defmodule Solver do
  @moduledoc """
  https://adventofcode.com/2024/day/6
  """

  @turns %{n: :e, s: :w, e: :s, w: :n}
  @dir_map %{"^" => :n, "v" => :s, ">" => :e, "<" => :w}

  def jump_points(nil), do: %{n: nil, s: nil, e: nil, w: nil}

  @doc """
  Returns a map of jump points around this block when coming from each direction.
  """
  def jump_points([row, col]) do
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
      origin: nil,
      height: Enum.count(input),
      width: Enum.count(String.graphemes(Enum.at(input, 0))),
      distance: MapSet.new([])
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

          put_in(new_acc[:jumps][coord], :block)

        {dir, col}, new_acc when dir in ["^", "v", "<", ">"] ->
          coord = [row, col]

          dir = @dir_map[dir]

          new_acc = put_in(new_acc[:jumps][coord], dir)

          put_in(new_acc[:origin], %{coord: coord, dir: dir})

        _, new_acc ->
          new_acc
      end)
    end)
  end

  defp next(map, dir, coord) do
    width = map.width
    height = map.height
    points = jump_points(coord)

    case points[dir] do
      [-1, _col] ->
        :edge

      [_row, -1] ->
        :edge

      [^height, _col] ->
        :edge

      [_row, ^width] ->
        :edge

      val ->
        p = get_in(map[:jumps][val])

        case p do
          :block ->
            {coord, :block}

          _ ->
            d = MapSet.member?(map[:distance], {dir, val})

            if d do
              {:loop, coord}
            else
              {val, nil}
            end
        end
    end
  end

  def patrol(data, dir \\ nil, next \\ nil, visited \\ nil, map_fn \\ &map_only/3)

  def patrol(data, nil, nil, nil, map_fn) do
    origin = get_in(data[:origin])
    new_distance = map_fn.(MapSet.new([]), {origin.dir, origin.coord}, data)

    patrol(
      %{data | distance: new_distance},
      origin.dir,
      {origin.coord, nil},
      new_distance,
      map_fn
    )
  end

  def patrol(_data, _dir, :edge, distance, _map_fn), do: distance
  def patrol(_data, dir, {:loop, coord}, _distance, _map_fn), do: {:loop, coord}

  def patrol(data, dir, {coord, :block}, distance, map_fn) do
    new_dir = @turns[dir]
    # IO.inspect({dir, new_dir}, label: "Turn")
    patrol(data, new_dir, {coord, nil}, distance, map_fn)
  end

  def patrol(data, dir, {coord, nil}, distance, map_fn) do
    new_distance = map_fn.(distance, {dir, coord}, data)
    patrol(%{data | distance: new_distance}, dir, next(data, dir, coord), new_distance, map_fn)
  end

  def map_only(distance, {_dir, coord}, _data), do: MapSet.put(distance, {coord})

  def map_with_dir(distance, {dir, coord}, data) do
    MapSet.put(distance, {dir, coord})
  end

  def part1(map) do
    patrol(map, nil, nil, nil, &map_only/3)
    |> Enum.count()
  end

  def part2(map) do
    distances = patrol(map, nil, nil, nil, &map_with_dir/3)

    distances
    |> Enum.map(fn
      {dir, coord} when coord != map.origin.coord ->
        test_map = put_in(map[:jumps][coord], :block)

        case patrol(test_map, nil, nil, nil, &map_with_dir/3) do
          {:loop, coord} -> coord
          _ -> 0
        end

      _ ->
        0
    end)
    |> MapSet.new()
    |> Enum.map(fn
      0 -> 0
      _ -> 1
    end)
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

IO.inspect(Solver.part1(test_file), label: "Part 1 Test")
IO.inspect(Solver.part1(file), label: "Part 1 Real")
IO.inspect(Solver.part2(test_file), label: "Part 2 Test")
IO.inspect(Solver.part2(file), label: "Part 2 Real")
