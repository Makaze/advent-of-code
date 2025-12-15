Mix.install([
  {:nimble_parsec, "~> 1.4"}
])

defmodule DiagramNode do
  defstruct state: nil, action: nil, parent: nil

  def bfs(start, goal?, neighbors) do
    if goal?.(start) do
      %DiagramNode{state: start}
    else
      start = %DiagramNode{state: start}
      bfs(:queue.in(start, :queue.new()), goal?, MapSet.new([]), neighbors)
    end
  end

  def bfs(queue, goal?, explored, neighbors) do
    case :queue.out(queue) do
      {:empty, _} ->
        explored

      {{:value, node}, queue} ->
        if goal?.(node.state) do
          node
        else
          nexts = neighbors.(node)

          found = nexts |> Enum.find(fn x -> goal?.(x) end)

          if found do
            found
          else
            {queue, explored} =
              nexts
              |> Enum.reduce({queue, explored}, fn neighbor, {q, e} = acc ->
                if MapSet.member?(e, neighbor.state) do
                  acc
                else
                  q = :queue.in(neighbor, q)
                  e = MapSet.put(e, neighbor.state)
                  {q, e}
                end
              end)

            bfs(queue, goal?, explored, neighbors)
          end
        end
    end
  end

  def path_size(%DiagramNode{parent: nil}), do: 0
  def path_size(%DiagramNode{parent: p}), do: path_size(p, 1)
  def path_size(%DiagramNode{parent: nil}, size), do: size
  def path_size(%DiagramNode{parent: p}, size), do: path_size(p, size + 1)
end

