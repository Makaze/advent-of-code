# Advent of Code 2023-12-13
# @makaze

import colorama


def main():
    file = "test.txt"
    file = "data.txt"
    with open(file) as f:
        s = f.read()

    s = [x.split() for x in s.split("\n\n")]

    print(f"Part 1:", solve(s))
    print(f"Part 2:", solve(s, True))


def print_mirror(lines, pos, t):
    lines = lines if t == "rows" else list(map(lambda x: "".join(x), transpose(lines)))

    for y, line in enumerate(lines):
        if t == "columns":
            for x, char in enumerate(line):
                print(char, end="")
                if x == pos:
                    print(colorama.Fore.RED + "|" + colorama.Fore.RESET, end="")
            print()
        else:
            print(line)
            if y == pos:
                print(colorama.Fore.RED + ("-" * len(line)) + colorama.Fore.RESET)

    print(f"\nFrom {pos+1}-{pos+2}\n")


def transpose(lst):
    return [list(x) for x in zip(*lst)]


def bin_diff(a, b):
    a = (
        int("".join([str(x).replace("#", "1").replace(".", "0") for x in a]), 2)
        if type(a) is not int
        else a
    )
    b = (
        int("".join([str(x).replace("#", "1").replace(".", "0") for x in b]), 2)
        if type(b) is not int
        else b
    )
    count = 0
    for i in range(32):  # Length of int
        if ((a >> i) & 1) != ((b >> i) & 1):  # Check if bit i is mismatched
            count += 1
    return count


def mirror(lines, t="rows", smudged=False):
    for pos in range(0, len(lines) - 1):
        d = 0
        try:
            before = pos
            after = pos + (1 + d)
            lines_equal = lines[before] == lines[after]
            smudges = bin_diff(lines[before], lines[after]) if smudged else 0
            while before >= 0 and (lines_equal or smudges == 1):
                d += 1
                before = pos - d
                after = pos + (1 + d)
                lines_equal = lines[before] == lines[after]
                if before < 0:
                    if smudged:
                        if smudges == 1:
                            raise IndexError
                        else:
                            break
                    raise IndexError
                smudges += bin_diff(lines[before], lines[after]) if smudged else 0
        except IndexError:
            if smudged and smudges != 1:
                return 0
            return pos + 1
    return 0


def solve(patterns, smudged=False):
    r = 0
    c = 0

    for i, pattern in enumerate(patterns):
        rows = [line for line in pattern]
        columns = [line for line in transpose(pattern)]

        if this := mirror(rows, "rows", smudged):
            r += this

        if this := mirror(columns, "columns", smudged):
            c += this

    return c + (r * 100)


if __name__ == "__main__":
    main()
