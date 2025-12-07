Mix.install([
  {:nimble_parsec, "~> 1.4"}
])

defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2025/day/6
  """

  import NimbleParsec

  def row_from(x), do: x

  anything = ignore(utf8_char([]))
  whitespace = utf8_char([?\s, ?\t])

  arg = integer(min: 1)
  digit = integer(1)

  operation =
    choice([
      string("+"),
      string("*")
    ])

  row =
    repeat(
      choice([
        operation,
        arg,
        ignore(whitespace)
      ])
    )
    |> ignore(anything)
    |> reduce({__MODULE__, :row_from, []})

  columns =
    repeat(
      choice([
        operation,
        digit,
        whitespace |> replace(nil)
      ])
    )
    |> ignore(anything)
    |> reduce({__MODULE__, :row_from, []})

  defparsec(
    :parse,
    repeat(
      choice([
        row,
        anything
      ])
    )
  )

  defparsec(
    :parse2,
    repeat(
      choice([
        columns,
        anything
      ])
    )
  )

  def get_in_tuple(tuple, []) do
    tuple
  end

  def get_in_tuple(tuple, index) when is_integer(index), do: get_in_tuple(tuple, [index])

  def get_in_tuple(tuple, [index | rest])
      when is_tuple(tuple) and tuple_size(tuple) - 1 >= index and index >= 0 do
    elem(tuple, index) |> get_in_tuple(rest)
  end

  def get_in_tuple(tuple, index), do: {:index_error, tuple, index}

  def part1({:ok, ranges, _, _, _, _}) do
    {args, [ops]} =
      ranges
      |> Enum.split_with(fn
        [x | _r] when is_integer(x) and x > 0 -> true
        _ -> false
      end)

    args = args |> Enum.map(&List.to_tuple/1)

    ops
    |> Enum.with_index()
    |> Enum.map(fn
      {"+", i} -> args |> Enum.reduce(0, fn x, acc -> acc + get_in_tuple(x, i) end)
      {"*", i} -> args |> Enum.reduce(1, fn x, acc -> acc * get_in_tuple(x, i) end)
    end)
    |> Enum.sum()
  end

  def part2({:ok, ranges, _, _, _, _}) do
    {args, [ops]} =
      ranges
      |> Enum.split_with(fn
        ["+" | _r] -> false
        ["*" | _r] -> false
        _ -> true
      end)

    args =
      args
      |> Enum.zip()
      |> Enum.map(fn x -> x |> Tuple.to_list() |> Enum.reject(&is_nil/1) |> Integer.undigits() end)
      |> Enum.reverse()
      |> Enum.reject(&(&1 === 0))

    ops
    |> Enum.reduce(%{ops: [], temp: 0}, fn
      el, acc when is_nil(el) ->
        Map.update(acc, :temp, 0, fn x -> x + 1 end)

      el, acc ->
        acc
        |> Map.update(:ops, [el], fn
          [] -> [{el, acc.temp}]
          [{last_el, _} | rest] -> [{el, acc.temp}, {last_el, acc.temp} | rest]
        end)
        |> Map.put(:temp, 0)
    end)
    |> Map.get(:ops)
    |> Enum.map_reduce(args, fn
      {"+", count}, rest ->
        {a, r} = Enum.split(rest, count)
        {a |> Enum.sum(), r}

      {"*", count}, rest ->
        {a, r} = Enum.split(rest, count)
        {a |> Enum.product(), r}
    end)
    |> elem(0)
    |> Enum.sum()
  end
end

test_file =
  File.read!("test.txt")

file =
  File.read!("input.txt")

IO.inspect(test_file |> Solver.parse() |> Solver.part1(), label: "Part 1 Test")
IO.inspect(file |> Solver.parse() |> Solver.part1(), label: "Part 1 Real")

IO.inspect(test_file |> Solver.parse2() |> Solver.part2(), label: "Part 2 Test")
IO.inspect(file |> Solver.parse2() |> Solver.part2(), label: "Part 2 Real")
