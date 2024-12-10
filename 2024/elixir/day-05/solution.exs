Mix.install([
  {:nimble_parsec, "~> 1.4"}
])

defmodule Rule do
  defstruct [:left, :right, :sorter]
end

defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2024/day/5
  """

  import NimbleParsec

  def rule_from([left, right]) do
    %Rule{
      left: left,
      right: right,
      sorter: fn
        ^left, ^right -> true
        ^right, ^left -> false
        _left, _right -> true
      end
    }
  end

  def row_from(row), do: row

  anything = ignore(utf8_char([]))

  rule =
    integer(max: 2)
    |> ignore(string("|"))
    |> integer(max: 2)
    |> optional(ignore(anything))
    |> reduce({__MODULE__, :rule_from, []})

  page =
    integer(max: 2)
    |> repeat(ignore(string(",")) |> concat(integer(max: 2)))
    |> reduce({__MODULE__, :row_from, []})

  defparsec(
    :rules,
    repeat(rule)
  )

  defparsec(
    :updates,
    repeat(
      choice([
        page,
        anything
      ])
    )
  )

  def rules_to_parsec([_ | _] = list) when is_list(list) do
    list
    |> Enum.reduce(%{}, fn %Rule{left: val, right: key}, acc ->
      Map.update(acc, key, MapSet.new([val]), fn rest -> MapSet.put(rest, val) end)
    end)
  end

  def sorted?(list, map, prev \\ MapSet.new([]))

  def sorted?([], _, _), do: true

  def sorted?([head | rest], %{} = map, prev) do
    set = Map.get(map, head)

    case set do
      nil ->
        sorted?(rest, map, MapSet.put(prev, head))

      _ ->
        set |> Enum.all?(fn x -> MapSet.member?(prev, x) or not Enum.member?(rest, x) end) and
          sorted?(rest, map, MapSet.put(prev, head))
    end
  end

  def middle([_ | _] = list) do
    mid = div(length(list), 2)
    Enum.at(list, mid)
  end

  def sum({:ok, results, _, _, _, _}) do
    Enum.sum(results)
  end
end

# File.read!("test.txt")
[rules, updates] =
  File.read!("input.txt")
  |> String.split(~r/\s\s+/, trim: true)

{:ok, rules, _, _, _, _} = rules |> Solver.rules()
{:ok, updates, _, _, _, _} = updates |> Solver.updates()
map = Solver.rules_to_parsec(rules)

part1 =
  updates
  |> Enum.filter(fn x -> Solver.sorted?(x, map) end)
  |> Enum.map(&Solver.middle/1)
  |> Enum.sum()

part2 =
  updates
  |> Enum.filter(fn x -> !Solver.sorted?(x, map) end)
  |> Enum.map(fn x ->
    sorters =
      rules
      |> Enum.map(fn rule ->
        rule.sorter
      end)

    Enum.sort(x, fn a, b ->
      Enum.all?(
        Enum.map(sorters, fn s ->
          s.(a, b)
        end)
      )
    end)
  end)
  |> Enum.map(&Solver.middle/1)
  |> Enum.sum()

IO.inspect(part1, label: "Part 1")
IO.inspect(part2, label: "Part 2")
