defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2024/day/11
  """

  defp count_digits(v), do: :math.log10(v) |> floor() |> Kernel.+(1) |> trunc()

  defp blink(v, ^max, max), do: length(v)
  defp blink([0], step, max), do: blink([1], step + 1, max)

  defp blink(v) do
    digits = count_digits(v)

    cond do
      rem(digits, 2) == 0 -> split(v, digits)
      true -> [v * 2024]
    end
  end

  defp split(value, digits) do
    divisor = :math.pow(10, div(digits, 2)) |> trunc()

    [div(value, divisor), rem(value, divisor)]
  end

  defp count(stones) do
    stones |> List.flatten() |> Enum.count()
  end

  def parse(input) do
    input
    |> Enum.map(&String.to_integer/1)
  end

  def part1(stones) do
    0..24
    |> Enum.reduce(stones, fn _, acc ->
      acc
      |> Enum.flat_map(&blink/1)
    end)
    |> count()
  end

  def part2(stones) do
    0..74
    |> Enum.reduce(stones, fn _, acc ->
      acc
      |> Enum.flat_map(&blink/1)
    end)
    |> count()
  end
end

test_file =
  File.read!("test.txt")
  |> String.split(~r/\s+/, trim: true)

file =
  File.read!("input.txt")
  |> String.split(~r/\s+/, trim: true)

IO.inspect(test_file |> Solver.parse() |> Solver.part1(), label: "Part 1 Test")
IO.inspect(file |> Solver.parse() |> Solver.part1(), label: "Part 1 Real")
IO.inspect(test_file |> Solver.parse() |> Solver.part2(), label: "Part 2 Test")
IO.inspect(file |> Solver.parse() |> Solver.part2(), label: "Part 2 Real")
