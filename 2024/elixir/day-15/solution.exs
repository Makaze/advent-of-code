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

  def shove(data, start, dir, []), do: shove(data, start, dir, [{:robot, start}])

  def shove(data, start, dir, queue) do
    coord =
      case queue do
        [] -> start
        [{last_type, last_coord} | _] -> last_coord
      end

    next = move(dir, coord)
    next_type = data[next]

    data =
      case next_type do
        :box ->
          shove(data, start, dir, [{:box, next} | queue])

        nil ->
          data = put_in(data[start], nil)

          queue
          |> Enum.reduce(data, fn {el, pos}, acc ->
            new_pos = move(dir, pos)

            acc =
              if el == :robot do
                put_in(acc[:robot], new_pos)
              else
                acc
              end

            put_in(acc[new_pos], el)
          end)

        :wall ->
          data
      end
  end

  defp print(data, {h, w}) do
    p =
      for y <- 0..(h - 1) do
        for x <- 0..(w - 1) do
          case data[[y, x]] do
            :wall -> "#"
            nil -> "."
            :box -> "O"
            :robot -> "@"
          end
        end
        |> Enum.join("")
      end
      |> Enum.join("\n")

    IO.puts(p)
  end

  def part1({:ok, [{data, move_list}], _, _, _, _}) do
    end_map =
      move_list
      |> Enum.reduce(data, fn dir, acc ->
        shove(acc, acc.robot, dir, [])
      end)

    end_map |> print({10, 10})

    end_map
    |> Enum.map(fn
      {[y, x], :box} -> y * 100 + x
      _ -> 0
    end)
    |> Enum.sum()
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
IO.inspect(file |> Solver.parse() |> Solver.part1(), label: "Part 1 Real")
