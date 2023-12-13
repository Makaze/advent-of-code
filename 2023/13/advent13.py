# Advent of Code 2023-12-13
# @makaze


def main():
    # with open("test.txt") as f:
    with open("data.txt") as f:
        s = f.read()

    # s = s.replace("#", "1").replace(".", "0")
    s = list(map(str.split, s.split("\n\n")))

    print(f"Part 1:", p1(s))
    print(f"Part 2:", p2(s))


def transpose(lst):
    return [list(x) for x in zip(*lst)]


def print_mirror(lines, pos, type):
    lines = (
        lines if type == "rows" else list(map(lambda x: "".join(x), transpose(lines)))
    )

    for y, line in enumerate(lines):
        if y < 1:
            print("")
        if type == "columns":
            for x, char in enumerate(line):
                if y < 1:
                    print(x + 1, end="")
                print(char, end=" ")
                if x == pos:
                    print("|", end=" ")
            print()
        else:
            print(line)
            if y == pos:
                print("-" * len(line))


def mirror(lines, type):
    for step in [1, -1]:
        start = int(len(lines) / 2)
        start -= 1 if step < 0 else 0  # Adjust for assymetry
        stop = len(lines) - 1 if step >= 0 else 0

        for pos in range(start, stop, step):
            d = 0
            try:
                while lines[pos - d] == lines[pos + 1 + d]:
                    d += 1
            except IndexError:
                print(
                    f"The reflection is between {type} {pos+1} and {pos+2} of {len(lines)}"
                )
                print_mirror(lines, pos, type)
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

        lines = columns
        this = mirror(lines, "columns")
        if this:
            r += this
            found = True
            results.append(this)

        if not found:
            print(f"=================!\nNo solution found! {i+1}")
            break

    return c + (r * 100)


def p2(s):
    pass


if __name__ == "__main__":
    main()
