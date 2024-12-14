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

  defp eval(:invalid, _rest, result, ops, _ops_list), do: {false, {result, ops}}
  defp eval(_acc, [], ops, result, _ops_list), do: {false, {result, ops}}

  defp eval(nil, [first | rest], result, ops, ops_list) do
    eval(first, rest, result, ops, ops_list)
  end

  defp eval(acc, terms, result, ops, ops_list) do
    do_op(acc, terms, result, ops, ops_list, ops_list)
  end

  defp do_op(_acc, _terms, result, ops, [], _ops_list), do: {false, {result, ops}}

  defp do_op(acc, [first | rest] = terms, result, ops, [op | rest_ops], ops_list) do
    output = op.(acc, first)
    solved = length(rest) == 1 and output == Enum.at(rest, 0)

    cond do
      solved ->
        {true, {result, [op | ops]}}

      true ->
        case eval(output, rest, result, [op | ops], ops_list) do
          {true, val} -> {true, val}
          _ -> do_op(acc, terms, result, ops, rest_ops, ops_list)
        end
    end
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
