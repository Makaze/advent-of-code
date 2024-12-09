defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2024/day/1
  """

  def count_valid([["X", "X", "X", "X"],
                   ["M", "M", "M", "M"],
                   ["A", "A", "A", "A"],
                   ["S", "S", "S", "S"]]), do: 6

  def count_valid([["S", "S", "S", "S"],
                   ["A", "A", "A", "A"],
                   ["M", "M", "M", "M"],
                   ["X", "X", "X", "X"]]), do: 6

  def count_valid([["X", "M", "A", "S"],
                   ["X", "M", "A", "S"],
                   ["X", "M", "A", "S"],
                   ["X", "M", "A", "S"]]), do: 6

  def count_valid([["S", "A", "M", "X"],
                   ["S", "A", "M", "X"],
                   ["S", "A", "M", "X"],
                   ["S", "A", "M", "X"]]), do: 6

  def count_valid([["X", "M", "A", "S"],
                   [_, "M", "A", _],
                   [_, "M", "A", _],
                   ["X", "M", "A", "S"]]), do: 4

  def count_valid([["S", "A", "M", "X"],
                   [_, "A", "M", _],
                   [_, "A", "M", _],
                   ["S", "A", "M", "X"]]), do: 4

  def count_valid([["X", _, _, "X"],
                   ["M", "M", "M", "M"],
                   ["A", "A", "A", "A"],
                   ["S", _, _, "S"]]), do: 4

  def count_valid([["S", _, _, "S"],
                   ["A", "A", "A", "A"],
                   ["M", "M", "M", "M"],
                   ["X", _, _, "X"]]), do: 4


  def count_valid([["S", _, _, "S"],
                   ["A", "A", "A", "A"],
                   ["M", "M", "M", "M"],
                   ["X", _, _, "X"]]), do: 4

  def count_valid([["X", "M", "A", "S"],
                   [_, "M", "A", _],
                   [_, "M", "A", _],
                   ["X", _, _, "S"]]), do: 3

  def count_valid([["S", _, _, "X"],
                   [_, "A", "M", _],
                   [_, "A", "M", _],
                   ["X", "M", "A", "S"]]), do: 3

  def count_valid([["X", "X", "X", _],
                   ["M", "M", "M", _],
                   ["A", "A", "A", _],
                   ["S", "S", "S", _]]), do: 3
  def count_valid([["X", "X", _, "X"],
                   ["M", "M", _, "M"],
                   ["A", "A", _, "A"],
                   ["S", "S", _, "S"]]), do: 3
  def count_valid([["X", _, "X", "X"],
                   ["M", _, "M", "M"],
                   ["A", _, "A", "A"],
                   ["S", _, "S", "S"]]), do: 3
  def count_valid([[_, "X", "X", "X"],
                   [_, "M", "M", "M"],
                   [_, "A", "A", "A"],
                   [_, "S", "S", "S"]]), do: 3

  def count_valid([["S", "S", "S", _],
                   ["A", "A", "A", _],
                   ["M", "M", "M", _],
                   ["X", "X", "X", _]]), do: 3
  def count_valid([["S", "S", _, "S"],
                   ["A", "A", _, "A"],
                   ["M", "M", _, "M"],
                   ["X", "X", _, "X"]]), do: 3
  def count_valid([["S", _, "S", "S"],
                   ["A", _, "A", "A"],
                   ["M", _, "M", "M"],
                   ["X", _, "X", "X"]]), do: 3
  def count_valid([[_, "S", "S", "S"],
                   [_, "A", "A", "A"],
                   [_, "M", "M", "M"],
                   [_, "X", "X", "X"]]), do: 3

  def count_valid([["X", "M", "A", "S"],
                   ["X", "M", "A", "S"],
                   ["X", "M", "A", "S"],
                   [_, _, _, _]]), do: 3
  def count_valid([["X", "M", "A", "S"],
                   ["X", "M", "A", "S"],
                   [_, _, _, _],
                   ["X", "M", "A", "S"]]), do: 3
  def count_valid([["X", "M", "A", "S"],
                   [_, _, _, _],
                   ["X", "M", "A", "S"],
                   ["X", "M", "A", "S"]]), do: 3
  def count_valid([[_, _, _, _],
                   ["X", "M", "A", "S"],
                   ["X", "M", "A", "S"],
                   ["X", "M", "A", "S"]]), do: 3


  def count_valid([["S", "A", "M", "X"],
                   ["S", "A", "M", "X"],
                   ["S", "A", "M", "X"],
                   ["S", "A", "M", "X"]]), do: 6

  def count_valid([["X", "M", "A", "S"],
                   [_, "M", _, _],
                   [_, _, "A", _],
                   [_, _, _, "S"]]), do: 2

  def count_valid([["X", "M", "A", "S"],
                   [_, _, "A", _],
                   [_, "M", _, _],
                   ["X", _, _, _]]), do: 2

  def count_valid([["S", "A", "M", "X"],
                   [_, "A", _, _],
                   [_, _, "M", _],
                   [_, _, _, "X"]]), do: 2

  def count_valid([["S", "A", "M", "X"],
                   [_, _, "M", _],
                   [_, "A", _, _],
                   ["S", _, _, _]]), do: 2

  def count_valid([["X", _, _, "S"],
                   [_, "M", "A", _],
                   [_, "M", "A", _],
                   ["X", _, _, "S"]]), do: 2

  def count_valid([["X", _, _, "S"],
                   [_, "M", "M", _],
                   [_, "A", "A", _],
                   ["S", _, _, "S"]]), do: 2

  def count_valid([["X", _, _, _],
                   [_, "M", _, _],
                   [_, _, "A", _],
                   [_, _, _, "S"]]), do: 1



  def parse(row) do
    row
    |> String.trim()
    |> String.split(~r/\s+/)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  def sort(rows) do
    {left, right} = Enum.unzip(rows)

    {Enum.sort(left), Enum.sort(right), Enum.frequencies(right)}
  end

  def diff(left, right) do
    for {l, r} <- Enum.zip(left, right) do
      abs(l - r)
    end
  end

  def score(left, freq) do
    for l <- left do
      l * Map.get(freq, l, 0)
    end
  end
end

{left, right, freq} =
  File.stream!("input.txt")
  # File.stream!("test.txt")
  |> Stream.map(&Solver.parse/1)
  |> Solver.sort()

diff1 =
  Solver.diff(left, right)
  |> Enum.sum()

diff2 =
  Solver.score(left, freq)
  |> Enum.sum()

IO.puts("Part 1: #{diff1}")
IO.puts("Part 2: #{diff2}")
