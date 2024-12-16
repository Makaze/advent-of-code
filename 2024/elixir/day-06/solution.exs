defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2024/day/4
  """

  @turns %{n: :e, s: :w, e: :s, w: :n}
  @dir_map %{"^" => :n, "v" => :s, ">" => :e, "<" => :w}

  defp jump_points(nil), do: %{n: nil, s: nil, e: nil, w: nil}

  @doc """
  Returns a map of jump points around this block when coming from each direction.
  """
  defp jump_points([row, col]) do
    %{
      n: [row - 1, col],
      s: [row + 1, col],
      e: [row, col + 1],
      w: [row, col - 1]
    }
  end

  @doc """
  Returns a map of jump locations from this block, so far.
  """
  def get_jumps(dir, map, [row, col]) do
    new_dir = @turns[dir]

    case new_dir do
      :n -> get_in(map[:col_history][col])
      :w -> get_in(map[:row_history][row])
      _ -> nil
    end
  end

  def parse(input) do
    data = %{
      jumps: %{},
      row_history: %{},
      col_history: %{},
      origin: nil,
      height: Enum.count(input),
      width: Enum.count(String.graphemes(Enum.at(input, 0)))
    }

    input
    |> Enum.with_index()
    |> Enum.reduce(data, fn {line, row}, acc ->
      line
      |> String.trim()
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn
        {"#", col}, new_acc ->
          coord = [row, col]
          points = jump_points(coord)

          IO.inspect(points, label: "Jumps for #{row}, #{col}")

          new_acc =
            Enum.reduce(points, new_acc, fn {key, [jrow, jcol] = val}, x ->
              jumps = get_jumps(key, x, val)
              x = put_in(x[:jumps][val], jumps)

              IO.inspect(get_in(x[:col_history][jcol]), label: "Col history")
              IO.inspect(get_in(x[:row_history][jrow]), label: "Row history")
              IO.inspect(get_in(x[:jumps]))

              # Update jumps from obstacles to the north and west
              x =
                case {jumps, key} do
                  {nil, _} -> x
                  {v, :n} -> put_in(x[:jumps][v], val)
                  {v, :w} -> put_in(x[:jumps][v], val)
                  _ -> x
                end
            end)

          # Update last in this col and row
          new_acc = put_in(new_acc[:row_history][row], points[:e])
          new_acc = put_in(new_acc[:col_history][col], points[:s])

        {dir, col}, new_acc when dir in ["^", "v", "<", ">"] ->
          coord = [row, col]

          dir = @dir_map[dir]

          jumps = get_jumps(dir, new_acc, coord)
          new_acc = put_in(new_acc[:jumps][coord], jumps)

          put_in(new_acc[:origin], %{coord: coord, dir: dir})

        _, new_acc ->
          new_acc
      end)
    end)
  end

  def patrol(data, last \\ nil, distance \\ 0)

  def patrol(data, nil, 0) do
    patrol(data, data[:origin], 0)
  end

  def patrol(data, last, distance) do
    next = get_in(data[:jumps][last[:coord]])

    case next do
      nil ->
        to_edge =
          case last[:dir] do
            :n -> get_in(last[:coord][1])
            :s -> get_in(data[:height]) - get_in(last[:coord][1])
            :e -> get_in(last[:coord][0])
            :w -> get_in(data[:width]) - get_in(last[:coord][0])
          end

        distance + to_edge

      jump ->
        new_dir = get_in(@turns[last[:dir]])
    end
  end

  def part1({_data, map}) do
    Map.get(map, :x)
    |> Enum.sum()
  end

  def part2({_data, map}) do
    Map.get(map, :a)
    |> Enum.sum()
  end
end

test_file =
  File.read!("test.txt")
  |> String.split(~r/\s+/, trim: true)
  |> Solver.parse()

file =
  File.read!("input.txt")
  |> String.split(~r/\s+/, trim: true)
  |> Solver.parse()

IO.inspect(test_file)

# IO.inspect(Solver.part1(test_file), label: "Part 1 Test")
# IO.inspect(Solver.part1(file), label: "Part 1 Real")
# IO.inspect(Solver.part2(test_file), label: "Part 2 Test")
# IO.inspect(Solver.part2(file), label: "Part 2 Real")
