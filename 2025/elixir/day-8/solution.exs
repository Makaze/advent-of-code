Mix.install([
  {:nimble_parsec, "~> 1.4"},
  {:sketch, git: "https://github.com/sannek/sketch.git", branch: "main"},
  {:jason, "~> 1.4"}
])

defmodule Projector do
  @type vec3 :: {number(), number(), number()}
  @type vec2 :: {number(), number()}

  @spec move_camera(vec3(), vec3()) :: vec3()
  def move_camera({x, y, z}, {cx, cy, cz}), do: {x - cx, y - cy, z - cz}

  @spec apply_perspective(vec3(), number()) :: vec2()
  def apply_perspective({x, y, z}, f \\ 1), do: {f * x / z, f * y / z}

  @spec project(vec3(), vec3(), number()) :: vec2()
  def project({_x, _y, _z} = point, cam_pos, f \\ 1) do
    point
    |> move_camera(cam_pos)
    |> apply_perspective(f)
  end
end

defmodule Svg do
  @type pt :: {number(), number()}
  @type seg :: {pt, pt}

  def render(lines, opts \\ []) do
    w = Keyword.get(opts, :width, 800)
    h = Keyword.get(opts, :height, 600)
    stroke = Keyword.get(opts, :stroke, "black")
    stroke_width = Keyword.get(opts, :stroke_width, 1)
    cam_pos = Keyword.get(opts, :cam_pos, {0, 0, 0})

    body =
      lines
      |> Enum.map(fn {_dist, a, b} ->
        {x1, y1} = Projector.project(a, cam_pos) |> Solver.scale()
        {x2, y2} = Projector.project(b, cam_pos) |> Solver.scale()

        ~s(<line x1="#{format(x1)}" y1="#{format(y1)}" x2="#{format(x2)}" y2="#{format(y2)}" stroke="#{stroke}" stroke-width="#{stroke_width}" />)
      end)
      |> Enum.join("\n  ")

    """
    <svg xmlns="http://www.w3.org/2000/svg" width="#{w}" height="#{h}" viewBox="0 0 #{w} #{h}">
      #{body}
    </svg>
    """
  end

  def write!(lines, path, opts \\ []) do
    File.write!(path, render(lines, opts))
  end

  defp format(n) when is_float(n), do: :erlang.float_to_binary(n, decimals: 3)
  defp format(n), do: to_string(n)
end

defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2025/day/8
  """

  import NimbleParsec

  def point_from(x), do: List.to_tuple(x)

  anything = ignore(utf8_char([]))

  row =
    integer(min: 1)
    |> ignore(string(","))
    |> integer(min: 1)
    |> ignore(string(","))
    |> integer(min: 1)
    |> reduce({__MODULE__, :point_from, []})

  defparsec(
    :parse,
    repeat(
      choice([
        row,
        anything
      ])
    )
  )

  def scale({x, y}) when x < 1000, do: {x * 100, y * 100}
  def scale({x, y}), do: {round(x) |> div(100), round(y) |> div(100)}

  def euclid_dist(a \\ [], b \\ [], result \\ 0)
  def euclid_dist([], _, result), do: :math.sqrt(result)
  def euclid_dist([d_a | a], [d_b | b], result), do: euclid_dist(a, b, result + (d_a - d_b) ** 2)

  def push_in(t, p, v), do: update_in(t, p, fn _ -> v end)

  def connect(a, b, circuits) do
    last_val = circuits.last_val
    a_circ = get_in(circuits, [a])
    b_circ = get_in(circuits, [b])

    case {a_circ, b_circ} do
      {nil, nil} ->
        v =
          circuits
          |> Map.put(a, last_val)
          |> Map.put(b, last_val)
          |> Map.put(:last_val, last_val + 1)

        push_in(v, [:circuits, last_val], %{a => true, b => true})

      {nil, circ_id} ->
        v =
          circuits
          |> Map.put(a, circ_id)

        push_in(v, [:circuits, circ_id, a], true)

      {circ_id, nil} ->
        v =
          circuits
          |> Map.put(b, circ_id)

        push_in(v, [:circuits, circ_id, b], true)

      {^a_circ, ^a_circ} ->
        circuits

      {j_a, j_b} ->
        b_circ_vals =
          get_in(circuits, [:circuits, j_b])

        {_o, v} =
          b_circ_vals
          |> Enum.reduce(circuits, fn {k, _}, acc ->
            acc
            |> push_in([k], j_a)
            |> push_in([:circuits, j_a, k], true)
          end)
          |> pop_in([:circuits, j_b])

        v
    end
  end

  def unique_pairs(e) do
    l = e |> Enum.with_index()

    for {x, i} <- l,
        {y, j} <- l,
        j > i do
      {x, y}
    end
  end

  def draw(data) do
    data
    |> Enum.reduce(
      {Sketch.new(width: 10_000, height: 10_000, background: {255, 255, 255}), 1},
      fn
        {_dist, a, b}, {s, i} ->
          cam_pos = {0, 0, 0}
          proj_a = Projector.project(a, cam_pos)
          proj_b = Projector.project(b, cam_pos)

          s =
            s
            |> Sketch.line(%{
              start: scale(proj_a),
              finish: scale(proj_b)
            })

          i = i + 1

          if rem(i, 100) == 0 do
            s |> Sketch.save()
          end

          {s, i}
      end
    )
    |> elem(0)
    |> Sketch.save()
  end

  def solve(data, count \\ 0) do
    res =
      data
      |> unique_pairs()
      |> Enum.map(fn
        {a, b} ->
          {al, bl} = {Tuple.to_list(a), Tuple.to_list(b)}
          {euclid_dist(al, bl, 0), a, b}
      end)
      |> List.flatten()
      |> Enum.sort()

    if count > 0 do
      res |> Enum.take(count)
    else
      res
    end
  end

  def part1({:ok, data, _, _, _, _}, count) do
    circuits =
      data
      |> Enum.reduce(%{last_val: 0, circuits: %{}}, fn el, acc -> acc |> Map.put(el, nil) end)

    data
    |> solve(count)
    |> Enum.reduce(circuits, fn {_dist, a, b}, acc ->
      v = connect(a, b, acc)
      v
    end)
    |> Map.get(:circuits)
    |> Enum.map(fn {_k, v} ->
      map_size(v)
    end)
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.take(3)
    |> Enum.product()
  end

  def part2({:ok, data, _, _, _, _}) do
    circuits =
      data
      |> Enum.with_index()
      |> Enum.reduce(
        %{last_val: 0, circuits: %{}},
        fn {el, i}, acc ->
          acc
          |> Map.put(el, i)
          |> push_in([:circuits, i], %{el => true})
        end
      )

    data =
      data
      |> solve()

    s =
      data
      |> Stream.map(fn {_dist, a, b} -> [a, b] |> Enum.map(&Tuple.to_list/1) end)
      |> Enum.take(10000)
      |> Jason.encode!()

    File.write!("viewer/list.json", s)

    # |> Svg.write!("output.svg",
    #   width: 10_000,
    #   height: 10_000,
    #   stroke_width: 3,
    #   cam_pos: {15_000, 0, 0}
    # )

    # |> draw()

    {{xa, _ya, _za}, {xb, _yb, _zb}} =
      data
      |> Enum.reduce_while(circuits, fn {_dist, a, b}, v ->
        v = connect(a, b, v)

        if map_size(v.circuits) == 1 and map_size(v.circuits |> Enum.at(0) |> elem(1)) > 3 do
          {:halt, {a, b}}
        else
          {:cont, v}
        end
      end)

    xa * xb
  end
end

test_file =
  File.read!("test.txt") |> Solver.parse()

test_part1 = test_file |> Solver.part1(10)
IO.inspect(test_part1, label: "Part 1 Test")

test_part2 = test_file |> Solver.part2()
IO.inspect(test_part2, label: "Part 2 Test")

file =
  File.read!("input.txt") |> Solver.parse()

real_part1 = file |> Solver.part1(1000)
IO.inspect(real_part1, label: "Part 1 Real")

real_part2 = file |> Solver.part2()
IO.inspect(real_part2, label: "Part 2 Real")
