Mix.install([
  {:nimble_parsec, "~> 1.4"},
  {:nx, "~> 0.10"}
])

defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2025/day/3
  """

  import NimbleParsec

  whitespace = utf8_char([?\s, ?\n, ?\t, ?\r])

  chars =
    choice([
      string(".") |> replace(0),
      string("@") |> replace(1)
    ])

  def char_from(x) do
    x
  end

  row =
    repeat(chars)
    |> ignore(whitespace)
    |> reduce({__MODULE__, :char_from, []})

  defparsec(
    :parse,
    repeat(
      choice([
        row,
        whitespace
      ])
    )
  )

  import Nx.Defn

  defn filter(tensor, opts \\ []) do
    opts = keyword!(opts, radius: 1)
    k = 2 * opts[:radius] + 1

    kernel = Nx.broadcast(1.0, {1, 1, k, k})

    tensor
    |> Nx.new_axis(0)
    |> Nx.new_axis(0)
    |> Nx.conv(kernel, padding: :same)
    |> Nx.squeeze()
  end

  def next_remove(state) do
    summed = state |> filter(radius: 1)

    Nx.logical_and(Nx.greater(state, 0), Nx.less(summed, 5)) |> Nx.select(-1, 0)
  end

  def remove_rolls(original, last_sum \\ 1, total \\ 0)
  def remove_rolls(_, 0, total), do: total

  def remove_rolls(original, _last_sum, total) do
    nr = next_remove(original)
    nr_sum = nr |> Nx.sum() |> Nx.to_number() |> abs
    remove_rolls(Nx.add(original, nr), nr_sum, total + nr_sum)
  end

  def part1({:ok, rows, _, _, _, _}) do
    original = Nx.tensor(rows)

    summed = original |> filter(radius: 1)

    Nx.logical_and(Nx.greater(original, 0), Nx.less(summed, 5))
    |> Nx.select(1, 0)
    |> Nx.sum()
    |> Nx.to_number()
  end

  def part2({:ok, rows, _, _, _, _}) do
    Nx.tensor(rows) |> remove_rolls()
  end
end

test_file =
  File.read!("test.txt")

file =
  File.read!("input.txt")

IO.inspect(test_file |> Solver.parse() |> Solver.part1(), label: "Part 1 Test", limit: :infinity)
IO.inspect(file |> Solver.parse() |> Solver.part1(), label: "Part 1 Real")

IO.inspect(test_file |> Solver.parse() |> Solver.part2(), label: "Part 2 Test")
IO.inspect(file |> Solver.parse() |> Solver.part2(), label: "Part 2 Real")
