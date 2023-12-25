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


def part1(s):
    solution = None
    frontier = [
        (0, 0, 0, 0, 0, 0)
    ]  # Heat loss, Current y, Current x, Change in y, Change in x, Prev steps in same dir
    explored = set()

    while frontier:
        node = heappop(frontier)
        heat_loss, y, x, dy, dx, prev_dir = node
        state = (y, x, dy, dx, prev_dir)

        if (y, x) == (len(s) - 1, len(s[0]) - 1):
            return heat_loss

        if state in explored:
            continue

        explored.add(state)

        if prev_dir < 3 and (dy, dx) != (0, 0):
            new_y = y + dy
            new_x = x + dx

            if 0 <= new_y < len(s) and 0 <= new_x < len(s[0]):
                heappush(
                    frontier,
                    (heat_loss + s[new_y][new_x], new_y, new_x, dy, dx, prev_dir + 1),
                )

        for new_dy, new_dx in [(1, 0), (-1, 0), (0, -1), (0, 1)]:
            if (new_dy, new_dx) in [(dy, dx), (-dy, -dx)]:
                continue
            new_y = y + new_dy
            new_x = x + new_dx

            if 0 <= new_y < len(s) and 0 <= new_x < len(s[0]):
                heappush(
                    frontier,
                    (heat_loss + s[new_y][new_x], new_y, new_x, new_dy, new_dx, 1),
                )


def part2(s):
    pass


if __name__ == "__main__":
    main()
