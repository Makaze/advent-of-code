# Advent of Code 2023-12-15
# @makaze

from icecream import ic

ic.configureOutput(includeContext=True)


def main():
    file = "test.txt"
    file = "data.txt"
    with open(file) as f:
        s = f.read().split(",")

    ic(part1(s))
    ic(part2(s))


def hash(s):
    total = 0
    for c in s:
        total += ord(c)
        total *= 17
        total %= 256
    return total


def part1(s):
    return sum(hash(item) for item in s)


def part2(s):
    hashes = {n: dict() for n in range(256)}

    for i in s:
        label, length = i.split("=") if "=" in i else (i.replace("-", ""), None)
        h = hash(label)
        if length:
            hashes[h][label] = int(length)
        else:
            hashes[h].pop(label, None)

    return sum(
        (i + 1) * (j + 1) * label[1]
        for i, h in hashes.items()
        for j, label in enumerate(h.items())
        if h
    )


if __name__ == "__main__":
    main()
