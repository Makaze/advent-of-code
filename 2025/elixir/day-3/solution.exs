Mix.install([
  {:nimble_parsec, "~> 1.4"}
])

defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2025/day/3
  """

  import NimbleParsec

  anything = ignore(utf8_char([]))

  defparsec(
    :parse,
    repeat(
      choice([
        integer(min: 1),
        anything
      ])
    )
  )

  defp bubble(stack, _digit, 0), do: {stack, 0}
  defp bubble([], _digit, rem), do: {[], rem}

  defp bubble([head | tail], digit, rem) when head < digit do
    bubble(tail, digit, rem - 1)
  end

  defp bubble(stack, _digit, rem), do: {stack, rem}

  def max_k_digits(digits, k) do
    remove = length(digits) - k

    digits
    |> Enum.reduce({[], remove}, fn d, {stack, rem} ->
      {stack, rem} = bubble(stack, d, rem)
      {[d | stack], rem}
    end)
    |> elem(0)
    |> Enum.reverse()
    |> Enum.take(k)
  end

  def part1({:ok, ranges, _, _, _, _}) do
    ranges
    |> Enum.map(fn x ->
      Integer.digits(x) |> max_k_digits(2) |> Integer.undigits()
    end)
    |> Enum.sum()
  end

  def part2({:ok, ranges, _, _, _, _}) do
    ranges
    |> Enum.map(fn x ->
      Integer.digits(x) |> max_k_digits(12) |> Integer.undigits()
    end)
    |> Enum.sum()
  end
end

test_file =
  File.read!("test.txt")

file =
  File.read!("input.txt")

IO.inspect(test_file |> Solver.parse() |> Solver.part1(), label: "Part 1 Test")
IO.inspect(file |> Solver.parse() |> Solver.part1(), label: "Part 1 Real")

IO.inspect(test_file |> Solver.parse() |> Solver.part2(), label: "Part 2 Test")
IO.inspect(file |> Solver.parse() |> Solver.part2(), label: "Part 2 Real")
