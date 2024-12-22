defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2024/day/9
  """

  def map({nil, _}), do: []
  def map({file, _}) when file < 0, do: []
  def map({file, index}) when rem(index, 2) == 0, do: List.duplicate(div(index, 2), file)
  def map({file, _}), do: List.duplicate(nil, file)

  def defrag(files, [], _), do: files |> List.flatten() |> Enum.with_index()

  def defrag(files, [move | rev], out) do
    index =
      files |> Enum.find_index(fn x -> hd(x) == nil and length(x) >= length(move) end)

    move_index = files |> Enum.find_index(&(&1 == move))

    cond do
      index == nil or move_index > index ->
        case index do
          nil ->
            defrag(files, rev, out)

          _ ->
            next = files |> Enum.at(index)

            files =
              files
              |> Enum.with_index()
              |> Enum.map(fn
                {^move, _i} -> List.duplicate(nil, length(move))
                {_v, ^index} -> move
                {v, _i} -> v
              end)

            cond do
              length(next) == length(move) ->
                defrag(files, rev, out)

              true ->
                files =
                  files
                  |> List.insert_at(index + 1, List.duplicate(nil, length(next) - length(move)))

                defrag(files, rev, out)
            end
        end

      true ->
        defrag(files, rev, out)
    end
  end

  def defrag([], _, out, _), do: out |> Enum.reverse() |> Enum.with_index()
  def defrag(_, _, out, max) when length(out) >= max, do: defrag([], [], out, max)
  def defrag([nil | _], [], out, max), do: defrag([], [], out, max)
  def defrag([nil | files], [next | rev], out, max), do: defrag(files, rev, [next | out], max)
  def defrag([next | files], rev, out, max), do: defrag(files, rev, [next | out], max)

  def part1(files) do
    files = files |> Enum.with_index() |> Enum.map(&map/1) |> List.flatten()
    reversed = files |> Enum.filter(& &1) |> Enum.reverse()

    defrag(files, reversed, [], length(reversed))
    |> Enum.map(fn {val, index} -> val * index end)
    |> Enum.sum()
  end

  def part2(files) do
    files = files |> Enum.with_index() |> Enum.map(&map/1) |> Enum.filter(&(&1 != []))
    reversed = files |> Enum.filter(&hd(&1)) |> Enum.reverse()

    val = defrag(files, reversed, [])

    val
    |> Enum.map(fn
      {nil, _index} -> 0
      {val, index} -> val * index
    end)
    |> Enum.sum()
  end
end

test_file =
  File.stream!("test.txt", [], 1)
  |> Stream.map(fn <<b>> -> b - ?0 end)

file =
  File.stream!("input.txt", [], 1)
  |> Stream.map(fn <<b>> -> b - ?0 end)

part1_test = test_file |> Solver.part1()
IO.inspect(part1_test, label: "Part 1 Test")
part1 = file |> Solver.part1()
IO.inspect(part1, label: "Part 1 Real")

part2_test = test_file |> Solver.part2()
IO.inspect(part2_test, label: "Part 2 Test")
part2 = file |> Solver.part2()
IO.inspect(part2, label: "Part 2 Real")
