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
    increasing?(rest) or decreasing?(rest)
  end

  defp increasing?([]), do: true
  defp increasing?([_]), do: true

  defp increasing?([first | rest]) do
    Enum.reduce_while(rest, first, fn this, prev ->
      case this - prev do
        diff when diff > 0 and diff < 4 -> {:cont, this}
        _ -> {:halt, false}
      end
    end) != false
  end

  defp decreasing?([]), do: true
  defp decreasing?([_]), do: true

  defp decreasing?([first | rest]) do
    Enum.reduce_while(rest, first, fn this, prev ->
      case this - prev do
        diff when diff < 0 and diff > -4 -> {:cont, this}
        _ -> {:halt, false}
      end
    end) != false
  end

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
