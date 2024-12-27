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

  ## Arguments

    - `name` - The function name and its parameters (e.g., `blink(v, 1)`).

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

        # Ensure the table exists
        if :ets.info(cache_table) == :undefined do
          :ets.new(cache_table, [:named_table, :public, :set])
        end

        # Create a unique cache key
        args_key = {__MODULE__, unquote(name), [unquote_splicing(args)]}

        # Check if the result is cached
        case :ets.lookup(cache_table, args_key) do
          [{^args_key, result}] ->
            result

          [] ->
            # Compute and cache the result
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
  https://adventofcode.com/2024/day/11
  """

  import Memoize

  defp count_digits(0), do: 1
  defp count_digits(v), do: :math.log10(v) |> floor() |> Kernel.+(1) |> trunc()

  defmemo blink(v, 1) do
    digits = count_digits(v)

    cond do
      rem(digits, 2) == 0 -> 2
      true -> 1
    end
  end

  defmemo blink(0, i) do
    blink(1, i - 1)
  end

  defmemo blink(v, i) do
    digits = count_digits(v)

    cond do
      rem(digits, 2) == 0 ->
        [left, right] = split(v, digits)
        blink(left, i - 1) + blink(right, i - 1)

      true ->
        blink(v * 2024, i - 1)
    end
  end

  defmemo split(value, digits) do
    divisor = :math.pow(10, div(digits, 2)) |> trunc()

    [div(value, divisor), rem(value, divisor)]
  end

  def parse(input) do
    input
    |> Enum.map(&String.to_integer/1)
  end

  def part1(stones) do
    stones
    |> Enum.map(fn x -> blink(x, 25) end)
    |> Enum.sum()
  end

  def part2(stones) do
    stones
    |> Enum.map(fn x -> blink(x, 75) end)
    |> Enum.sum()
  end
end

test_file =
  File.read!("test.txt")
  |> String.split(~r/\s+/, trim: true)

file =
  File.read!("input.txt")
  |> String.split(~r/\s+/, trim: true)

IO.inspect(test_file |> Solver.parse() |> Solver.part1(), label: "Part 1 Test")
IO.inspect(file |> Solver.parse() |> Solver.part1(), label: "Part 1 Real")
IO.inspect(test_file |> Solver.parse() |> Solver.part2(), label: "Part 2 Test")
IO.inspect(file |> Solver.parse() |> Solver.part2(), label: "Part 2 Real")
