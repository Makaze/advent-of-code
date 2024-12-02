defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2024/day/1
  """

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
