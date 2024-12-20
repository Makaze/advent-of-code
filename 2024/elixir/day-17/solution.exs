Mix.install([
  {:nimble_parsec, "~> 1.4"}
])

defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2024/day/17
  """

  import NimbleParsec

  def register_from(regs) do
    regs
    |> Enum.chunk_every(2)
    |> Enum.reduce(%{65 => nil, 66 => nil, 67 => nil}, fn [key, val], acc ->
      %{acc | key => val}
    end)
  end

  def program_from(rest), do: rest

  whitespace = ignore(utf8_char([?\n, ?\r]))
  anything = ignore(utf8_char([]))

  reg =
    ignore(string("Register "))
    |> repeat(
      choice([
        ascii_char([?A, ?B, ?C])
        |> ignore(string(": "))
        |> integer(min: 1),
        ignore(string("Register ")),
        whitespace
      ])
    )
    |> reduce({__MODULE__, :register_from, []})

  program =
    ignore(string("Program: "))
    |> integer(min: 1)
    |> repeat(choice([ignore(string(",")), integer(min: 1)]))
    |> reduce({__MODULE__, :program_from, []})

  defparsec(
    :parse,
    repeat(
      choice([
        reg,
        whitespace,
        program,
        anything
      ])
    )
  )

  def combo(0, _regs), do: 0
  def combo(1, _regs), do: 1
  def combo(2, _regs), do: 2
  def combo(3, _regs), do: 3
  def combo(4, regs), do: regs[65]
  def combo(5, regs), do: regs[66]
  def combo(6, regs), do: regs[67]

  def process([], _regs, out, _orig), do: out |> Enum.reverse() |> Enum.join(",")
  def process([_], _regs, out, _orig), do: out |> Enum.reverse() |> Enum.join(",")

  def process([0, val | rest], regs, out, orig) do
    IO.inspect({regs[65], val, div(regs[65], 2 ** combo(val, regs)), regs}, label: "Set A")
    process(rest, %{regs | 65 => div(regs[65], 2 ** combo(val, regs))}, out, orig)
  end

  def process([1, val | rest], regs, out, orig),
    do: process(rest, %{regs | 66 => Bitwise.bxor(regs[66], val)}, out, orig)

  def process([2, val | rest], regs, out, orig),
    do: process(rest, %{regs | 66 => rem(combo(val, regs), 8)}, out, orig)

  def process([3, val | rest], regs, out, orig) do
    IO.inspect({val, Enum.at(orig, val), regs, out}, label: "Jump")
    case regs[65] do
      0 -> process(rest, regs, out, orig)
      a -> process(Enum.slice(orig, val, length(orig)), regs, out, orig)
    end
  end

  def process([4, val | rest], regs, out, orig),
    do: process(rest, %{regs | 66 => Bitwise.bxor(regs[66], regs[67])}, out, orig)

  def process([5, val | rest], regs, out, orig) do
    IO.inspect({val, rem(combo(val, regs), 8), out, regs})
    process(rest, regs, [rem(combo(val, regs), 8) | out], orig)
  end

  def process([6, val | rest], regs, out, orig),
    do: process(rest, %{regs | 66 => div(regs[65], 2 ** combo(val, regs))}, out, orig)

  def process([7, val | rest], regs, out, orig),
    do: process(rest, %{regs | 67 => div(regs[65], 2 ** combo(val, regs))}, out, orig)

  def part1({:ok, results, _, _, _, _}) do
    [regs, rest] = results
    process(rest, regs, [], rest)
  end
end

test_file =
  File.read!("test.txt")
  |> Solver.parse()

file =
  File.read!("input.txt")
  |> Solver.parse()

IO.inspect(Solver.part1(test_file), label: "Part 1 Test")
IO.inspect(Solver.part1(file), label: "Part 1 Real")
# IO.inspect(Solver.part2(test_file), label: "Part 2 Test")
# IO.inspect(Solver.part2(file), label: "Part 2 Real")