defmodule Diagram do
  @typedoc """
  A diagram for AoC Day 10 2025.
  """
  @type diagram() :: Map.t()

  defstruct goal: %{}, state: %{}, buttons: [], joltages: %{}, assigned: %{}, maxes: %{}

  def toggle_button(%Diagram{state: s, buttons: b} = d, button_id) do
    button = b |> Enum.at(button_id)

    new_state =
      button
      |> Enum.reduce(s, fn light, acc ->
        acc |> Map.update(light, true, &(not &1))
      end)

    %Diagram{d | state: new_state}
  end

  def incr_button(%Diagram{state: s, buttons: b} = d, button_id) do
    button = b |> Enum.at(button_id)

    new_state =
      button
      |> Enum.reduce(s, fn joltage, acc ->
        acc
        |> Map.update(joltage, 1, fn x ->
          if is_integer(x) do
            x + 1
          else
            1
          end
        end)
      end)

    %Diagram{d | state: new_state}
  end

  def reset(%Diagram{goal: g} = d), do: %Diagram{d | state: Map.from_keys(g |> Map.keys(), false)}
  def empty(%Diagram{joltages: g} = d), do: %Diagram{d | state: Map.from_keys(g |> Map.keys(), 0)}

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

  def is_joltage?(%Diagram{state: s, joltages: j}) when s == j, do: true
  def is_joltage?(_), do: false

  def is_lit?(%Diagram{state: s, goal: g}) when s == g, do: true
  def is_lit?(_), do: false

  def light_neighbors(%DiagramNode{state: %Diagram{buttons: b} = d} = n) do
    0..(length(b) - 1)
    |> Enum.map(fn id ->
      %DiagramNode{
        state: d |> Diagram.toggle_button(id),
        action: id,
        parent: n
      }
    end)
  end

  def jolt_neighbors(%DiagramNode{state: %Diagram{buttons: b, joltages: j} = d} = n) do
    0..(length(b) - 1)
    |> Enum.map(fn id ->
      %Diagram{state: new_j} = increased = d |> Diagram.incr_button(id)

      if Enum.any?(new_j, fn {k, v} -> v > Map.get(j, k) end) do
        nil
      else
        %DiagramNode{
          state: increased,
          action: id,
          parent: n
        }
      end
    end)
    |> Enum.reject(&is_nil/1)
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
      buttons
      |> Enum.with_index()
      |> Enum.filter(fn {_, i} ->
        ax = Map.get(a, i)
        is_nil(ax) or ax < 1
      end)

    maxes =
      Enum.reduce(m, %{}, fn {v, k}, acc ->
        v
        |> Enum.reduce(acc, fn i, inner_acc ->
          j = Map.get(d.state, i)
          Map.update(inner_acc, k, j, fn old -> min(old, j) end)
        end)
      end)

    d =
      maxes
      |> Enum.reduce(d, fn {k, v}, acc ->
        %Diagram{acc | maxes: Map.put(acc.maxes, k, v)}
      end)

    m =
      m
      |> Enum.reduce(%{}, fn {el, index}, m_acc ->
        el
        |> Enum.reduce(m_acc, fn i, m_inner_acc ->
          Map.update(m_inner_acc, i, [index], &[index | &1])
        end)
      end)

    ranks = ranks(m)

    m =
      m
      |> Enum.map(fn {k, v} ->
        {k, v |> Enum.sort_by(fn x -> {Map.get(ranks, x), -Map.get(maxes, x)} end),
         Map.get(d.state, k), length(v)}
      end)
      |> Enum.sort_by(fn {_i, _c, j, l} -> {l, j} end)
      |> Enum.map(fn {i, c, j, _l} -> {i, c, j} end)

    {d, m}
  end

  def ranks(m) do
    m
    |> Enum.reduce(%{}, fn {_k, v}, m_acc ->
      lv = length(v)

      v
      |> Enum.reduce(m_acc, fn i, m_inner_acc ->
        m_inner_acc |> Map.update(i, lv, fn old -> min(old, lv) end)
      end)
    end)
  end

  def force(%Diagram{} = d) do
    {d, constraints} = constrain(d)

    case hd(constraints) do
      {_c, [best_var], value} -> assign(d, best_var, value) |> force()
      {_c, [best_var, _b], value} -> assign(d, best_var, value)
      _ -> d
    end
  end

  def assign(%Diagram{buttons: b, state: s, joltages: j, assigned: a} = d, button_id, value) do
    new_state =
      b
      |> Enum.at(button_id)
      |> Enum.reduce(s, fn joltage, acc ->
        acc
        |> Map.update(joltage, Map.get(j, joltage), fn x -> x - value end)
      end)

    %Diagram{d | state: new_state, assigned: Map.put(a, button_id, value)}
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

  def push_in(t, p, v), do: update_in(t, p, fn _ -> v end)

  def solve(data) do
  end

  def part1({:ok, data, _, _, _, _}) do
    data
    |> Enum.map(fn d ->
      r = DiagramNode.bfs(Diagram.reset(d), &Diagram.is_lit?/1, &Diagram.light_neighbors/1)
      r |> DiagramNode.path_size()
    end)
    |> Enum.sum()
  end

  def part2({:ok, data, _, _, _, _}) do
    data
    |> Enum.map(fn d ->
      d
      |> Diagram.charge()
      |> Diagram.force()
      |> Diagram.constrain()
    end)
  end

  def run() do
    test_file = File.read!("test.txt") |> Solver.parse()

    test_part1 = test_file |> Solver.part1()
    IO.inspect(test_part1, label: "Part 1 Test")

    test_part2 = test_file |> Solver.part2()
    IO.inspect(test_part2, label: "Part 2 Test")

    # file = File.read!("input.txt") |> Solver.parse()
    #
    # real_part1 = file |> Solver.part1()
    # IO.inspect(real_part1, label: "Part 1 Real")
    #
    # real_part2 = file |> Solver.part2()
    # IO.inspect(real_part2, label: "Part 2 Real")
  end

  def t() do
    Task.async(fn -> Solver.run() end)
  end

  def trace(t) do
    Process.info(t.pid, :current_stacktrace)
  end
end
