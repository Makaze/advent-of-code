Mix.install([
  {:nimble_parsec, "~> 1.4"}
])

defmodule RangeStore do
  def init(table \\ nil) do
    :ets.new(:"range_#{table}_store", [:named_table, :public, :ordered_set])
    :ets.new(:"total_#{table}_store", [:named_table, :public, :set])
    :ets.insert(:"total_#{table}_store", {:total, 0})
  end

  def insert(table, {s, e} = r) do
    dif = e - s + 1
    old = RangeStore.get_total(table)
    :ets.insert(:"range_#{table}_store", r)
    :ets.insert(:"total_#{table}_store", {:total, old + dif})
  end

  def in_any?(table, x) do
    case :ets.prev(:"range_#{table}_store", x + 1) do
      :"$end_of_table" ->
        false

      start ->
        [{^start, finish}] = :ets.lookup(:"range_#{table}_store", start)
        x <= finish
    end
  end

  def get_total(table) do
    [{:total, v}] = :ets.lookup(:"total_#{table}_store", :total)
    v
  end
end

defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2025/day/5
  """

  import NimbleParsec

  def range_from([lower, upper | _rest]) do
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
        integer(min: 1),
        anything
      ])
    )
  )

  def reduce_range(r, []), do: [r]

  def reduce_range({r_start, r_end}, [{prev_start, prev_end} | rest])
      when r_start <= prev_end + 1 do
    [{prev_start, max(prev_end, r_end)} | rest]
  end

  def reduce_range(r, rest), do: [r | rest]

  RangeStore.init("test")
  RangeStore.init("real")

  def part1({:ok, ranges, _, _, _, _}, table) do
    {ranges, ints} =
      ranges
      |> Enum.split_with(fn
        {_a, _b} -> true
        _ -> false
      end)

    ranges
    |> Enum.sort()
    |> Enum.reduce([], &reduce_range/2)
    |> Enum.each(fn x -> RangeStore.insert(table, x) end)

    ints
    |> Enum.map(fn x ->
      if RangeStore.in_any?(table, x) do
        1
      else
        0
      end
    end)
    |> Enum.sum()
  end

  def part2(table) do
    RangeStore.get_total(table)
  end
end

test_file =
  File.read!("test.txt")

file =
  File.read!("input.txt")

IO.inspect(test_file |> Solver.parse() |> Solver.part1("test"), label: "Part 1 Test")
IO.inspect(file |> Solver.parse() |> Solver.part1("real"), label: "Part 1 Real")

IO.inspect(Solver.part2("test"), label: "Part 2 Test")
IO.inspect(Solver.part2("real"), label: "Part 2 Real")
