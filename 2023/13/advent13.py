# Advent of Code 2023-12-13
# @makaze

import colorama


def main():
    # with open("test.txt") as f:
    with open("data.txt") as f:
        s = f.read()

    # s = s.replace("#", "1").replace(".", "0")
    s = list(map(str.split, s.split("\n\n")))

    print(f"Part 1:", p1(s))
    print(f"Part 2:", p2(s))


def transpose(lst):
    return ["".join(list(x)) if type(lst[0]) is str else list(x) for x in zip(*lst)]


def print_mirror(lines, pos, t):
    # lines = lines if t == "rows" else list(map(lambda x: "".join(x), transpose(lines)))

    for y, line in enumerate(lines):
        if y < 1:
            print("")
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


def mirror(lines, t):
    step = 1
    start = int(len(lines) / 2)
    start -= 1 if step < 0 else 0  # Adjust for assymetry
    stop = len(lines) - 1 if step >= 0 else 0

    for pos in range(0, len(lines) - 1):
        d = 0
        try:
            before = pos - d
            while before >= 0 and lines[pos - d] == lines[pos + (1 + d)]:
                d += 1
                before = pos - d
                if before < 0:
                    raise IndexError
        except IndexError:
            print(f"The reflection is between {t} {pos+1} and {pos+2} of {len(lines)}")
            return pos + 1
    return 0


def p1(patterns):
    r = 0
    c = 0
    results = []

    for i, pattern in enumerate(patterns):
        # Convert to binary
        rows = [line for line in pattern]
        columns = [line for line in transpose(pattern)]

        found = False
        lines = rows
        this = mirror(lines, "rows")
        if this:
            r += this
            found = True
            results.append(this)
            print("\nPattern #", i + 1, "\n")
            print_mirror(rows, this, "rows")

        lines = columns
        this = mirror(lines, "columns")
        if this:
            r += this
            found = True
            results.append(this)
            print("\nPattern #", i + 1, "\n")
            print_mirror(columns, this, "rows")

        if not found:
            print(f"=================!\nNo solution found! {i+1}")
            break

    print(f"{len(results)}")

    return c + (r * 100)


def p2(s):
    pass


if __name__ == "__main__":
    main()
