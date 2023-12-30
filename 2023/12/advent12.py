# Advent of Code 2023-12-12
# @makaze

from functools import cache
from icecream import ic

ic.configureOutput(includeContext=True)


def main():
    # file = "test.txt"
    file = "data.txt"
    with open(file) as f:
        s = f.read().split("\n")

    ic(p1(s))
    ic(p2(s))


def count_solutions(record: str, groups: tuple[int, ...]) -> int:
    if not record:
        # Must be exactly 1 if groups is empty, otherwise 0
        return len(groups) == 0

    if not groups:
        # Must be exactly 1 if there are no more blocks (#) within the record,
        # otherwise 0
        return "#" not in record

    char, rest = record[0], record[1:]

    if char == ".":
        # Move on with rest
        return count_solutions(rest, groups)

    if char == "#":
        g = groups[0]
        # Group found
        if (
            len(record) >= g  # long enough to match
            and all(c != "." for c in record[:g])  # has no .
            and (
                len(record) == g or record[g] != "#"
            )  # Next char after group cannot be another #
        ):
            # Continue with next group
            return count_solutions(record[g + 1 :], groups[1:])

        return 0  # Matching is imppssible

    if char == "?":
        # Get the sum with both possibilities (. and #)
        return count_solutions(f"#{rest}", groups) + count_solutions(f".{rest}", groups)

    raise ValueError(f"Invalid char: {char}")


def possible_nonos(nono: str, with_multi=False) -> int:
    record, raw = nono.split()
    blocks = tuple(map(int, raw.split(",")))

    if with_multi:
        record = "?".join([record] * 5)

    return count_solutions(record, blocks)


def p1(s):
    return sum(possible_nonos(r) for r in s)


def p2(s):
    return sum(possible_nonos(r, with_multi=True) for r in s)


if __name__ == "__main__":
    main()
