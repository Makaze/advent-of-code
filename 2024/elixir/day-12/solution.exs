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
      |> Enum.reduce(%{plots: %{}, seen: %{}, plot: 0}, fn {char, coord}, %{plot: plot} = acc ->
        case get_in(acc[:seen][coord]) do
          nil ->
            %{members: members, char: ^char} =
              result =
              fill(data_tuple, [{char, coord}], %{edges: 0, char: char, members: [], corners: []})

            acc =
              members
              |> Enum.reduce(acc, fn k, deep_acc ->
                update(deep_acc, [:seen, k], true)
              end)

            acc = update(acc, [:plots, plot], result)
            update_in(acc[:plot], &(&1 + 1))

          _ ->
            acc
        end
      end)

    data
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
  def move(:nw, coord), do: shift(coord, [-1, -1])
  def move(:sw, coord), do: shift(coord, [1, -1])
  def move(:ne, coord), do: shift(coord, [-1, 1])
  def move(:se, coord), do: shift(coord, [1, 1])
  def move(_, coord), do: coord

  def fill(_data, [], plot), do: plot

  def fill(data, [{value, index} | rest], plot) do
    cond do
      index not in plot.members ->
        edges =
          @dirs
          |> Enum.map(fn dir ->
            next = move(dir, index)
            new_value = get_in_tuple(data, next)

            cond do
              new_value == value ->
                if next in plot.members do
                  true
                else
                  {new_value, next}
                end

              true ->
                {nil, dir}
            end
          end)

        plot = update_in(plot[:members], &([index | &1] |> Enum.uniq()))

        plot =
          update_in(plot[:edges], fn x ->
            x + (4 - length(edges |> Enum.reject(&(is_tuple(&1) and elem(&1, 0) == nil))))
          end)

        diagonals =
          %{
            ne: move(:ne, index),
            nw: move(:nw, index),
            se: move(:se, index),
            sw: move(:sw, index)
          }
          |> Enum.map(fn {k, v} ->
            case get_in_tuple(data, v) do
              ^value ->
                {v, k}

              _other ->
                {nil, k}
            end
          end)

        corners =
          %{
            ne:
              [{nil, :n}, {nil, :e}] |> Enum.all?(&(&1 in edges)) or
                (not ([{nil, :n}, {nil, :e}] |> Enum.any?(&(&1 in edges))) and
                   {nil, :ne} in diagonals),
            nw:
              [{nil, :n}, {nil, :w}] |> Enum.all?(&(&1 in edges)) or
                (not ([{nil, :n}, {nil, :w}] |> Enum.any?(&(&1 in edges))) and
                   {nil, :nw} in diagonals),
            se:
              [{nil, :s}, {nil, :e}] |> Enum.all?(&(&1 in edges)) or
                (not ([{nil, :s}, {nil, :e}] |> Enum.any?(&(&1 in edges))) and
                   {nil, :se} in diagonals),
            sw:
              [{nil, :s}, {nil, :w}] |> Enum.all?(&(&1 in edges)) or
                (not ([{nil, :s}, {nil, :w}] |> Enum.any?(&(&1 in edges))) and
                   {nil, :sw} in diagonals)
          }
          |> Enum.map(fn
            {:ne, true} -> move(:e, index)
            {:nw, true} -> index
            {:se, true} -> move(:se, index)
            {:sw, true} -> move(:s, index)
            _ -> false
          end)
          |> Enum.reject(&(!&1))

        plot =
          corners
          |> Enum.reduce(plot, fn corner, c_acc ->
            update_in(c_acc[:corners], &[corner | &1])
          end)

        fill(
          data,
          (edges |> Enum.reject(&((is_tuple(&1) and elem(&1, 0) == nil) or &1 == true))) ++ rest,
          plot
        )

      true ->
        fill(data, rest, plot)
    end
  end

  def part1(rest) do
    rest.plots
    |> Enum.map(fn {_k, v} -> length(v.members) * v.edges end)
    |> Enum.sum()
  end

  def part2(rest) do
    rest.plots
    |> Enum.map(fn {_k, v} -> length(v.members) * (v.corners |> Enum.count()) end)
    |> Enum.sum()
  end
end

test_file =
  File.read!("test2.txt")
  |> String.split(~r/\s+/, trim: true)

file =
  File.read!("input.txt")
  |> String.split(~r/\s+/, trim: true)

IO.inspect(test_file |> Solver.parse() |> Solver.part1(), label: "Part 1 Test")
IO.inspect(file |> Solver.parse() |> Solver.part1(), label: "Part 1 Real")
IO.inspect(test_file |> Solver.parse() |> Solver.part2(), label: "Part 2 Test")
IO.inspect(file |> Solver.parse() |> Solver.part2(), label: "Part 2 Real")
