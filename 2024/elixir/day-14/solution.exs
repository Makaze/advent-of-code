Mix.install([
  {:nimble_parsec, "~> 1.4"}
])

defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2024/day/14
  """

  import NimbleParsec

  def robot_from([px, py, vx, vy]), do: %{p: %{x: px, y: py}, v: %{x: vx, y: vy}}
  def int_from(["-", num]), do: num * -1
  def int_from([num]), do: num

  anything = ignore(utf8_char([]))
  neg_int = string("-") |> integer(min: 1) |> reduce({__MODULE__, :int_from, []})
  pos_int = integer(min: 1) |> reduce({__MODULE__, :int_from, []})

  robot =
    ignore(string("p="))
    |> choice([neg_int, pos_int])
    |> ignore(string(","))
    |> choice([neg_int, pos_int])
    |> ignore(string(" v="))
    |> choice([neg_int, pos_int])
    |> ignore(string(","))
    |> choice([neg_int, pos_int])
    |> reduce({__MODULE__, :robot_from, []})

  defparsec(
    :parse,
    repeat(
      choice([
        robot,
        anything
      ])
    )
  )

  def predict(%{p: p, v: v}, time, constraints \\ %{h: 103, w: 101}) do
    new = %{
      x: rem(p.x + (constraints.w + v.x) * time, constraints.w),
      y: rem(p.y + (constraints.h + v.y) * time, constraints.h)
    }
  end

  def part1({:ok, results, _, _, _, _}, time, constraints) do
    results =
      results
      |> Enum.map(&predict(&1, time, constraints))

    quads = %{
      1 => %{
        top: 0,
        bottom: floor(constraints.h / 2) - 1,
        left: 0,
        right: floor(constraints.w / 2) - 1
      },
      2 => %{
        top: 0,
        bottom: floor(constraints.h / 2) - 1,
        left: ceil(constraints.w / 2),
        right: constraints.w - 1
      },
      3 => %{
        top: ceil(constraints.h / 2),
        bottom: constraints.h - 1,
        left: ceil(constraints.w / 2),
        right: constraints.w - 1
      },
      4 => %{
        top: ceil(constraints.h / 2),
        bottom: constraints.h - 1,
        left: 0,
        right: floor(constraints.w / 2) - 1
      }
    }

    quads
    |> Enum.reduce(%{}, fn {k, q}, acc ->
      vals =
        results
        |> Enum.reject(fn robot ->
          robot.x not in q.left..q.right or robot.y not in q.top..q.bottom
        end)

      put_in(acc[k], vals)
    end)
    |> Enum.map(fn {_k, v} -> length(v) end)
    |> Enum.product()
  end

  def part2({:ok, results, _, _, _, _}, constraints) do
    time =
      100..10_000
      |> Enum.reduce_while(100, fn i, acc ->
        f =
          results
          |> Enum.map(&predict(&1, i, constraints))
          |> Enum.frequencies()
          |> Map.values()
          |> Enum.max()

        if f == 1 do
          {:halt, i}
        else
          {:cont, f}
        end
      end)

    print(
      results
      |> Enum.map(&predict(&1, time, constraints)),
      constraints
    )

    time
  end

  defp print(prediction, constraints) do
    p =
      for y <- 0..(constraints.h - 1) do
        for x <- 0..(constraints.w - 1) do
          if %{x: x, y: y} in prediction do
            "X"
          else
            " "
          end
        end
        |> Enum.join("")
      end
      |> Enum.join("\n")

    IO.puts(p)
  end
end

test_file =
  File.read!("test.txt")

file =
  File.read!("input.txt")

IO.inspect(test_file |> Solver.parse() |> Solver.part1(100, %{h: 7, w: 11}), label: "Part 1 Test")
IO.inspect(file |> Solver.parse() |> Solver.part1(100, %{h: 103, w: 101}), label: "Part 1 Real")
IO.inspect(file |> Solver.parse() |> Solver.part2(%{h: 103, w: 101}), label: "Part 2 Real")
