defmodule Solver do
  def parse(line) do
    line
    |> String.replace(~r/Game \d+:\s+/, "")
    |> String.trim()
    |> String.split(";", trim: true)
    |> Enum.map(&parse_game/1)
  end

  defp parse_game(game) do
    game
    |> String.split(",", trim: true)
    |> Enum.map(&parse_item/1)
    |> Enum.reduce(
      %{red: 0, green: 0, blue: 0},
      &Map.merge(&2, &1, fn _key, default, new -> default + new end)
    )
  end

  defp parse_item(item) do
    [count, color] = String.split(item, " ", trim: true)
    color = String.to_atom(color)
    %{color => String.to_integer(count)}
  end

  def filter({games, index}) do
    case Enum.any?(games, fn %{red: red, green: green, blue: blue} = _game ->
           red > 12 or green > 13 or blue > 14
         end) do
      false -> index + 1
      _ -> 0
    end
  end

  def powers({games, _index}) do
    low =
      Enum.reduce(
        games,
        %{},
        &Map.merge(&2, &1, fn _key, acc_value, new_value -> max(acc_value, new_value) end)
      )

    low.red * low.green * low.blue
  end
end

file =
  File.stream!("input.txt")
  |> Stream.map(&Solver.parse/1)
  |> Enum.with_index()

stream1 =
  file
  |> Enum.map(&Solver.filter/1)
  |> Enum.sum()

stream2 =
  file
  |> Enum.map(&Solver.powers/1)
  |> Enum.sum()

IO.puts("Part 1: #{stream1}")
IO.puts("Part 2: #{stream2}")
