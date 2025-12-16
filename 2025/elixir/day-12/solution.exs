Mix.install([
  {:nimble_parsec, "~> 1.4"}
])

defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2025/day/11
  """

  import NimbleParsec

  def shape_from([i | rest]), do: %{index: i, space: Enum.sum(rest)}
  def area_from([h, w | rest]), do: %{h: h, w: w, shapes: rest}

  anything = ignore(utf8_char([]))
  whitespace = ignore(utf8_char([?\s, ?\t]))
  newlines = ignore(utf8_char([?\n, ?\r]))

  shape =
    integer(min: 1)
    |> ignore(string(":"))
    |> repeat(
      choice([
        string("#") |> replace(1),
        string(".") |> replace(0),
        newlines
      ])
    )
    |> reduce({__MODULE__, :shape_from, []})

  area =
    integer(min: 1)
    |> ignore(string("x"))
    |> integer(min: 1)
    |> ignore(string(":"))
    |> repeat(whitespace |> concat(integer(min: 1)))
    |> reduce({__MODULE__, :area_from, []})

  defparsec(
    :parse,
    repeat(
      choice([
        shape,
        area,
        anything
      ])
    )
  )

  def part1({:ok, data, _, _, _, _}) do
    {shapes, areas} =
      Enum.split_with(data, fn
        %{index: _i, space: _s} -> true
        _ -> false
      end)

    shapes =
      shapes
      |> Enum.reduce(%{}, fn %{index: i, space: s}, acc ->
        Map.put(acc, i, s)
      end)

    areas
    |> Enum.count(fn %{h: h, w: w, shapes: s} ->
      a = h * w

      sum =
        s
        |> Enum.with_index()
        |> Enum.map(fn {num, i} -> num * Map.get(shapes, i) end)
        |> Enum.sum()

      a >= sum
    end)
  end

  def run() do
    test_file = File.read!("test.txt") |> Solver.parse()

    test_part1 = test_file |> Solver.part1()

    IO.inspect(test_part1, label: "Part 1 Test")

    file = File.read!("input.txt") |> Solver.parse()

    real_part1 = file |> Solver.part1()
    IO.inspect(real_part1, label: "Part 1 Real")
  end

  def t() do
    Task.async(fn -> Solver.run() end)
  end

  def trace(t) do
    Process.info(t.pid, :current_stacktrace)
  end
end
