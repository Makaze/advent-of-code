Mix.install([
  {:nimble_parsec, "~> 1.4"}
])

defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2025/day/10
  """

  import NimbleParsec

  def point_from(x), do: List.to_tuple(x)

  anything = ignore(utf8_char([]))

  row =
    integer(min: 1)
    |> ignore(string(","))
    |> integer(min: 1)
    |> reduce({__MODULE__, :point_from, []})

  defparsec(
    :parse,
    repeat(
      choice([
        row,
        anything
      ])
    )
  )

  def bfs(start, neighbors), do: bfs(:queue.new(), MapSet.new([start]), neighbors)

  def bfs(queue, explored, neighbors) do
    case :queue.out(queue) do
      {:empty, _} ->
        explored

      {{:value, node}, queue} ->
        {queue, explored} =
          neighbors.(node)
          |> Enum.reduce({queue, explored}, fn n, {q, e} = acc ->
            if MapSet.member?(acc, n) do
              acc
            else
              q = :queue.in(n, q)
              e = MapSet.put(e, n)
              {q, e}
            end
          end)

        bfs(queue, explored, neighbors)
    end

    bfs(:queue.new(), MapSet.new([start]), f)
  end

  def push_in(t, p, v), do: update_in(t, p, fn _ -> v end)

  def solve(data) do
  end

  def part1({:ok, data, _, _, _, _}, count) do
  end

  def part2({:ok, data, _, _, _, _}) do
  end

  def run() do
    test_file = File.read!("test.txt") |> Solver.parse()

    test_part1 = test_file |> Solver.part1()

    file = File.read!("input.txt") |> Solver.parse()

    real_part1 = file |> Solver.part1()

    IO.inspect(test_part1, label: "Part 1 Test")
    IO.inspect(real_part1, label: "Part 1 Real")

    test_part2 = test_file |> Solver.part2()
    real_part2 = file |> Solver.part2()

    IO.inspect(test_part2, label: "Part 2 Test")
    IO.inspect(real_part2, label: "Part 2 Real")
  end

  def t() do
    Task.async(fn -> Solver.run() end)
  end

  def trace(t) do
    Process.info(t.pid, :current_stacktrace)
  end
end
