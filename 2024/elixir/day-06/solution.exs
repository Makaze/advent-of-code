defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2024/day/4
  """

  @dirs [:n, :s, :e, :w]
  @dir_map %{"^" => :n, "v" => :s, ">" => :e, "<" => :w}

  def parse(input) do
    data = %{
      jumps: %{},
      row_history: %{},
      col_history: %{},
      origin: nil,
      height: Enum.count(input),
      width: Enum.count(input[0])
    }

    input
    |> Enum.with_index()
    |> Enum.reduce(data, fn {line, row}, acc ->
      line
      |> String.trim()
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn
        {"#", col}, acc ->
          coord = [row, col]

          jumps = %{
            n: get_in(acc[:col_history][col]),
            s: nil,
            e: nil,
            w: get_in(acc[:row_history][row]),
            dir: nil
          }

          # Update jumps from obstacles to the north and west
          acc = put_in(acc[:jumps][jumps[:n]][:s], coord)
          acc = put_in(acc[:jumps][jumps[:w]][:e], coord)

          acc = put_in(acc[:jumps][coord], jumps)

          # Update last in this col and row
          acc = put_in(acc[:row_history][row], coord)
          acc = put_in(acc[:col_history][col], coord)

        {dir, col}, acc when dir in ["^", "v", "<", ">"] ->
          coord = [row, col]

          dir = @dir_map[dir]

          jumps = %{
            n: get_in(acc[:col_history][col]),
            s: nil,
            e: nil,
            w: get_in(acc[:row_history][row]),
            dir: dir
          }

          acc = put_in(acc[:jumps][coord][dir], jumps[dir])
          put_in(acc[:origin], %{coord: coord, dir: dir})

        _, _ ->
          acc
      end)
    end)
  end

  def patrol(data, last \\ nil, distance \\ 0)

  def patrol(data, nil, 0) do
    patrol(data, data[:origin], 0)
  end

  def patrol(data, last, distance) do
    next = get_in(data[:jumps][last[:coord]])

    case next do
      nil ->
        to_edge =
          case last[:dir] do
            :n -> get_in(last[:coord][1])
            :s -> get_in(data[:height] - last[:coord][1])
            :e -> get_in(last[:coord][0])
            :w -> get_in(data[:width] - last[:coord][0])
          end

        distance + to_edge

      jump ->
        jump
    end
  end

  def patrol(data, dir, distance) do
  end

  def count_from(data, x) do
    @dirs |> Enum.map(fn dir -> count(dir, data, x, [:x]) end) |> Enum.sum()
  end

  def part1({_data, map}) do
    Map.get(map, :x)
    |> Enum.sum()
  end

  def part2({_data, map}) do
    Map.get(map, :a)
    |> Enum.sum()
  end
end

test_file =
  File.read!("test.txt")
  |> String.split(~r/\s+/, trim: true)
  |> Solver.parse()

file =
  File.read!("input.txt")
  |> String.split(~r/\s+/, trim: true)
  |> Solver.parse()

IO.inspect(Solver.part1(test_file), label: "Part 1 Test")
IO.inspect(Solver.part1(file), label: "Part 1 Real")
IO.inspect(Solver.part2(test_file), label: "Part 2 Test")
IO.inspect(Solver.part2(file), label: "Part 2 Real")
