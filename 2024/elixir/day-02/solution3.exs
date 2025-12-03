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

  def increasing?([]), do: true
  def increasing?([_]), do: true

  def increasing?([first | rest]) do
    Enum.reduce_while(rest, first, fn this, prev ->
      case this - prev do
        diff when diff > 0 and diff < 4 -> {:cont, this}
        _ -> {:halt, false}
      end
    end) != false
  end

  def decreasing?([]), do: true
  def decreasing?([_]), do: true

  def decreasing?([first | rest]) do
    Enum.reduce_while(rest, first, fn this, prev ->
      case this - prev do
        diff when diff < 0 and diff > -4 -> {:cont, this}
        _ -> {:halt, false}
      end
    end) != false
  end
end

reports =
  File.stream!("input.txt")
  # File.stream!("test.txt")
  |> Stream.map(&Solver.parse/1)
  |> Enum.count(&Solver.safe?/1)

IO.puts("Part 1: #{reports}")
# IO.puts("Part 2: #{diff2}")
