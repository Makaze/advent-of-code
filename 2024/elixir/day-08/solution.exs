defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2024/day/8
  """

  def parse(input) do
    data = %{
      height: Enum.count(input),
      width: Enum.count(String.graphemes(Enum.at(input, 0))),
      chars: %{}
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

  defp antinodes(map, a, b, multiplier \\ false, rest \\ [])

  defp antinodes(map, {arow, acol}, {brow, bcol}, false, []) do
    {drow, dcol} = {brow - arow, bcol - acol}
    left = {arow - drow, acol - dcol}
    right = {brow + drow, bcol + dcol}
    [left, right] |> Enum.filter(fn x -> valid?(x, map) end)
  end

  defp antinodes(map, {arow, acol}, {brow, bcol}, multiplier, rest)
       when is_integer(multiplier) do
    {drow, dcol} = {(brow - arow) * multiplier, (bcol - acol) * multiplier}
    left = {arow - drow, acol - dcol}
    right = {brow + drow, bcol + dcol}
    antis = [left, right] |> Enum.filter(fn x -> valid?(x, map) end)

    rest = Enum.reduce(antis, rest, fn x, acc -> [x | acc] end)

    cond do
      length(antis) > 0 -> antinodes(map, {arow, acol}, {brow, bcol}, multiplier + 1, rest)
      true -> rest
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
    for {_, coords} <- map.chars do
      for {a, _} <- coords, {b, _} <- coords, a < b do
        antinodes(map, a, b)
      end
    end
    |> List.flatten()
    |> MapSet.new()
    |> Enum.count()
  end

  def part2(map) do
    for {_, coords} <- map.chars do
      for {a, _} <- coords, {b, _} <- coords, a < b do
        antinodes(map, a, b, 0, [])
      end
    end
    |> List.flatten()
    |> MapSet.new()
    |> Enum.count()
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
