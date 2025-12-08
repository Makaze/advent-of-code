Mix.install([
  {:nimble_parsec, "~> 1.4"}
])

defmodule Memoize do
  @moduledoc """
  Provides a macro to memoize function results using ETS (Erlang Term Storage).

  This module dynamically generates an ETS table for each memoized function
  and caches the results of function calls. Subsequent calls with the same
  arguments retrieve the result directly from the ETS cache.

  ## Features

    - Automatically generates a unique ETS table for each function.
    - Handles any number of arguments using a unique cache key.
    - Supports functions with specific patterns or guards.

  ## Example Usage

      defmodule Example do
        require Memoize

        # Define a memoized function
        Memoize.defmemo blink(v, 1) do
          if rem(v, 2) == 0, do: :even, else: :odd
        end

        # Another memoized function
        Memoize.defmemo factorial(n) do
          cond do
            n == 0 -> 1
            true -> n * factorial(n - 1)
          end
        end
      end

      # Example usage
      IO.inspect(Example.blink(4, 1))      # Output: :even
      IO.inspect(Example.blink(4, 1))      # Output: :even (cached result)
      IO.inspect(Example.factorial(5))     # Output: 120
  """

  @doc """
  Defines a memoized function.

  This macro wraps a function to store its results in an ETS table.
  When the function is called, it checks if the result for the given arguments
  is already cached. If cached, the result is returned immediately; otherwise,
  the function is executed, and the result is stored in the cache.

  ## Example

      Memoize.defmemo my_function(x, y) do
        x + y
      end

  ## Notes

    - Each memoized function gets its own ETS table to avoid key collisions.
    - The table is created lazily if it does not exist.
  """
  defmacro defmemo({name, _meta, args}, _opts \\ [], do: body) do
    quote do
      def unquote(name)(unquote_splicing(args)) do
        cache_table = String.to_atom("#{__MODULE__}_#{unquote(name)}_cache")

        if :ets.info(cache_table) == :undefined do
          :ets.new(cache_table, [:named_table, :public, :set])
        end

        args_key = {__MODULE__, unquote(name), [unquote_splicing(args)]}

        case :ets.lookup(cache_table, args_key) do
          [{^args_key, result}] ->
            result

          [] ->
            result = (fn -> unquote(body) end).()
            :ets.insert(cache_table, {args_key, result})
            result
        end
      end
    end
  end
end

defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2025/day/7
  """

  import Memoize
  import NimbleParsec

  def row_from(x), do: x

  anything = ignore(utf8_char([]))

  row =
    repeat(
      choice([
        string(".") |> replace(nil),
        string("S") |> replace(:start),
        string("^") |> replace(:splitter)
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

  defmemo traverse(row, col, %{height: h, width: w} = grid) do
    cond do
      row >= h -> 1
      col >= w -> 1
      col < 0 -> 1
      true -> do_traverse(row, col, grid)
    end
  end

  defmemo do_traverse(row, col, %{splits: s} = grid) do
    if Map.has_key?(s, {row, col}) do
      :ets.update_counter(:splits, :count, {2, 1}, {:count, 0})
      a = traverse(row + 1, col + 1, grid)
      b = traverse(row + 1, col - 1, grid)
      a + b
    else
      traverse(row + 1, col, grid)
    end
  end

  :ets.new(:splits, [:named_table, :public, :set])

  def solve({:ok, data, _, _, _, _}) do
    grid = %{
      height: Enum.count(data),
      width: data |> Enum.at(0) |> Enum.count(),
      start: {},
      splits: %{}
    }

    grid =
      data
      |> Enum.with_index()
      |> Enum.map(fn
        {el, row} -> el |> Enum.with_index() |> Enum.map(fn {char, col} -> {row, col, char} end)
      end)
      |> List.flatten()
      |> Enum.reduce(grid, fn
        {row, col, :start}, acc -> put_in(acc.start, {row, col})
        {row, col, :splitter}, acc -> put_in(acc, [:splits, {row, col}], true)
        _, acc -> acc
      end)

    {r, c} = get_in(grid, [:start])

    part2 = traverse(r, c, grid)

    part1 =
      case :ets.lookup(:splits, :count) do
        [{:count, result}] ->
          result

        [] ->
          0
      end

    {part1, part2}
  end
end

test_file =
  File.read!("test.txt") |> Solver.parse()

file =
  File.read!("input.txt") |> Solver.parse()

{test_part1, test_part2} = test_file |> Solver.solve()
{real_part1, real_part2} = file |> Solver.solve()

IO.inspect(test_part1, label: "Part 1 Test")
IO.inspect(real_part1, label: "Part 1 Real")

IO.inspect(test_part2, label: "Part 2 Test")
IO.inspect(real_part2, label: "Part 2 Real")
