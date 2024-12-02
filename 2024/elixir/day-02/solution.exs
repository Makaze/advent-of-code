defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2024/day/2
  """

  def parse(row) do
    row
    |> String.trim()
    |> String.split(~r/\s+/)
    |> Enum.map(&String.to_integer/1)
  end

  def safe?([]), do: true

  def safe?(rest) do
    mono?(rest, &increasing?/2) or mono?(rest, &decreasing?/2)
  end

  defp mono?([], _), do: true
  defp mono?([_], _), do: true

  defp mono?([first | rest], direction) do
    Enum.reduce_while(rest, first, fn this, prev ->
      if direction.(prev, this), do: {:cont, this}, else: {:halt, false}
    end) != false
  end

  defp increasing?(prev, this), do: this - prev > 0 and this - prev < 4
  defp decreasing?(prev, this), do: this - prev < 0 and this - prev > -4

  def with_skip(rest, callback) do
    callback.(rest) or
      Enum.any?(0..(length(rest) - 1), fn index ->
        mod = List.delete_at(rest, index)
        callback.(mod)
      end)
  end
end

file =
  File.stream!("input.txt")
  # File.stream!("test.txt")
  |> Stream.map(&Solver.parse/1)

reports1 =
  file
  |> Enum.count(&Solver.safe?/1)

reports2 =
  file
  |> Enum.count(fn report -> Solver.with_skip(report, &Solver.safe?/1) end)

IO.puts("Part 1: #{reports1}")
IO.puts("Part 2: #{reports2}")
