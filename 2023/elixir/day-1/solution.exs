defmodule Solver do
  @names %{
    "zero" => "0o",
    "one" => "o1e",
    "two" => "t2o",
    "three" => "t3e",
    "four" => "4",
    "five" => "5e",
    "six" => "6",
    "seven" => "7n",
    "eight" => "e8t",
    "nine" => "n9e"
  }

  defp digit?(char) do
    char in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
  end

  def replace(line) do
    Enum.reduce(@names, line, fn {p, r}, acc ->
      String.replace(acc, p, r)
    end)
    |> String.graphemes()
  end

  def value(line) do
    line =
      case line do
        x when is_binary(x) -> String.graphemes(x)
        x -> x
      end

    first =
      line
      |> Enum.find(&digit?/1)

    last =
      line
      |> Enum.reverse()
      |> Enum.find(&digit?/1)

    (first <> last) |> String.to_integer()
  end
end

stream1 =
  File.stream!("input.txt")
  |> Stream.map(&Solver.value/1)

stream2 =
  File.stream!("input.txt")
  |> Stream.map(&Solver.replace/1)
  |> Stream.map(&Solver.value/1)

sum1 = Enum.sum(stream1)
sum2 = Enum.sum(stream2)
IO.puts("Part 1: #{sum1}")
IO.puts("Part 2: #{sum2}")
