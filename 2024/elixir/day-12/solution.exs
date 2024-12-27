defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2024/day/12
  """

  @dirs [:n, :s, :e, :w]

  def update(path, keys, value), do: put_in(path, Enum.map(keys, &Access.key(&1, %{})), value)

  def parse(input) do
    data =
      input
      |> Enum.map(fn line ->
        line
        |> String.trim()
        |> String.graphemes()
        |> Enum.map(&String.downcase/1)
        |> Enum.map(&String.to_atom/1)
      end)

    data_tuple = data |> Enum.map(&List.to_tuple/1) |> List.to_tuple()

    data =
      data
      |> Enum.with_index()
      |> Enum.reduce([], fn {line, row}, acc ->
        line
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {char, col}, inner_acc ->
          coord = [row, col]

          [{char, coord} | inner_acc]
        end)
      end)

    {data_tuple, data}
  end

  def get_in_tuple(tuple, []) do
    tuple
  end

  def get_in_tuple(tuple, [index | rest])
      when is_tuple(tuple) and tuple_size(tuple) - 1 >= index and index >= 0 do
    elem(tuple, index) |> get_in_tuple(rest)
  end

  def get_in_tuple(_tuple, index), do: {:index_error, index}

  def shift(coord, offset), do: Enum.zip(coord, offset) |> Enum.map(fn {a, b} -> a + b end)

  def move(:s, coord), do: shift(coord, [1, 0])
  def move(:n, coord), do: shift(coord, [-1, 0])
  def move(:e, coord), do: shift(coord, [0, 1])
  def move(:w, coord), do: shift(coord, [0, -1])
  def move(_, coord), do: coord

  def count(_data, [], fill), do: fill.edges

  def count(data, [{value, index} | rest], fill) do
    edges =
      @dirs
      |> Enum.map(fn dir ->
        next = move(dir, index)
        new_value = get_in_tuple(data, next)

        cond do
          new_value == value ->
            if next in fill.plots do
              nil
            else
              {new_value, next}
            end

          true ->
            nil
        end
      end)
      |> Enum.reject(&(!&1))

    fill = update(fill, [:plots, index], true)
    fill = update_in(fill[:edges], &(&1 + (4 - length(edges))))

    count(data, rest, fill)
  end

  def part1({data, rest}) do
    count(data, rest, %{edges: 0, plots: %{}})
  end

  def part2(path) do
    path
  end
end

test_file =
  File.read!("test.txt")
  |> String.split(~r/\s+/, trim: true)

file =
  File.read!("input.txt")
  |> String.split(~r/\s+/, trim: true)

# IO.inspect(test_file |> Solver.parse(), label: "Part 1 Test")
IO.inspect(test_file |> Solver.parse() |> Solver.part1(), label: "Part 1 Test")
