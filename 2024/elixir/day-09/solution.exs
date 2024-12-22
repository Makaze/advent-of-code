defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2024/day/7
  """

  def map({nil, _}), do: []
  def map({file, _}) when file < 0, do: []
  def map({file, index}) when rem(index, 2) == 0, do: List.duplicate(div(index, 2), file)
  def map({file, _}), do: List.duplicate(nil, file)

  def defrag([], _, out, _), do: out |> Enum.reverse() |> Enum.with_index()
  def defrag(_, _, out, max) when length(out) >= max, do: defrag([], [], out, max)
  def defrag([nil | _], [], out, max), do: defrag([], [], out, max)

  def defrag([nil | files], [next | reverse], out, max),
    do: defrag(files, reverse, [next | out], max)

  def defrag([next | files], reverse, out, max), do: defrag(files, reverse, [next | out], max)

  def sort(files) do
    files = files |> Enum.with_index() |> Enum.map(&map/1) |> List.flatten()
    reversed = files |> Enum.filter(& &1) |> Enum.reverse()
    IO.inspect({files, reversed})

    defrag(files, reversed, [], length(reversed))
  end

  def sum(results) do
    results
    |> sort()
    |> Enum.map(fn {val, index} -> val * index end)
    |> Enum.sum()
  end
end

test_file =
  File.stream!("test.txt", [], 1)
  |> Stream.map(fn <<b>> -> b - ?0 end)

file =
  File.stream!("input.txt", [], 1)
  |> Stream.map(fn <<b>> -> b - ?0 end)

part1_test = test_file |> Solver.sum()
IO.inspect(part1_test, label: "Part 1 Test")
part1 = file |> Solver.sum()
IO.inspect(part1, label: "Part 1 Real")

# part2_test = test_file |> Solver.parse() |> Solver.sum()
# IO.inspect(part2_test, label: "Part 2 Test")
# part2 = file |> Solver.parse() |> Solver.sum()
# IO.inspect(part2, label: "Part 2 Real")
