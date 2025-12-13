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
  https://adventofcode.com/2025/day/11
  """

  import NimbleParsec

  def list_from(x), do: x

  anything = ignore(utf8_char([]))
  whitespace = ignore(utf8_char([?\s, ?\t]))
  word = ascii_string([?a..?z], min: 3)

  row =
    word
    |> ignore(string(":"))
    |> repeat(
      choice([
        word,
        whitespace
      ])
    )
    |> reduce({__MODULE__, :list_from, []})

  defparsec(
    :parse,
    repeat(
      choice([
        row,
        anything
      ])
    )
  )

  def push_in(t, p, v), do: update_in(t, p, fn _ -> v end)

  def solve(data) do
  end

  def count_paths(g, start, goal) do
    case :digraph_utils.topsort(g) do
      false ->
        {:error, :cycle}

      topo ->
        ways =
          topo
          |> Enum.reverse()
          |> Enum.reduce(%{goal => 1}, fn vertex, acc ->
            if vertex == goal do
              acc
            else
              sum =
                g
                |> :digraph.out_neighbours(vertex)
                |> Enum.reduce(0, fn neighbor, x -> x + Map.get(acc, neighbor, 0) end)

              Map.put(acc, vertex, sum)
            end
          end)

        {:ok, Map.get(ways, start, 0)}
    end
  end

  def part1({:ok, data, _, _, _, _}) do
    g = :digraph.new()

    edges =
      data
      |> Enum.each(fn [from | tos] ->
        :digraph.add_vertex(g, from)

        Enum.each(tos, fn to ->
          :digraph.add_vertex(g, to)
          :digraph.add_edge(g, from, to, {from, to})
        end)
      end)

    {:ok, ways} = count_paths(g, "you", "out")
    ways
  end

  def part2({:ok, data, _, _, _, _}) do
    g = :digraph.new()

    edges =
      data
      |> Enum.each(fn [from | tos] ->
        :digraph.add_vertex(g, from)

        Enum.each(tos, fn to ->
          :digraph.add_vertex(g, to)
          :digraph.add_edge(g, from, to, {from, to})
        end)
      end)

    if "dac" in :digraph_utils.reachable(["fft"], g) do
      {:ok, segment1} = count_paths(g, "svr", "fft")
      {:ok, segment2} = count_paths(g, "fft", "dac")
      {:ok, segment3} = count_paths(g, "dac", "out")
      [segment1, segment2, segment3]
    else
      {:ok, segment1} = count_paths(g, "svr", "dac")
      {:ok, segment2} = count_paths(g, "dac", "fft")
      {:ok, segment3} = count_paths(g, "fft", "out")
      [segment1, segment2, segment3]
    end
    |> Enum.product()
  end

  def run() do
    test_file = File.read!("test.txt") |> Solver.parse()
    test2_file = File.read!("test2.txt") |> Solver.parse()

    test_part1 = test_file |> Solver.part1()

    IO.inspect(test_part1, label: "Part 1 Test")

    test_part2 = test2_file |> Solver.part2()
    IO.inspect(test_part2, label: "Part 2 Test")

    file = File.read!("input.txt") |> Solver.parse()

    real_part1 = file |> Solver.part1()
    IO.inspect(real_part1, label: "Part 1 Real")

    real_part2 = file |> Solver.part2()
    IO.inspect(real_part2, label: "Part 2 Real")
  end

  def t() do
    Task.async(fn -> Solver.run() end)
  end

  def trace(t) do
    Process.info(t.pid, :current_stacktrace)
  end
end
