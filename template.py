# Advent of Code 2023-12-
# @makaze

from icecream import ic

ic.configureOutput(includeContext=True)


def main():
    file = "test.txt"
    # file = "data.txt"
    with open(file) as f:
        s = f.read().split("\n")

    ic(part1(s))
    ic(part2(s))


def transpose(lst):
    return list(map(list, zip(*lst)))


def rotate(lst, n=1):
    a = lst[:]
    for _ in range(n):
        a = transpose(a)[::-1]
    return a


def part1(s):
    pass


def part2(s):
    pass


if __name__ == "__main__":
    main()
