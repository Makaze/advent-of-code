Mix.install([
  {:nimble_parsec, "~> 1.4"}
])

defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2024/day/7
  """

  import NimbleParsec

  def equation_from([result | rest]), do: [result | Enum.reverse(rest)]

  anything = ignore(utf8_char([]))

  equation =
    integer(min: 1)
    |> ignore(string(": "))
    |> repeat(choice([integer(min: 1), ignore(string(" "))]))
    |> reduce({__MODULE__, :equation_from, []})

  defparsec(
    :parse,
    repeat(
      choice([
        equation,
        anything
      ])
    )
  )

  def divide(a, b) when rem(a, b) == 0, do: div(a, b)
  def divide(_a, _b), do: :invalid

  def unconcat(a, b) do
    size_b = :math.log10(b) |> floor() |> Kernel.+(1) |> trunc()
    divisor = :math.pow(10, size_b) |> trunc()

    case rem(a, divisor) do
      val when val == b -> div(a, divisor)
      _ -> :invalid
    end
  end

  def eval(acc, _rest, result, ops, _ops_list) when acc == :invalid do
    {false, {result, ops}}
  end

  def eval(_acc, [], ops, result, _ops_list), do: {false, {result, ops}}

  def eval(nil, [first | rest], result, ops, ops_list) do
    eval(first, rest, result, ops, ops_list)
  end

  def eval(acc, [first | rest], result, ops, ops_list) do
    Enum.reduce_while(ops_list, 0, fn op, _ ->
      output = op.(acc, first)
      solved = length(rest) == 1 and output == Enum.at(rest, 0)

      case solved or eval(output, rest, result, [op | ops], ops_list) do
        true ->
          {:halt, {true, {result, [op | ops]}}}

        {true, val} ->
          {:halt, {true, val}}

        {false, val} ->
          {:cont, {false, val}}
      end
    end)
  end

  def sum({:ok, results, _, _, _, _}, ops) do
    results
    |> Enum.map(fn eq ->
      case eval(nil, eq, Enum.at(eq, 0), [], ops) do
        {true, {acc, _}} -> acc
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
