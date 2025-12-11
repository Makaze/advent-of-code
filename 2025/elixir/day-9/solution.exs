Mix.install([
  {:nimble_parsec, "~> 1.4"},
  {:sketch, git: "https://github.com/sannek/sketch.git", branch: "main"}
])

defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2025/day/9
  """

  import NimbleParsec

  def point_from(x), do: List.to_tuple(x)

  anything = ignore(utf8_char([]))

  row =
    integer(min: 1)
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

  def area({ax, ay}, {bx, by}), do: (abs(ax - bx) + 1) * (abs(ay - by) + 1)

  def push_in(t, p, v), do: update_in(t, p, fn _ -> v end)

  def unique_pairs(e) do
    l = e |> Enum.with_index()

    for {x, i} <- l,
        {y, j} <- l,
        j > i do
      {x, y}
    end
  end

  def rect_from({ax, ay}, {bx, by}) do
    [top, bottom] = [ay, by] |> Enum.sort()
    [left, right] = [ax, bx] |> Enum.sort()

    {top, left, bottom, right}
  end

  def orientation({ax, ay}, {bx, by}, {cx, cy}) do
    area = (bx - ax) * (cy - ay) - (by - ay) * (cx - ax)

    cond do
      area > 0 -> :ccw
      area < 0 -> :cw
      true -> :collinear
    end
  end

  def orientation(points) when is_list(points) do
    area =
      points
      |> Stream.chunk_every(2, 1, [hd(points)])
      |> Enum.reduce(0, fn [{x1, y1}, {x2, y2}], acc ->
        acc + (x1 * y2 - x2 * y1)
      end)

    cond do
      area > 0 -> :ccw
      area < 0 -> :cw
      true -> :collinear
    end
  end

  def perim(%MapSet{map: m} = points, []) do
    p = :maps.iterator(m) |> :maps.next() |> elem(0)
    perim(points |> MapSet.delete(p), [p])
  end

  def perim(%MapSet{map: m}, acc) when map_size(m) == 0, do: {acc, orientation(acc)}

  def perim(points, [{x, y} | _rest] = acc) do
    neighbor =
      [
        {x, y + 1},
        {x + 1, y},
        {x, y - 1},
        {x - 1, y}
      ]
      |> Enum.find(fn p -> points |> MapSet.member?(p) end)

    perim(points |> MapSet.delete(neighbor), [neighbor | acc])
  end

  def inside?({top, left, bottom, right}, {x, y})
      when x > left and x < right and
             y > top and y < bottom,
      do: true

  def inside?(_rect, _point), do: false

  def scale({x, y}) when x < 100, do: {x * 100, y * 100}
  def scale({x, y}), do: {x |> div(100), y |> div(100)}

  def solve(data, count \\ 0) do
    res =
      data
      |> unique_pairs()
      |> Stream.map(fn
        {a, b} ->
          {area(a, b), a, b}
      end)
      |> Enum.sort(&(&1 > &2))

    if count > 0 do
      res |> Enum.take(count)
    else
      res
    end
  end

  def part1({:ok, data, _, _, _, _}, count) do
    [{res, _a, _b}] = solve(data, count)
    res
  end

  def part2({:ok, data, _, _, _, _}) do
    res = solve(data)

    {horizontals, verticals, sketch} =
      res
      |> Enum.reduce(
        {MapSet.new(), MapSet.new(), Sketch.new(width: 1100, height: 1100)},
        fn {_d, {ax, ay}, {bx, by}}, {horizontals, verticals, sketch} = acc ->
          case {abs(ax - bx), abs(ay - by)} do
            {0, _} ->
              [n, x] = [ay, by] |> Enum.sort()

              sketch =
                sketch
                |> Sketch.line(%{
                  start: scale({ax, n}),
                  finish: scale({ax, x})
                })

              verticals =
                n..x
                |> Enum.reduce(verticals, fn y_val, inner_acc ->
                  inner_acc |> MapSet.put({ax, y_val})
                end)

              {horizontals, verticals, sketch}

            {_, 0} ->
              [n, x] = [ax, bx] |> Enum.sort()

              sketch =
                sketch
                |> Sketch.line(%{
                  start: scale({n, ay}),
                  finish: scale({x, ay})
                })

              horizontals =
                n..x
                |> Enum.reduce(horizontals, fn x_val, inner_acc ->
                  inner_acc |> MapSet.put({x_val, ay})
                end)

              {horizontals, verticals, sketch}

            _ ->
              acc
          end
        end
      )

    loop = MapSet.union(verticals, horizontals)

    perimeter = perim(loop, [])

    sketch |> Sketch.save()

    res =
      res
      |> Enum.find(fn {_d, a, b} ->
        {top, left, bottom, right} = rect_from(a, b)

        v =
          not (perimeter
               |> elem(0)
               |> Enum.any?(fn p -> inside?({top, left, bottom, right}, p) end))

        if v do
          sketch
          |> Sketch.rect(%{
            origin: scale({left, top}),
            width: scale({right - left, 0}) |> elem(0),
            height: scale({bottom - top, 0}) |> elem(0)
          })
          |> Sketch.save()
        end

        v
      end)
      |> elem(0)
  end

  def run() do
    test_file =
      File.read!("test.txt") |> Solver.parse()

    test_part1 = test_file |> Solver.part1(1)
    test_part2 = test_file |> Solver.part2()

    file =
      File.read!("input.txt") |> Solver.parse()

    real_part1 = file |> Solver.part1(1)
    real_part2 = file |> Solver.part2()

    IO.inspect(test_part1, label: "Part 1 Test")
    IO.inspect(real_part1, label: "Part 1 Real")

    IO.inspect(test_part2, label: "Part 2 Test")
    IO.inspect(real_part2, label: "Part 2 Real")
  end

  def t() do
    Task.async(fn -> Solver.run() end)
  end

  def trace(t) do
    Process.info(t.pid, :current_stacktrace)
  end
end
