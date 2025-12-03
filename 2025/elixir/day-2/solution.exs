Mix.install([
  {:nimble_parsec, "~> 1.4"}
])

defmodule MaxStore do
  def init(val \\ nil) do
    :ets.new(:max_store, [:named_table, :public, :set])
    :ets.insert(:max_store, {:max, val})
  end

  def update(val) do
    [{:max, current}] = :ets.lookup(:max_store, :max)

    new =
      cond do
        current == nil -> val
        val > current -> val
        true -> current
      end

    :ets.insert(:max_store, {:max, new})
  end

  def get do
    case :ets.lookup(:max_store, :max) do
      [{:max, v}] -> v
      _ -> nil
    end
  end
end

defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2025/day/2
  """

  import NimbleParsec

  MaxStore.init()

  def range_from([lower, upper | _rest]) do
    size_upper = size_int(upper)

    MaxStore.update(size_upper)

    {lower, upper}
  end

  anything = ignore(utf8_char([]))

  range =
    integer(min: 1)
    |> ignore(string("-"))
    |> integer(min: 1)
    |> reduce({__MODULE__, :range_from, []})

  defparsec(
    :parse,
    repeat(
      choice([
        range,
        anything
      ])
    )
  )

  def size_int(x), do: :math.log10(x) |> floor() |> Kernel.+(1) |> trunc()

  def concat_int(a, b) do
    res = a * 10 ** trunc(:math.log10(b) + 1) + b
    res
  end

  def gen_reps(n, reps) do
    v =
      1..reps
      |> Enum.reduce(n, fn _i, acc ->
        concat_int(acc, n)
      end)

    v
  end

  def find_range(_rep, []), do: 0
  def find_range(rep, [{lower, upper} | _rest]) when rep >= lower and rep <= upper, do: rep
  def find_range(rep, [_range | rest]), do: find_range(rep, rest)

  def part1({:ok, ranges, _, _, _, _}) do
    1..(10 ** (div(MaxStore.get(), 2) + 1) - 1)
    |> Enum.map(fn n ->
      concat_int(n, n)
      |> find_range(ranges)
    end)
    |> Enum.sum()
  end

  def part2({:ok, ranges, _, _, _, _}) do
    1..(10 ** (div(MaxStore.get(), 2) + 1) - 1)
    |> Enum.map(fn n ->
      size_n = size_int(n)
      max_reps = div(MaxStore.get(), size_n)

      1..max_reps
      |> Enum.map(fn r ->
        gen_reps(n, r)
        |> find_range(ranges)
      end)
    end)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.sum()
  end
end

test_file =
  File.read!("test.txt")

file =
  File.read!("input.txt")

IO.inspect(test_file |> Solver.parse() |> Solver.part1(), label: "Part 1 Test")
IO.inspect(file |> Solver.parse() |> Solver.part1(), label: "Part 1 Real")

IO.inspect(test_file |> Solver.parse() |> Solver.part2(), label: "Part 2 Test")
IO.inspect(file |> Solver.parse() |> Solver.part2(), label: "Part 2 Real")
