Mix.install([
  {:nimble_parsec, "~> 1.4"}
])

defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2024/day/13
  """

  import NimbleParsec

  def equation_from([ax, ay, bx, by, px, py]),
    do: %{a: %{x: ax, y: ay}, b: %{x: bx, y: by}, prize: %{x: px, y: py}}

  whitespace = ignore(utf8_char([?\n, ?\r]))
  anything = ignore(utf8_char([]))

  equation =
    ignore(string("Button A: X+"))
    |> integer(min: 1)
    |> ignore(string(", Y+"))
    |> integer(min: 1)
    |> repeat(whitespace)
    |> ignore(string("Button B: X+"))
    |> integer(min: 1)
    |> ignore(string(", Y+"))
    |> integer(min: 1)
    |> repeat(whitespace)
    |> ignore(string("Prize: X="))
    |> integer(min: 1)
    |> ignore(string(", Y="))
    |> integer(min: 1)
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

  def sum({:ok, results, _, _, _, _}, adjustment \\ 0) do
    results
    |> Enum.map(fn %{a: a, b: b, prize: prize} ->
      prize = %{x: prize.x + adjustment, y: prize.y + adjustment}

      b_button =
        case a.x * b.y - a.y * b.x do
          det when rem(a.x * prize.y - a.y * prize.x, det) == 0 ->
            div(a.x * prize.y - a.y * prize.x, det)

          _ ->
            false
        end

      a_button =
        case a.x * b.y - a.y * b.x do
          det
          when rem(det * prize.x - b.x * a.x * prize.y + b.x * a.y * prize.x, det * a.x) == 0 ->
            div(det * prize.x - b.x * a.x * prize.y + b.x * a.y * prize.x, det * a.x)

          _ ->
            false
        end

      if Enum.all?([a_button, b_button]) do
        3 * a_button + b_button
      else
        0
      end
    end)
    |> Enum.sum()
  end
end

test_file =
  File.read!("test.txt")

file =
  File.read!("input.txt")

IO.inspect(test_file |> Solver.parse() |> Solver.sum(), label: "Part 1 Test")
IO.inspect(file |> Solver.parse() |> Solver.sum(), label: "Part 1 Real")

IO.inspect(test_file |> Solver.parse() |> Solver.sum(10_000_000_000_000), label: "Part 2 Test")
IO.inspect(file |> Solver.parse() |> Solver.sum(10_000_000_000_000), label: "Part 2 Real")
