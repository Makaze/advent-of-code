defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2024/day/8
  """

  def parse(input) do
    data = %{
      height: Enum.count(input),
      width: Enum.count(String.graphemes(Enum.at(input, 0))),
      chars: %{},
      antinodes: %{}
    }

    input
    |> Enum.with_index()
    |> Enum.reduce(data, fn {line, row}, acc ->
      line
      |> String.trim()
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn
        {".", _}, new_acc ->
          new_acc

        {char, col}, new_acc ->
          coord = {row, col}

          new_acc =
            case get_in(new_acc[:chars][char]) do
              nil -> put_in(new_acc[:chars][char], %{})
              _ -> new_acc
            end

          put_in(new_acc[:chars][char][coord], true)
      end)
    end)
  end

  defp antinodes(map, a, b, multiplier \\ false)

  defp antinodes(map, {arow, acol}, {brow, bcol}, false) do
    {drow, dcol} = {brow - arow, bcol - acol}
    left = {arow - drow, acol - dcol}
    right = {brow + drow, bcol + dcol}
    {vl, vr} = {valid?(left, map), valid?(right, map)}

    map = put_in(map[:antinodes][left], vl)
    put_in(map[:antinodes][right], vr)
  end

  defp antinodes(map, {arow, acol}, {brow, bcol}, multiplier)
       when is_integer(multiplier) do
    {drow, dcol} = {(brow - arow) * multiplier, (bcol - acol) * multiplier}
    left = {arow - drow, acol - dcol}
    right = {brow + drow, bcol + dcol}
    {vl, vr} = {valid?(left, map), valid?(right, map)}

    if vl or vr do
      map = put_in(map[:antinodes][left], vl)
      map = put_in(map[:antinodes][right], vr)
      antinodes(map, {arow, acol}, {brow, bcol}, multiplier + 1)
    else
      map
    end
  end

  def valid?({row, col}, map) do
    width = map.width
    height = map.height

    cond do
      row < 0 -> false
      row >= width -> false
      col < 0 -> false
      col >= height -> false
      true -> true
    end
  end

  def part1(map) do
    Enum.reduce(map.chars, map, fn {_, char}, acc ->
      for({a, true} <- char, {b, true} <- char, a < b, do: {a, b})
      |> Enum.reduce(acc, fn {a, b}, pair_acc -> antinodes(pair_acc, a, b) end)
    end)[:antinodes]
    |> Enum.count(fn {_k, v} -> v end)
  end

  def part2(map) do
    Enum.reduce(map.chars, map, fn {_, char}, acc ->
      for({a, true} <- char, {b, true} <- char, a < b, do: {a, b})
      |> Enum.reduce(acc, fn {a, b}, pair_acc -> antinodes(pair_acc, a, b, 0) end)
    end)[:antinodes]
    |> Enum.count(fn {_k, v} -> v end)
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
