# Advent of Code 2023-12-13
# @makaze

import colorama


def main():
    # file = "test.txt"
    file = "data.txt"
    with open(file) as f:
        s = f.read()

    s2 = s.replace("#", "1").replace(".", "0")
    s = [x.split() for x in s.split("\n\n")]
    s2 = [x.split() for x in s2.split("\n\n")]

    print(f"Part 1:", p1(s))
    print(f"Part 2:", p2(s2))


# def transpose(lst):
#     return ["".join(list(x)) if type(lst[0]) is str else list(x) for x in zip(*lst)]


def transpose(lst):
    return [list(x) for x in zip(*lst)]


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


def mirror(lines, t="rows", check_smudge=False):
    step = 1
    start = int(len(lines) / 2)
    start -= 1 if step < 0 else 0  # Adjust for assymetry
    stop = len(lines) - 1 if step >= 0 else 0
    smudges = 0

    for pos in range(0, len(lines) - 1):
        d = 0
        try:
            before = pos
            smudges = bin_diff(lines[pos], lines[pos + 1]) if check_smudge else 1
            while before >= 0 and (lines[pos - d] == lines[pos + (1 + d)]):
                d += 1
                smudges += bin_diff(lines[pos], lines[pos + 1]) if check_smudge else 0
                before = pos - d
                if before < 0:
                    if check_smudge:
                        if smudges == 1:
                            raise IndexError
                    else:
                        raise IndexError
            print(f"{smudges=}")
        except IndexError:
            if check_smudge and smudges != 1:
                return 0
            print(f"The reflection is between {t} {pos+1} and {pos+2} of {len(lines)}")
            return pos + 1
    return 0


def p1(patterns):
    r = 0
    c = 0
    results = []

    for i, pattern in enumerate(patterns):
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
            c += this
            found = True
            results.append(this)

        if not found:
            print
            (f"=================!\nNo solution found! {i+1}")
            break

    print(f"{len(results)}")

    return c + (r * 100)


def bin_diff(a, b):
    a = int("".join([str(x) for x in a]), 2) if type(a) is not int else a
    b = int("".join([str(x) for x in b]), 2) if type(b) is not int else b
    count = 0
    for i in range(32):  # Length of int
        if ((a >> i) & 1) != ((b >> i) & 1):  # Check if bit i is mismatched
            print(f"{a=}, {b=}, {bin(a)=}, {bin(b)=}, {i=}")
            count += 1
    return count


def p2(patterns):
    r = 0
    c = 0
    results = []

    for i, pattern in enumerate(patterns):
        # Convert to binary
        binary = [[int(line, 2) for line in lines] for lines in pattern]
        rows = [line for line in binary]
        columns = [line for line in transpose(binary)]

        found = False
        lines = rows
        this = mirror(lines, "rows", True)
        if this:
            r += this
            found = True
            results.append(this)
            print("\nPattern #", i + 1, "\n")
            print_mirror(pattern, this - 1, "rows")

        lines = columns
        this = mirror(lines, "columns", True)
        if this:
            c += this
            found = True
            results.append(this)
            print("\nPattern #", i + 1, "\n")
            print_mirror(pattern, this - 1, "columns")

        if not found:
            print(f"=================!\nNo solution found! {i+1}")
            break

    print(f"{len(results)}")

    return c + (r * 100)


if __name__ == "__main__":
    main()
