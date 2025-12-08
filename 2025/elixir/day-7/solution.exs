Mix.install([
  {:nimble_parsec, "~> 1.4"}
])

defmodule BeamStore do
  def init(table \\ nil) do
    :ets.new(:"beam_#{table}_store", [:named_table, :public, :set])
    :ets.new(:"meta_#{table}_store", [:named_table, :public, :set])
    :ets.insert(:"meta_#{table}_store", {:coord, {0, 0}})
    :ets.insert(:"meta_#{table}_store", {:splits, 0})
  end

  def new_row(table) do
    {_x, y} = BeamStore.get_data(table, :coord)
    :ets.insert(:"meta_#{table}_store", {:coord, {0, y + 1}})
  end

  def insert(table, nil) do
    {x, y} = BeamStore.get_data(table, :coord)
    :ets.insert(:"meta_#{table}_store", {:coord, {x + 1, y}})
  end

  def insert(table, :start) do
    {x, y} = BeamStore.get_data(table, :coord)
    :ets.insert(:"meta_#{table}_store", {:coord, {x + 1, y}})
    :ets.insert(:"beam_#{table}_store", {x, y + 1})
  end

  def insert(table, :splitter) do
    {x, y} = BeamStore.get_data(table, :coord)

    if is_beam?(table, x) do
      splits = BeamStore.get_data(table, :splits)
      :ets.delete(:"beam_#{table}_store", x)
      :ets.insert(:"beam_#{table}_store", {x - 1, y})
      :ets.insert(:"beam_#{table}_store", {x + 1, y})
      :ets.insert(:"meta_#{table}_store", {:splits, splits + 1})
    end

    :ets.insert(:"meta_#{table}_store", {:coord, {x + 1, y}})
  end

  def is_beam?(table, x) do
    case :ets.lookup(:"beam_#{table}_store", x) do
      [{^x, _y}] -> true
      [] -> false
    end
  end

  def get_data(table, key) do
    [{^key, v}] = :ets.lookup(:"meta_#{table}_store", key)
    v
  end

  def size(table), do: :ets.info(:"beam_#{table}_store", :size)
end

defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2025/day/7
  """

  import NimbleParsec

  BeamStore.init("real")

  def row_from(x) do
    x
    |> Enum.map(fn
      char -> BeamStore.insert("real", char)
    end)

    BeamStore.new_row("real")
    x
  end

  anything = ignore(utf8_char([]))

  row =
    repeat(
      choice([
        string(".") |> replace(nil),
        string("S") |> replace(:start),
        string("^") |> replace(:splitter)
      ])
    )
    |> ignore(anything)
    |> reduce({__MODULE__, :row_from, []})

  defparsec(
    :parse,
    repeat(
      choice([
        row,
        anything
      ])
    )
  )

  def part1({:ok, ranges, _, _, _, _}) do
    x = BeamStore.get_data("real", :splits)
    y = :ets.info(:beam_real_store, :size)
    :ets.delete(:beam_real_store)
    :ets.delete(:meta_real_store)
    BeamStore.init("real")
    {x, y}
  end

  def part2({:ok, ranges, _, _, _, _}) do
  end
end

test_file =
  File.read!("test.txt")

file =
  File.read!("input.txt")

IO.inspect(test_file |> Solver.parse() |> Solver.part1(), label: "Part 1 Test")
IO.inspect(file |> Solver.parse() |> Solver.part1(), label: "Part 1 Real")
#
# IO.inspect(test_file |> Solver.parse2() |> Solver.part2(), label: "Part 2 Test")
# IO.inspect(file |> Solver.parse2() |> Solver.part2(), label: "Part 2 Real")
