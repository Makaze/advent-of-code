Mix.install([
  {:nimble_parsec, "~> 1.4"}
])

defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2024/day/7
  """

  import NimbleParsec

  def equation_from([result | rest]), do: %{result: result, values: rest}

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
  def divide(a, b), do: :invalid

  def unconcat(a, b) do
    res = a * 10 ** trunc(:math.log10(b) + 1) + b
    # IO.inspect({a, b, res}, label: "concat result")
    res
    size_b = :math.log10(x) |> floor() |> Kernel.+(1) |> trunc()
    divisor = :math.pow(10, size_b) |> trunc()
    case rem(number, divisor) do
      val when val == b -> div(number, divisor)
      _ -> :invalid
    end
  end

  def eval(acc, [], result, ops, _ops_list) do
    value = {acc == result, {acc, result, ops}}
    # IO.inspect(value, label: "End result?")
    value
  end

  def eval(nil, [first | rest], result, ops, ops_list) do
    eval(first, rest, result, ops, ops_list)
  end

  def eval(acc, _, result, ops, _ops_list) when acc > result do
    {false, {acc, result, ops}}
  end

  def eval(acc, [first | rest], result, ops, ops_list) when acc <= result do
    Enum.reduce_while(ops_list, 0, fn op, _ ->
      case eval(op.(acc, first), rest, result, [op | ops], ops_list) do
        {true, val} ->
          # IO.inspect(val, label: "Oh boy")
          {:halt, {true, val}}

        {false, val} ->
          {:cont, {false, val}}
      end
    end)
  end

  def sum({:ok, results, _, _, _, _}, ops) do
    results
    |> Enum.map(fn eq ->
      case eval(nil, eq.values, eq.result, [], ops) do
        {true, {acc, _, _}} -> acc
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

part1_test = test_file |> Solver.parse() |> Solver.sum([&+/2, &*/2])
IO.inspect(part1_test, label: "Part 1 test")
part1 = file |> Solver.parse() |> Solver.sum([&+/2, &*/2])
IO.inspect(part1, label: "Part 1 Real")

part2_test = test_file |> Solver.parse() |> Solver.sum([&Solver.concat_int/2, &*/2, &+/2])
IO.inspect(part2_test, label: "Part 2 Test")
part2 = file |> Solver.parse() |> Solver.sum([&Solver.concat_int/2, &*/2, &+/2])
IO.inspect(part2, label: "Part 2 Real")
