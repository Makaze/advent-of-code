Mix.install([
  {:nimble_parsec, "~> 1.4"}
])

defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2024/day/7
  """

  import NimbleParsec

  def file_from([file, gap]), do: %{file: file, gap: gap}
  def file_from([file]), do: %{file: file, gap: 0}

  anything = ignore(utf8_char([]))

  file_gap =
    integer(max: 1)
    |> integer(max: 1)
    |> reduce({__MODULE__, :file_from, []})

  file_only =
    integer(max: 1)
    |> reduce({__MODULE__, :file_from, []})

  defparsec(
    :parse,
    repeat(
      choice([
        file_gap,
        file_only
      ])
    )
  )

  def to_map(files) do

    files =
      files
      |> Enum.with_index()

    [_ | rest] =
      files
      |> Enum.reverse()

    data = %{last_index: 0, disk: %{}, rest: rest}


    map = files
      |> Enum.reduce(data, fn {file, index}, acc ->
        acc =
          Enum.reduce(0..file.file, acc, fn key, inner_acc ->
            key = key + inner_acc.last_index
            %{inner_acc | key => index, last_index: key}
          end)

        Enum.reduce(0..file.gap, acc, fn key, inner_acc ->
          [last | rest] = acc.rest
          key = key + inner_acc.last_index
          
          %{inner_acc | key => nil, last_index: key}
        end)
      end)

    Enum.reduce((map.last_index - 1)..0, map, fn reversi, acc ->
      case acc[reversi] do
        nil ->
          nil
      end
    end)
  end

  def sum({:ok, results, _, _, _, _}, ops) do
    results
    |> Enum.map(fn eq ->
      case eval(nil, eq, Enum.at(eq, 0), ops) do
        {true, acc} -> acc
        {false, _} -> 0
      end
    end)
    |> Enum.sum()
  end
end

test_file =
  File.read!("test.txt")

file =
  File.read!("input.txt")

part1_test = test_file |> Solver.parse() |> Solver.sum([&Solver.divide/2, &-/2])
IO.inspect(part1_test, label: "Part 1 Test")
part1 = file |> Solver.parse() |> Solver.sum([&Solver.divide/2, &-/2])
IO.inspect(part1, label: "Part 1 Real")

part2_test =
  test_file |> Solver.parse() |> Solver.sum([&Solver.unconcat/2, &Solver.divide/2, &-/2])

IO.inspect(part2_test, label: "Part 2 Test")
part2 = file |> Solver.parse() |> Solver.sum([&Solver.unconcat/2, &Solver.divide/2, &-/2])
IO.inspect(part2, label: "Part 2 Real")
