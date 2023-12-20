# Advent of Code 2023-12-16
# @makaze

import colorama
from enum import IntFlag
from icecream import ic

ic.configureOutput(includeContext=True)


def main():
    file = "test.txt"
    file = "data.txt"
    with open(file) as f:
        s = f.read().split("\n")
        if not s or not s[0]:
            return None

    ic(part1(s))
    ic(part2(s))


def highlight(s):
    for y, line in enumerate(s):
        for char in NEW_CHARS.values():
            line = line.replace(char, colorama.Fore.RED + char + colorama.Fore.RESET)
        s[y] = line
    return s


def replaceAt(s, x, new_string):
    return s[:x] + new_string + s[x + len(new_string) :]


DIR = IntFlag("Dir", ["NORTH", "SOUTH", "EAST", "WEST"])
MIRRORS = {
    "|": {
        DIR.NORTH: 0,
        DIR.SOUTH: 0,
        DIR.EAST: DIR.NORTH | DIR.SOUTH,
        DIR.WEST: DIR.NORTH | DIR.SOUTH,
    },
    "-": {
        DIR.NORTH: DIR.EAST | DIR.WEST,
        DIR.SOUTH: DIR.EAST | DIR.WEST,
        DIR.EAST: 0,
        DIR.WEST: 0,
    },
    "/": {
        DIR.NORTH: DIR.EAST,
        DIR.SOUTH: DIR.WEST,
        DIR.EAST: DIR.NORTH,
        DIR.WEST: DIR.SOUTH,
    },
    "\\": {
        DIR.NORTH: DIR.WEST,
        DIR.SOUTH: DIR.EAST,
        DIR.EAST: DIR.SOUTH,
        DIR.WEST: DIR.NORTH,
    },
}
NEW_CHARS = {
    DIR.NORTH: "🠅",
    DIR.SOUTH: "🠇",
    DIR.EAST: "🠆",
    DIR.WEST: "🠄",
}


def reflect(pos, current_dir, char):
    next_dir = MIRRORS[char][current_dir]
    return [(pos, d) for d in DIR if d & next_dir]


def follow(data, energized, path, display):
    if not data:
        return None

    y, x = path[0]
    dir = path[1]
    char = data[y][x]

    if (y, x) == (0, 0) and char in MIRRORS and MIRRORS[char][dir]:
        dir = MIRRORS[char][dir]

    while (
        (y, x) == path[0]
        or char not in MIRRORS
        or (char in MIRRORS and not MIRRORS[char][dir])
    ):
        if display[y][x] not in MIRRORS.keys():
            display[y] = replaceAt(display[y], x, NEW_CHARS[dir])

        if dir & DIR.NORTH:
            if y <= 0:
                break
            y -= 1
        elif dir & DIR.SOUTH:
            if y >= len(data) - 1:
                break
            y += 1
        elif dir & DIR.EAST:
            if x >= len(data[0]) - 1:
                break
            x += 1
        elif dir & DIR.WEST:
            if x <= 0:
                break
            x -= 1
        energized.add((y, x))
        char = data[y][x]
    energized.add((y, x))

    if char in MIRRORS and MIRRORS[char][dir]:
        return reflect((y, x), dir, char)
    return None


def energize(s, start, dir):
    energized = set()  # Start in top left corner
    energized.add(start)
    paths = [(start, dir)]
    explored = set()
    display = s[:]

    cycles = 0

    while len(paths):
        cycles += 1
        path = paths.pop(0)  # BFS
        # path = paths.pop()  # DFS
        if path in explored:
            continue
        explored.add(path)
        if next := follow(s, energized, path, display):
            paths += next

    display = highlight(display)
    return len(energized), "\n".join(display)


def part1(s):
    start = (0, 0)  # y, x coord
    e, d = energize(s, start, DIR.EAST)
    print(d)
    return e


def part2(s):
    energies = set()
    for dir in DIR:
        if dir & DIR.NORTH:
            [
                energies.add(energize(s, (len(s) - 1, x), dir)[0])
                for x in range(len(s[0]))
            ]
        elif dir & DIR.SOUTH:
            [energies.add(energize(s, (0, x), dir)[0]) for x in range(len(s[0]))]
        elif dir & DIR.EAST:
            [energies.add(energize(s, (y, 0), dir)[0]) for y in range(len(s))]
        elif dir & DIR.WEST:
            [
                energies.add(energize(s, (y, len(s[0]) - 1), dir)[0])
                for y in range(len(s))
            ]

    return max(energies)


if __name__ == "__main__":
    main()
