Mix.install([
  {:nimble_parsec, "~> 1.4"}
])

defmodule Rule do
  defstruct [:left, :right]
end

defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2024/day/5
  """

  import NimbleParsec

  def rule_from([left, right]), do: %Rule{left: left, right: right}

  anything = ignore(utf8_char([]))

  rule =
    integer(max: 2)
    |> ignore(string("|"))
    |> integer(max: 2)
    |> optional(ignore(anything))
    |> reduce({__MODULE__, :rule_from, []})

  page =
    choice([
      integer(max: 2),
      ignore(string(","))
    ])

  defparsec(
    :rules,
    repeat(rule)
  )

  defparsec(
    :pages,
    repeat(
      choice([
        page,
        anything
      ])
    )
  )

  def sum({:ok, results, _, _, _, _}) do
    Enum.sum(results)
  end
end

[rules, updates] =
  File.read!("test.txt")
  |> String.split(~r/\s\s+/, trim: true)

# File.read!("input.txt")

# File.read!("test.txt")

part1 = rules |> Solver.rules()
part2 = updates |> Solver.pages()

IO.inspect(part1, label: "Part 1")
IO.inspect(part2, label: "Part 2")
