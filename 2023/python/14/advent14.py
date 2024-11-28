# Advent of Code 2023-12-14
# @makaze

from icecream import ic

ic.configureOutput(includeContext=True)


def main():
    file = "test.txt"
    file = "data.txt"
    with open(file) as f:
        s = f.read().split("\n")

    ic(part1(s))
    ic(part2(s))


def print_map(lines):
    for y, line in enumerate(lines):
        if type(line) is not str:
            for x, char in enumerate(line):
                print(char, end="")
            print()
        else:
            print(line)


def transpose(lst):
    return [list(x) if type(lst[0]) is list else "".join(x) for x in zip(*lst)]


def rotate(lst, n=1, clockwise=False):
    a = lst[:]
    for _ in range(n):
        if clockwise:
            a = transpose(a[::-1])
        else:
            a = transpose(a)[::-1]
    return a


def shift_line(line, x, empty="."):
    while x > 0 and line[x - 1] == empty:
        line = line[: x - 1] + line[x] + empty + line[x + 1 :]
        x -= 1
    return line


def part1(s):
    new_s = transpose(s)
    new_s, load = tilt_map(new_s)

    return load


def tilt_map(new_s, move=True):
    new_s = new_s[:]
    load = 0
    for y, line in enumerate(new_s):
        new_line = line[:]
        if move:
            for x, char in enumerate(new_line):
                if char == "O":
                    new_line = shift_line(new_line, x)
            new_s[y] = new_line
        for x, char in enumerate(new_line):
            if char == "O":
                load += len(new_line) - x

    return new_s, load


def part2(s):
    states = dict()
    states_by_cycle = dict()
    cycles_by_state = dict()
    new_s = s[:]

    new_s = rotate(new_s, 2, clockwise=True)  # Make left side == east

    loop_start = None
    loop_state = None

    for cycle in range(0, 10**9):
        for i in range(4):
            new_s = rotate(new_s, clockwise=True)
            new_s, load = tilt_map(new_s)
        north = rotate(new_s, 3)  # Get north
        west = rotate(new_s, 2)  # Get west (original orientation)
        north, north_load = tilt_map(north, move=False)

        state = "\n".join(west)
        if state in states:
            if loop_state == state:
                diff = cycle - loop_start
                return states[
                    states_by_cycle[((10**9 - loop_start) % (diff)) + loop_start - 1]
                ]
            elif not loop_state:
                loop_state = state
                loop_start = cycle
        states[state] = north_load
        states_by_cycle[cycle] = state
        cycles_by_state[state] = cycle


if __name__ == "__main__":
    main()
