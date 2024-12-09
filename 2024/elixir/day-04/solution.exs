defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2024/day/3
  """

  def parse(input) do
    data =
      input
      |> Enum.map(fn line ->
        line
        |> String.trim()
        |> String.graphemes()
        |> Enum.map(fn
          "X" -> :x
          "M" -> :m
          "A" -> :a
          "S" -> :s
        end)
      end)

    map =
      data
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {line, row}, acc ->
        line
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {char, col}, map ->
          coord = [row, col]

          case char do
            :x -> Map.update(map, :x, :queue.in(coord, :queue.new()), &:queue.in(coord, &1))
            _ -> map
          end
        end)
      end)

    data = data |> Enum.map(&List.to_tuple/1) |> List.to_tuple()

    {data, map}
  end

  def get_in_tuple(tuple, []) do
    tuple
  end

  def get_in_tuple(tuple, [index | rest])
      when is_tuple(tuple) and tuple_size(tuple) - 1 >= index do
    elem(tuple, index) |> get_in_tuple(rest)
  end

  def get_in_tuple(tuple, index) do
    {:index_error, tuple, index}
  end

  def get_next(map, key) do
    q = Map.fetch!(map, key)

    case :queue.out(q) do
      {{:value, coord}, new_q} -> {coord, Map.put(map, key, new_q)}
      {:empty, _} -> {:error, :empty}
    end
  end

  def shift(coord, offset), do: Enum.zip(coord, offset) |> Enum.map(fn {a, b} -> a + b end)

  def move(:s, coord), do: shift(coord, [1, 0])
  def move(:n, coord), do: shift(coord, [-1, 0])
  def move(:e, coord), do: shift(coord, [0, 1])
  def move(:w, coord), do: shift(coord, [0, -1])
  def move(:ne, coord), do: shift(coord, [-1, 1])
  def move(:nw, coord), do: shift(coord, [-1, -1])
  def move(:se, coord), do: shift(coord, [1, 1])
  def move(:sw, coord), do: shift(coord, [1, -1])
  def move(_, coord), do: coord

  def count(_dir, _data, _coord, [:s, :a, :m, :x]), do: 1

  def count(dir, data, coord, [:a, :m, :x] = walk) do
    next = move(dir, coord)
    count(dir, data, next, [get_in_tuple(data, next) | walk])
  end

  def count(dir, data, coord, [:m, :x] = walk) do
    next = move(dir, coord)
    count(dir, data, next, [get_in_tuple(data, next) | walk])
  end

  def count(dir, data, coord, [:x] = walk) do
    next = move(dir, coord)
    count(dir, data, next, [get_in_tuple(data, next) | walk])
  end

  def count(_, _, _, _), do: 0

  def sum({:ok, results, _, _, _, _}) do
    Enum.sum(results)
  end
end

file =
  File.read!("test.txt")
  |> String.split(~r/\s+/, trim: true)

{data, parsed} =
  file
  |> Solver.parse()

IO.inspect({data, parsed}, label: "Parsed")
{first, parsed} = parsed |> Solver.get_next(:x)
{second, parsed} = parsed |> Solver.get_next(:x)
IO.inspect(first, label: "First X")
IO.inspect(second, label: "Second X")
IO.inspect(Solver.get_in_tuple(data, Solver.move(:s, second)), label: "Second X below")
IO.inspect(Solver.count(:s, data, first, [:x]), label: "Second X below")
IO.inspect(Solver.count(:se, data, first, [:x]), label: "Second X below")
IO.inspect(Solver.count(:sw, data, first, [:x]), label: "Second X below")

# File.read!("input.txt")

# part1 = file |> Solver.part1() |> Solver.sum()
# part2 = file |> Solver.part2() |> Solver.sum()
#
# IO.inspect(part1, label: "Part 1")
# IO.inspect(part2, label: "Part 2")
