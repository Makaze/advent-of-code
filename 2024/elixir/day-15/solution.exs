Mix.install([
  {:nimble_parsec, "~> 1.4"}
])

defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2024/day/15
  """

  import NimbleParsec

  def row_from(chars) do
    chars
    |> Enum.map(fn
      "#" -> :wall
      "." -> nil
      "O" -> :box
      "@" -> :robot
    end)
  end

  def moves_from(chars) do
    chars
    |> Enum.map(fn
      "^" -> :n
      "v" -> :s
      "<" -> :w
      ">" -> :e
    end)
  end

  def map_from(data) do
    [{moves, _} | data] = data |> Enum.with_index() |> Enum.reverse()

    data =
      data
      |> Enum.reduce(%{}, fn {line, row}, acc ->
        line
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {char, col}, inner_acc ->
          coord = [row, col]

          inner_acc =
            case char do
              :robot -> put_in(inner_acc[:robot], coord)
              _ -> inner_acc
            end

          put_in(inner_acc[coord], char)
        end)
      end)

    {data, moves}
  end

  anything = ignore(utf8_char([]))
  whitespace = ignore(utf8_char([?\n, ?\r]))
  wall = string("#")
  box = string("O")
  robot = string("@")
  empty = string(".")

  grid_row =
    choice([empty, wall, box, robot])
    |> repeat(choice([empty, wall, box, robot]))
    |> reduce({__MODULE__, :row_from, []})

  moves =
    choice([string("^"), string("v"), string("<"), string(">")])
    |> repeat(choice([string("^"), string("v"), string("<"), string(">"), whitespace]))
    |> reduce({__MODULE__, :moves_from, []})

  defparsec(
    :parse,
    repeat(
      choice([
        grid_row,
        whitespace,
        moves
      ])
    )
    |> reduce({__MODULE__, :map_from, []})
  )


  def shift(coord, offset), do: Enum.zip(coord, offset) |> Enum.map(fn {a, b} -> a + b end)

  def move(:s, coord), do: shift(coord, [1, 0])
  def move(:n, coord), do: shift(coord, [-1, 0])
  def move(:e, coord), do: shift(coord, [0, 1])
  def move(:w, coord), do: shift(coord, [0, -1])
  def move(_, coord), do: coord

  def shove(%{robot: {row, col}} = data, [dir | rest]) do
    next = move(dir, [row, col])
    next_type = data[next]
  end

  def part1({:ok, results, _, _, _, _}) do
    results
  end

  def part2({:ok, results, _, _, _, _}) do
    nil
  end
end

test_file =
  File.read!("test.txt")

file =
  File.read!("input.txt")

IO.inspect(test_file |> Solver.parse() |> Solver.part1(), label: "Part 1 Test")
