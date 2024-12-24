Mix.install([
  {:nimble_parsec, "~> 1.4"}
])

defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2024/day/17
  """

  import NimbleParsec

  def edge_from(nodes), do: nodes |> Enum.map(&String.to_atom/1) |> List.to_tuple()

  anything = ignore(utf8_char([]))

  edge =
    ascii_string([?a..?z, ?A..?Z], min: 2)
    |> ignore(string("-"))
    |> ascii_string([?a..?z, ?A..?Z], min: 2)
    |> reduce({__MODULE__, :edge_from, []})

  defparsec(
    :parse,
    repeat(
      choice([
        edge,
        anything
      ])
    )
  )

  def update(path, keys, value), do: put_in(path, Enum.map(keys, &Access.key(&1, %{})), value)

  def map({:ok, edges, _, _, _, _}) do
    data = %{nodes: %{}, edges: %{}, t: %{}}

    edges
    |> Enum.reduce(data, fn edge, acc ->
      {a, b} = edge
      reverse = {b, a}
      acc = if Atom.to_string(a) |> String.starts_with?("t") do
        update(acc, [:t, a], true)
      else
        acc
      end
      acc = if Atom.to_string(b) |> String.starts_with?("t") do
        update(acc, [:t, b], true)
      else
        acc
      end
      acc = update(acc, [:nodes, a, b], true)
      acc = update(acc, [:nodes, b, a], true)
      acc = put_in(acc[:edges][edge], true)
      put_in(acc[:edges][reverse], true)
    end)
  end

  def pairs(data, t) do
    keys = Map.keys(data.nodes[t])
    for b <- keys, c <- keys, b < c do
      if edge?(data, {b, c}) do
        %{t => true, b => true, c => true}
      else
        nil
      end
    end
  end

  def edge?(data, edge), do: get_in(data[:edges][edge])

  def part1(map) do
    map.t
    |> Map.keys()
    |> Enum.map(fn t -> Task.async(fn -> pairs(map, t) end) end)
    |> Enum.map(fn task -> Task.await(task) end)
    |> List.flatten()
    |> Enum.reject(& !&1)
    |> Enum.uniq()
    |> Enum.count()
  end
end

test_file =
  File.read!("test.txt")
  |> Solver.parse()
  |> Solver.map()

file =
  File.read!("input.txt")
  |> Solver.parse()
  |> Solver.map()

IO.inspect(test_file |> Solver.part1(), label: "Part 1 Test")
IO.inspect(file |> Solver.part1(), label: "Part 1 Real")
# IO.inspect(test_file |> Solver.part2(), label: "Part 2 Test")
# IO.inspect(file |> Solver.part2(), label: "Part 2 Real")
