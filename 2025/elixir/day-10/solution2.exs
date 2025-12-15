Mix.install([
  {:nimble_parsec, "~> 1.4"}
])

defmodule Diagram do
  @typedoc """
  A diagram for AoC Day 10 2025.
  """
  @type diagram() :: Map.t()

  defstruct goal: %{}, state: %{}, buttons: [], joltages: %{}, assigned: %{}, maxes: %{}

  def charge(%Diagram{joltages: g, buttons: b} = d) do
    %Diagram{
      d
      | state: g,
        assigned:
          for i <- 0..(length(b) - 1), into: %{} do
            {i, nil}
          end
    }
  end

  @doc """
  Returns the list of joltages and the indexes buttons that increment them, sorted by the number of buttons affecting that index and the amount of joltage required.

  This represents an equation of the form:
  coefficient of button 0 + coefficient of button 1 ... + button n = joltage needed
  Returns:
    iex> [{joltage_index, [button1, ...], joltage_required}, ...]
  """
  def constrain(%Diagram{buttons: buttons, assigned: a} = d) do
    m =
      om =
      buttons
      |> Enum.with_index()
      |> Enum.filter(fn {_, i} ->
        ax = Map.get(a, i)
        is_nil(ax) or ax < 1
      end)

    strings = [
      ("Minimize\n obj: x" <> Enum.join(0..(length(om) - 1), " + x")) <> "\n\nSubject To"
    ]

    m =
      m
      |> Enum.reduce(%{}, fn {el, index}, m_acc ->
        el
        |> Enum.reduce(m_acc, fn i, m_inner_acc ->
          Map.update(m_inner_acc, i, [index], &[index | &1])
        end)
      end)

    strings =
      m
      |> Enum.reduce(strings, fn {k, v}, acc ->
        [" c#{k}: x" <> Enum.join(v, " + x") <> " = #{Map.get(d.state, k)}" | acc]
      end)

    strings =
      [
        "\nEnd\n",
        "\nGeneral\n x" <> Enum.join(0..(length(om) - 1), " x"),
        "\nBounds\n x" <> Enum.join(0..(length(om) - 1), " >= 0\n x") <> " >= 0"
        | strings
      ]
      |> Enum.reverse()
      |> Enum.join("\n")

    m =
      m
      |> Enum.map(fn {k, v} ->
        {k, v, Map.get(d.state, k)}
      end)

    {d, m, strings}
  end
end

defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2025/day/10
  """

  import NimbleParsec

  def list_from(x), do: x
  def state_from(x), do: x |> Enum.with_index() |> Enum.into(%{}, fn {v, k} -> {k, v} end)

  def diagram_from([state, buttons, joltage | _rest]) do
    %Diagram{
      goal: state,
      state: state,
      buttons: buttons,
      joltages: joltage
    }
  end

  anything = ignore(utf8_char([]))
  whitespace = ignore(utf8_char([?\s, ?\t]))

  diagram =
    ignore(string("["))
    |> repeat(
      choice([
        string(".") |> replace(false),
        string("#") |> replace(true)
      ])
    )
    |> ignore(string("]"))
    |> ignore(whitespace)
    |> reduce({__MODULE__, :state_from, []})

  button =
    ignore(string("("))
    |> repeat(
      choice([
        integer(min: 1),
        ignore(string(","))
      ])
    )
    |> ignore(string(")"))
    |> ignore(whitespace)
    |> reduce({__MODULE__, :list_from, []})

  buttons =
    repeat(button)
    |> reduce({__MODULE__, :list_from, []})

  joltage =
    ignore(string("{"))
    |> repeat(
      choice([
        integer(min: 1),
        ignore(string(","))
      ])
    )
    |> ignore(string("}"))
    |> reduce({__MODULE__, :state_from, []})

  row =
    diagram
    |> concat(buttons)
    |> concat(joltage)
    |> reduce({__MODULE__, :diagram_from, []})

  defparsec(
    :parse,
    repeat(
      choice([
        row,
        anything
      ])
    )
  )

  def part2({:ok, data, _, _, _, _}) do
    data
    |> Enum.with_index()
    |> Enum.map(fn {d, i} ->
      {d, c, s} =
        d
        |> Diagram.charge()
        |> Diagram.constrain()

      File.write!("model#{i}.lp", s)

      {res, status} = System.shell("highs model#{i}.lp | grep objective | awk '{print $1}'")

      {d, c, res |> String.trim() |> String.to_integer(), status}
      res |> String.trim() |> String.to_integer()
    end)
    |> Enum.sum()
  end

  def run() do
    test_file = File.read!("test.txt") |> Solver.parse()

    test_part2 = test_file |> Solver.part2()
    IO.inspect(test_part2, label: "Part 2 Test")

    file = File.read!("input.txt") |> Solver.parse()

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
