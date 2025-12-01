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
      "S" -> :start
      "E" -> :end
    end)
  end

  def map_from(data) do
    data = data |> Enum.with_index() |> Enum.reverse()

    data =
      data
      |> Enum.reduce(%{}, fn {line, row}, acc ->
        line
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {char, col}, inner_acc ->
          coord = [row, col]

          inner_acc =
            case char do
              :start -> put_in(inner_acc[:start], coord)
              :end -> put_in(inner_acc[:end], coord)
              _ -> inner_acc
            end

          put_in(inner_acc[coord], char)
        end)
      end)

    data
  end

  anything = ignore(utf8_char([]))
  whitespace = ignore(utf8_char([?\n, ?\r]))
  wall = string("#")
  start = string("S")
  target = string("E")
  empty = string(".")

  grid_row =
    choice([empty, wall, target, start])
    |> repeat(choice([empty, wall, target, start]))
    |> reduce({__MODULE__, :row_from, []})

  defparsec(
    :parse,
    repeat(
      choice([
        grid_row,
        whitespace
      ])
    )
    |> reduce({__MODULE__, :map_from, []})
  )

  def bfs(graph, start) do
    queue = :queue.new() |> :queue.in({start, [start]})
    visited = %{}

    bfs_step(graph, queue, visited)
  end

  defp bfs_step(_graph, queue, _visited) when :queue.is_empty(queue), do: :done

  defp bfs_step(graph, queue, visited) do
    {{:value, {node, path}}, queue} = :queue.out(queue)

    if Map.has_key?(visited, node) do
      bfs_step(graph, queue, visited)
    else
      neighbors = get_neighbors(graph, node)
    end
  end

  def part1({:ok, [data], _, _, _, _}) do
    nil
  end
end

test_file =
  File.read!("test.txt")

file =
  File.read!("input.txt")

IO.inspect(test_file |> Solver.parse() |> Solver.part1(), label: "Part 1 Test")
IO.inspect(file |> Solver.parse() |> Solver.part1(), label: "Part 1 Real")
