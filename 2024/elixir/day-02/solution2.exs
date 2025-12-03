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
    IO.puts("New list: ----------")
    IO.inspect(rest, charlists: :as_lists)
    result = increasing?(rest, 0, 0) or decreasing?(rest, 0)
    IO.inspect(result)
    result
  end

  def increasing?(rest, last \\ 0, skipped \\ 0)
  def increasing?([], _last, _skipped), do: true
  def increasing?([_], _last, _skipped), do: true
  def increasing?([0 | _rest], _last, _skipped), do: false

  def increasing?([prev, next | rest], last, skipped) do
    result =
      case next - prev do
        diff when diff > 0 and diff < 4 ->
          increasing?([next | rest], prev, skipped)

        _diff when skipped < 1 ->
          increasing?([last, next | rest], last, prev) or increasing?([prev | rest], prev, next)

        _ ->
          false
      end

    if not result do
      IO.puts("Increasing -- prev=#{prev}, next=#{next}, skipped=#{skipped}, last=#{last}")
      IO.inspect(result)
    end

    result
  end

  def decreasing?(rest, last \\ 0, skipped \\ 0)
  def decreasing?([], _last, _skipped), do: true
  def decreasing?([_], _last, _skipped), do: true
  def decreasing?([0 | _rest], _last, _skipped), do: false

  def decreasing?([prev, next | rest], last, skipped) do
    result =
      case next - prev do
        diff when diff < 0 and diff > -4 ->
          decreasing?([next | rest], prev, skipped)

        _diff when skipped < 1 ->
          decreasing?([last, next | rest], last, prev) or decreasing?([prev | rest], prev, next)

        _ ->
          false
      end

    if not result do
      IO.puts("Decreasing -- prev=#{prev}, next=#{next}, skipped=#{skipped}, last=#{last}")
      IO.inspect(result)
    end

    result
  end
end

reports =
  File.stream!("input.txt")
  # File.stream!("test.txt")
  |> Stream.map(&Solver.parse/1)
  |> Enum.count(&Solver.safe?/1)

IO.puts("Part 1: #{reports}")
# IO.puts("Part 2: #{diff2}")
