Mix.install([
  {:nimble_parsec, "~> 1.4"}
])

defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2025/day/1
  """

  import NimbleParsec

  def left_from([result | _rest]), do: result * -1
  def right_from([result | _rest]), do: result

  anything = ignore(utf8_char([]))

  left_turn =
    ignore(string("L"))
    |> integer(min: 1)
    |> reduce({__MODULE__, :left_from, []})

  right_turn =
    ignore(string("R"))
    |> integer(min: 1)
    |> reduce({__MODULE__, :right_from, []})

  defparsec(
    :parse,
    repeat(
      choice([
        left_turn,
        right_turn,
        anything
      ])
    )
  )

  defp r1(elem, {last, exact, passes}) when rem(last + elem, 100) == 0 do
    extra = abs(div(elem, 100))

    extra =
      if rem(elem, 100) == 0 do
        extra - 1
      else
        extra
      end

    # IO.inspect({elem, last, last + elem, exact, passes}, label: "== 0")
    {0, exact + 1, passes + 1 + extra}
  end

  defp r1(elem, {last, exact, passes}) when last != 0 and last < 0 != last + elem < 0 do
    # IO.inspect({elem, last, last + elem, exact, passes}, label: "+- case")
    {rem(last + elem, 100), exact, passes + 1 + abs(div(last + elem, 100))}
  end

  defp r1(elem, {last, exact, passes}) do
    # IO.inspect({elem, last, last + elem, exact, passes}, label: "other case")
    {rem(last + elem, 100), exact, passes + abs(div(last + elem, 100))}
  end

  def part1({:ok, results, _, _, _, _}) do
    results
    |> Enum.reduce({50, 0, 0}, &r1/2)
  end
end

test_file =
  File.read!("test.txt")

file =
  File.read!("input.txt")

IO.inspect(test_file |> Solver.parse() |> Solver.part1(), label: "Part 1 Test")
IO.inspect(file |> Solver.parse() |> Solver.part1(), label: "Part 1 Real")
