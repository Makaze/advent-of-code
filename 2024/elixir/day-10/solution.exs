defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2024/day/10
  """

  @dirs [:n, :s, :e, :w]

  def parse(input, filter) do
    data =
      input
      |> Enum.map(fn line ->
        line
        |> String.trim()
        |> String.graphemes()
        |> Enum.map(&String.to_integer/1)
      end)

    data_tuple = data |> Enum.map(&List.to_tuple/1) |> List.to_tuple()

    data
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, row}, acc ->
      line
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {char, col}, inner_acc ->
        coord = [row, col]

        case char do
          0 ->
            c =
              count(data_tuple, coord, 0, [{{row, col}, 0}], filter)
              |> List.flatten()
              |> Enum.reject(&(!&1))

            Enum.reduce(c, inner_acc, fn
              false, deep_acc ->
                deep_acc

              x, deep_acc ->
                Map.put(deep_acc, x, true)
            end)

          _ ->
            inner_acc
        end
      end)
    end)
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

  def count(_data, _coord, 9 = _value, [last | rest] = walk, filter) do
    %{end: {rest |> Enum.reverse() |> hd(), last}, path: List.to_tuple(walk)}
    |> filter.()
  end

  def count(data, coord, value, walk, filter) do
    @dirs
    |> Enum.map(fn dir ->
      next = move(dir, coord)
      new_value = get_in_tuple(data, next)

      cond do
        new_value != value + 1 or {List.to_tuple(next), new_value} in walk -> false
        true -> count(data, next, new_value, [{List.to_tuple(next), new_value} | walk], filter)
      end
    end)
  end

  def part1(path) do
    path.end
  end

  def part2(path) do
    path.path
  end
end

test_file =
  File.read!("test.txt")
  |> String.split(~r/\s+/, trim: true)

file =
  File.read!("input.txt")
  |> String.split(~r/\s+/, trim: true)

IO.inspect(test_file |> Solver.parse(&Solver.part1/1) |> Enum.count(), label: "Part 1 Test")
IO.inspect(file |> Solver.parse(&Solver.part1/1) |> Enum.count(), label: "Part 1 Real")
IO.inspect(test_file |> Solver.parse(&Solver.part2/1) |> Enum.count(), label: "Part 2 Test")
IO.inspect(file |> Solver.parse(&Solver.part2/1) |> Enum.count(), label: "Part 2 Real")
