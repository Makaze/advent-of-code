# Advent of Code 2023-12-10
# @makaze

import colorama
from enum import IntFlag

colorama.init()

DIR = IntFlag("Dir", ["NORTH", "SOUTH", "EAST", "WEST"])
PIPES = {
    "|": DIR.NORTH | DIR.SOUTH,
    "-": DIR.EAST | DIR.WEST,
    "L": DIR.NORTH | DIR.EAST,
    "J": DIR.NORTH | DIR.WEST,
    "7": DIR.SOUTH | DIR.WEST,
    "F": DIR.EAST | DIR.SOUTH,
    ".": 0,
    "S": DIR.NORTH | DIR.SOUTH | DIR.EAST | DIR.WEST,
}
CHARS = {val: key for key, val in PIPES.items()}
MOVES = {DIR.NORTH: (-1, 0), DIR.SOUTH: (1, 0), DIR.EAST: (0, 1), DIR.WEST: (0, -1)}
OPPOSITES = {
    DIR.NORTH: DIR.SOUTH,
    DIR.SOUTH: DIR.NORTH,
    DIR.EAST: DIR.WEST,
    DIR.WEST: DIR.EAST,
}

explored = set()
start = ()
allowed_pipes = ["|"]
allowed_pipes = ["|", "F", "7", "L", "J", "S"]


def main():
    global outside
    # with open("test.txt") as f:
    with open("data.txt") as f:
        s = f.read().split("\n")

    print(f"Part 1:", p1(s))
    print(f"Part 2:", p2(s))


def p1(s):
    global start
    global explored
    global start_char

    lines = []
    max_distance = 0
    for i, line in enumerate(s):
        if "S" in line:
            start = (i, line.index("S"))
            explored.add(start)
        lines.append(list(map(lambda x: PIPES[x], line)))

    end, pos, distance, last_move = False, start, 0, (0, 0)

    while end != start:
        curr_pipe = lines[pos[0]][pos[1]]
        explored.add(pos)

        for dir, move in MOVES.items():
            next_pos = tuple(map(sum, zip(move, pos)))

            if dir & curr_pipe == 0:  # Pipe doesn't go that direction
                continue
            if not (0 <= next_pos[0] < len(lines)):  # Not in y range
                continue
            if not (0 <= next_pos[1] < len(lines[0])):  # Not in x range
                continue

            next_pipe = lines[next_pos[0]][next_pos[1]]

            if tuple(map(sum, zip(move, last_move))) == (0, 0):  # Going backwards
                continue
            if OPPOSITES[dir] & next_pipe == 0:  # Next pipe doesn't attach
                continue
            if next_pos == start and distance > 0:
                end, distance = start, distance + 1
                break
            if next_pos in explored:
                continue
            else:
                pos, distance, last_move = next_pos, distance + 1, move
                break

    if end == start:
        max_distance = int((distance + 1) / 2)

    return max_distance


def highlight(s, sel):
    y, x = sel
    lit = s.copy()
    lit[y] = (
        lit[y][: x - (1 if x else 0)]
        + colorama.Fore.RED
        + lit[y][x]
        + colorama.Fore.RESET
        + lit[y][(x if x else x + 1) :]
    )

    print()

    for line in lit:
        print(line)


def p2(s):
    global explored
    global start

    inside = set()
    last = None

    for y, line in enumerate(s):
        pipe_count = 0
        for x, char in enumerate(line):
            point = (y, x)
            line = list(line)

            if point in explored:
                line[x] = colorama.Fore.GREEN + line[x] + colorama.Fore.RESET
                if char in allowed_pipes:
                    if not last or PIPES[char] & last:
                        pipe_count += 1
                        last = DIR.NORTH if PIPES[char] & DIR.NORTH else DIR.SOUTH
                continue

            if pipe_count % 2 != 0:
                inside.add(point)
                line[x] = (
                    colorama.Fore.RED
                    + "\033[1m"
                    + "I"
                    + "\033[0m"
                    + colorama.Fore.RESET
                )
            else:
                line[x] = "O"

        print("".join(line))

    return len(inside)


if __name__ == "__main__":
    main()
