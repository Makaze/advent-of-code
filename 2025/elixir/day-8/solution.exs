Mix.install([
  {:nimble_parsec, "~> 1.4"}
])

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
      |> Enum.reduce(%{last_val: 0, circuits: %{}}, fn {el, i}, acc ->
        acc
        |> Map.put(el, i)
        |> push_in([:circuits, i], %{el => true})
      end)

    {{xa, _ya, _za}, {xb, _yb, _zb}} =
      data
      |> solve()
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
test_part2 = test_file |> Solver.part2()

file =
  File.read!("input.txt") |> Solver.parse()

real_part1 = file |> Solver.part1(1000)
real_part2 = file |> Solver.part2()

IO.inspect(test_part1, label: "Part 1 Test")
IO.inspect(real_part1, label: "Part 1 Real")

IO.inspect(test_part2, label: "Part 2 Test")
IO.inspect(real_part2, label: "Part 2 Real")
