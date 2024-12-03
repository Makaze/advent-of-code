Mix.install([
  {:nimble_parsec, "~> 1.4"}
])

defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2024/day/3
  """

  import NimbleParsec

  dont =
    ignore(string("don't()"))
    |> ignore(
      repeat(
        lookahead_not(string("do()"))
        |> utf8_char([])
      )
    )
    |> ignore(string("do()"))

  anything = ignore(utf8_char([]))

  muls =
    ignore(string("mul("))
    |> integer(max: 3)
    |> ignore(string(","))
    |> integer(max: 3)
    |> ignore(string(")"))
    |> reduce({Enum, :product, []})

  defparsec(
    :part1,
    repeat(
      choice([
        muls,
        anything
      ])
    )
  )

  defparsec(
    :part2,
    repeat(
      choice([
        dont,
        muls,
        anything
      ])
    )
  )

  def sum({:ok, results, _, _, _, _}) do
    Enum.sum(results)
  end
end

file =
  File.read!("input.txt")

# File.read!("test2.txt")

# File.read!("test.txt")

part1 = file |> Solver.part1() |> Solver.sum()
part2 = file |> Solver.part2() |> Solver.sum()

IO.inspect(part1, label: "Part 1")
IO.inspect(part2, label: "Part 2")
