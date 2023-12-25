# Advent of Code 2023-12-17
# @makaze

from heapq import heappush, heappop
from icecream import ic

ic.configureOutput(includeContext=True)


def main():
    file = "test.txt"
    file = "data.txt"
    with open(file) as f:
        s = f.read().split("\n")
        s = [list(map(int, line)) for line in s]

    ic(part1(s))
    ic(part2(s))


def lowest_heat_loss(s, min_same_dir=1, max_same_dir=3):
    frontier = [(0, 0, 0, 0, 0, 0)]
    explored = set()

    while frontier:
        heat_loss, y, x, dy, dx, n = heappop(frontier)
        # Heat loss, Current y, Current x, Change in y, Change in x, Number of steps in same direction
        state = (y, x, dy, dx, n)

        if (y, x) == (len(s) - 1, len(s[0]) - 1):
            return heat_loss

        if state in explored:
            continue

        explored.add(state)

        new_n = max(1, min_same_dir - n)

        if n < max_same_dir and (dy, dx) != (0, 0):
            new_y = y + dy * new_n
            new_x = x + dx * new_n

            if 0 <= new_y < len(s) and 0 <= new_x < len(s[0]):
                heappush(
                    frontier,
                    (heat_loss + s[new_y][new_x], new_y, new_x, dy, dx, n + new_n),
                )

        for new_dy, new_dx in [(1, 0), (-1, 0), (0, -1), (0, 1)]:
            if (new_dy, new_dx) in [(dy, dx), (-dy, -dx)]:
                continue
            new_n = min_same_dir  # Reset to minimum for new direction
            new_y = y + new_dy * new_n
            new_x = x + new_dx * new_n

            if 0 <= new_y < len(s) and 0 <= new_x < len(s[0]):
                new_loss = heat_loss + sum(
                    s[y + new_dy * i][x + new_dx * i] for i in range(1, new_n + 1)
                )
                heappush(
                    frontier,
                    (new_loss, new_y, new_x, new_dy, new_dx, min_same_dir),
                )


def part1(s):
    return lowest_heat_loss(s)


def part2(s):
    return lowest_heat_loss(s, min_same_dir=4, max_same_dir=10)


if __name__ == "__main__":
    main()
