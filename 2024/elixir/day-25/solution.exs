Mix.install([
  {:nimble_parsec, "~> 1.4"}
])

defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2024/day/23
  """

  import NimbleParsec

  def lock_from(nodes), do: heights_from(nodes, :lock)
  def key_from(nodes), do: heights_from(nodes, :key)

  def heights_from(nodes, type) do
    nodes
    |> Enum.map(fn line ->
      String.graphemes(line)
      |> Enum.map(fn char ->
        case char do
          "#" -> 1
          _ -> 0
        end
      end)
    end)
    |> Enum.reduce(%{type: type}, fn elem, acc ->
      elem
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {x, i}, new_acc -> Map.update(new_acc, i, x, fn v -> v + x end) end)
    end)
  end

  anything = ignore(utf8_char([]))
  whitespace = ignore(utf8_char([?\n, ?\r]))

  lock =
    ascii_string([?#], min: 5)
    |> times(
      whitespace
      |> ascii_string([?., ?#], min: 5),
      6
    )
    |> reduce({__MODULE__, :lock_from, []})

  key =
    ignore(ascii_string([?.], min: 5))
    |> times(
      whitespace
      |> ascii_string([?., ?#], min: 5),
      6
    )
    |> reduce({__MODULE__, :key_from, []})

  defparsec(
    :parse,
    repeat(
      choice([
        lock,
        key,
        whitespace,
        anything
      ])
    )
  )

  def update(path, keys, value), do: put_in(path, Enum.map(keys, &Access.key(&1, %{})), value)

  def map({:ok, objects, _, _, _, _}) do
    objects
    |> Enum.split_with(&(&1[:type] == :lock))
  end

  def part1({locks, keys}) do
    for l <- locks, k <- keys do
      0..4
      |> Enum.all?(fn i -> l[i] + k[i] <= 7 end)
    end
    |> Enum.count(& &1)
  end

  def part2(map) do
    map
  end
end

test_file =
  File.read!("test.txt")
  |> Solver.parse()
  |> Solver.map()

file =
  File.read!("input.txt")
  |> Solver.parse()
  |> Solver.map()

IO.inspect(test_file |> Solver.part1(), label: "Part 1 Test")
IO.inspect(file |> Solver.part1(), label: "Part 1 Real")
# IO.inspect(test_file |> Solver.part2(), label: "Part 2 Test")
# IO.inspect(file |> Solver.part2(), label: "Part 2 Real")
