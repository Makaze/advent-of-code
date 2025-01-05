Mix.install([
  {:nimble_parsec, "~> 1.4"}
])

defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2024/day/15
  """

  def put_data(key, val) do
    cache_table = :day15_data

    if :ets.info(cache_table) == :undefined do
      :ets.new(cache_table, [:named_table, :public, :set])
    end

    :ets.insert(cache_table, {key, val})
    val
  end

  def get_data(key) do
    cache_table = :day15_data

    if :ets.info(cache_table) == :undefined do
      :ets.new(cache_table, [:named_table, :public, :set])
    end

    case :ets.lookup(cache_table, key) do
      [{^key, val}] ->
        val

      [] ->
        nil
    end
  end

  import NimbleParsec

  def row_from(chars) do
    chars
    |> Enum.map(fn
      "#" -> :wall
      "." -> :empty
      "O" -> :box
      "@" -> :robot
    end)
  end

  def moves_from(chars) do
    chars
    |> Enum.map(fn
      "^" -> :up
      "v" -> :down
      "<" -> :left
      ">" -> :right
    end)
  end

  def map_from2(data) do
    [{moves, _} | data] = data |> Enum.with_index() |> Enum.reverse()

    data =
      data
      |> Enum.reduce(%{}, fn {line, row}, acc ->
        line
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {char, col}, inner_acc ->
          coord = [row, col * 2]
          doubled = [row, col * 2 + 1]

          inner_acc =
            case char do
              :robot -> put_in(inner_acc[:robot], coord)
              _ -> inner_acc
            end

          case char do
            :robot ->
              inner_acc = put_in(inner_acc[coord], char)
              put_in(inner_acc[doubled], :empty)

            :box ->
              inner_acc = put_in(inner_acc[coord], :left_box)
              put_in(inner_acc[doubled], :right_box)

            _ ->
              inner_acc = put_in(inner_acc[coord], char)
              put_in(inner_acc[doubled], char)
          end
        end)
      end)

    {data, moves}
  end

  anything = ignore(utf8_char([]))
  whitespace = ignore(utf8_char([?\n, ?\r]))
  wall = string("#")
  box = string("O")
  robot = string("@")
  empty = string(".")

  grid_row =
    choice([empty, wall, box, robot])
    |> repeat(choice([empty, wall, box, robot]))
    |> reduce({__MODULE__, :row_from, []})

  moves =
    choice([string("^"), string("v"), string("<"), string(">")])
    |> repeat(choice([string("^"), string("v"), string("<"), string(">"), whitespace]))
    |> reduce({__MODULE__, :moves_from, []})

  defparsec(
    :parse2,
    repeat(
      choice([
        grid_row,
        whitespace,
        moves
      ])
    )
    |> reduce({__MODULE__, :map_from2, []})
  )

  def shift(coord, offset), do: Enum.zip(coord, offset) |> Enum.map(fn {a, b} -> a + b end)

  def move(:down, coord), do: shift(coord, [1, 0])
  def move(:up, coord), do: shift(coord, [-1, 0])
  def move(:right, coord), do: shift(coord, [0, 1])
  def move(:left, coord), do: shift(coord, [0, -1])
  def move(_, coord), do: coord

  def shove(:wall, dir, _last_type, _coord, new_coord), do: {:err, %{new_coord => :wall}}
  def shove(:empty, dir, last_type, coord, new_coord), do: {:ok, %{new_coord => last_type}}

  # def shove(:robot, dir, _last_type, coord, new_coord) do
  #   data = get_data(:data)
  #   future = shove(data[new_coord], dir, :robot, coord, new_coord)
  # end

  def shove(:left_box, dir, last_type, [oy, ox] = coord, [y, x] = left)
      when dir in [:up, :down] do
    data = get_data(:data)
    right = [y, x + 1]
    last_right_type = data[[oy, ox + 1]]

    maybe =
      case last_type do
        :left_box -> %{left => last_type}
        _ -> %{left => last_type, right => :empty}
      end

    next_left = move(dir, left)
    next_right = move(dir, right)

    future_left = shove(data[next_left], dir, :left_box, left, next_left)
    future_right = shove(data[next_right], dir, :right_box, right, next_right)

    case {future_left, future_right} do
      {{:err, _}, _} ->
        {:err, maybe}

      {_, {:err, _}} ->
        {:err, maybe}

      {{:ok, lmap}, {:ok, rmap}} ->
        {:ok, Map.merge(lmap, rmap) |> Map.merge(maybe)}
    end
  end

  def shove(:right_box, dir, last_type, [oy, ox] = coord, [y, x] = right)
      when dir in [:up, :down] do
    data = get_data(:data)
    left = [y, x - 1]
    last_left_type = data[[oy, ox - 1]]

    maybe =
      case last_type do
        :right_box -> %{right => last_type}
        _ -> %{right => last_type, left => :empty}
      end

    next_left = move(dir, left)
    next_right = move(dir, right)

    future_left = shove(data[next_left], dir, :left_box, left, next_left)
    future_right = shove(data[next_right], dir, :right_box, right, next_right)

    case {future_left, future_right} do
      {{:err, _}, _} ->
        {:err, maybe}

      {_, {:err, _}} ->
        {:err, maybe}

      {{:ok, lmap}, {:ok, rmap}} ->
        {:ok, Map.merge(lmap, rmap) |> Map.merge(maybe)}
    end
  end

  def shove(new_type, dir, last_type, coord, new_coord) do
    data = get_data(:data)
    maybe = %{new_coord => last_type}
    next = move(dir, new_coord)
    future = shove(data[next], dir, new_type, new_coord, next)

    case future do
      {:ok, map} -> {:ok, Map.merge(map, maybe)}
      {:err, _} -> future
    end
  end

  defp print(data, {h, w}) do
    p =
      for y <- 0..(h - 1) do
        for x <- 0..(w - 1) do
          case data[[y, x]] do
            :wall -> "#"
            :empty -> "."
            :box -> "O"
            :left_box -> "["
            :right_box -> "]"
            :robot -> "@"
          end
        end
        |> Enum.join("")
      end
      |> Enum.join("\n")

    IO.puts(p)
  end

  def part2({:ok, [{data, move_list}], _, _, _, _}, {h, w}) do
    put_data(:data, data)

    print(data, {h, w})

    end_map =
      move_list
      |> Enum.reduce(data, fn dir, acc ->
        new_bot = move(dir, acc.robot)
        maybe = %{new_bot => :robot, acc.robot => :empty, robot: new_bot}

        future =
          shove(
            :robot,
            dir,
            nil,
            acc.robot,
            acc.robot
          )

        new_data =
          case future do
            {:ok, map} ->
              Map.merge(acc, map) |> Map.merge(maybe)

            {:err, _} ->
              acc
          end

        put_data(
          :data,
          new_data
        )
      end)

    print(end_map, {h, w})

    end_map
    |> Enum.map(fn
      {[y, x], :left_box} -> y * 100 + x
      _ -> 0
    end)
    |> Enum.sum()
  end
end

test_file =
  File.read!("test.txt")

file =
  File.read!("input.txt")

IO.inspect(test_file |> Solver.parse2() |> Solver.part2({10, 20}), label: "Part 2 Test")
IO.inspect(file |> Solver.parse2() |> Solver.part2({50, 100}), label: "Part 2 Real")
