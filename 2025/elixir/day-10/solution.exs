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
      bfs(:queue.in(start, :queue.new()), goal?, MapSet.new([]), nil, neighbors)
    end
  end

  def bfs(queue, goal?, explored, prev, neighbors) do
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

            bfs(queue, goal?, explored, node, neighbors)
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

  defstruct goal: %{}, state: %{}, buttons: [], joltages: %{}

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
  @spec constraints(diagram()) :: list({integer(), list(integer()), integer()})
  def constraints(%Diagram{buttons: buttons} = d) do
    m = 0..(map_size(d.joltages) - 1) |> Range.to_list() |> Map.from_keys([])

    {m, touches} =
      buttons
      |> Enum.with_index()
      |> Enum.reduce({m, m}, fn {el, index}, {m_acc, touches_acc} ->
        el
        |> Enum.reduce({m_acc, touches_acc}, fn i, {m_inner_acc, touches_inner_acc} ->
          {Map.update(m_inner_acc, i, [], &[index | &1]),
           Map.update(touches_inner_acc, index, [], &[i | &1])}
        end)
      end)

    # m
    # |> Enum.map(fn {k, v} ->
    #   {k,
    #    v
    #    |> Enum.sort(fn a, b ->
    #      length(Enum.at(buttons, a)) > length(Enum.at(buttons, b))
    #    end), Map.get(d.joltages, k)}
    # end)
    # |> Enum.sort(fn a, b ->
    #   length(elem(a, 1)) <= length(elem(b, 1)) and elem(a, 2) <= elem(b, 2)
    # end)
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
      Diagram.constraints(d)
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
