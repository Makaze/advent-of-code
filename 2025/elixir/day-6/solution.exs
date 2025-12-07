Mix.install([
  {:nimble_parsec, "~> 1.4"},
  {:nx, "~> 0.10"}
])

defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2025/day/6
  """

  import NimbleParsec

  def row_from(x), do: x

  anything = ignore(utf8_char([]))
  whitespace = utf8_char([?\s, ?\t])

  arg = integer(min: 1)
  digit = integer(1)

  operation =
    choice([
      string("+") |> replace(-1),
      string("*") |> replace(-2)
    ])

  row =
    repeat(
      choice([
        operation,
        arg,
        ignore(whitespace)
      ])
    )
    |> ignore(anything)
    |> reduce({__MODULE__, :row_from, []})

  columns =
    repeat(
      choice([
        operation,
        digit,
        whitespace |> replace(:nan)
      ])
    )
    |> ignore(anything)
    |> reduce({__MODULE__, :row_from, []})

  defparsec(
    :parse,
    repeat(
      choice([
        row,
        anything
      ])
    )
  )

  defparsec(
    :parse2,
    repeat(
      choice([
        columns,
        anything
      ])
    )
  )

  def get_in_tuple(tuple, []) do
    tuple
  end

  def get_in_tuple(tuple, index) when is_integer(index), do: get_in_tuple(tuple, [index])

  def get_in_tuple(tuple, [index | rest])
      when is_tuple(tuple) and tuple_size(tuple) - 1 >= index and index >= 0 do
    elem(tuple, index) |> get_in_tuple(rest)
  end

  def get_in_tuple(tuple, index), do: {:index_error, tuple, index}

  def part1({:ok, ranges, _, _, _, _}) do
    {args, [ops]} =
      ranges
      |> Enum.split_with(fn
        [x | _r] when is_integer(x) and x > 0 -> true
        _ -> false
      end)

    args = args |> Enum.map(&List.to_tuple/1)

    ops
    |> Enum.with_index()
    |> Enum.map(fn
      {-1, i} -> args |> Enum.reduce(0, fn x, acc -> acc + get_in_tuple(x, i) end)
      {-2, i} -> args |> Enum.reduce(1, fn x, acc -> acc * get_in_tuple(x, i) end)
    end)
    |> Enum.sum()
  end

  def part2({:ok, ranges, _, _, _, _}) do
    args =
      ranges
      |> Enum.map(&Enum.reverse/1)

    args = args |> Nx.tensor() |> Nx.transpose()
  end
end

test_file =
  File.read!("test.txt")

file =
  File.read!("input.txt")

IO.inspect(test_file |> Solver.parse() |> Solver.part1(), label: "Part 1 Test")
IO.inspect(file |> Solver.parse() |> Solver.part1(), label: "Part 1 Real")

IO.inspect(test_file |> Solver.parse2() |> Solver.part2(), label: "Part 2 Test")
# IO.inspect(file |> Solver.parse2() |> Solver.part2(), label: "Part 2 Real")
