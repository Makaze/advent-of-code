# Advent of Code 2023-12-08
# @makaze

import re


def main():
    # with open("test.txt") as f:
    with open("data.txt") as f:
        s = f.read()

    s = s.split("\n")
    instructs = s[0]
    nodes = {sep[0]: (sep[1], sep[2]) for sep in [re.split(r"\W+", x) for x in s[2:]]}

    next = "AAA"  # Start

    steps = 0

    while next != "ZZZ":
        node = nodes[next]
        step = instructs[steps % len(instructs)]
        print(f"{next} = {node}, {step=}")
        next = node[0] if step == "L" else node[1]
        steps += 1

    print(f"Steps: {steps}")


if __name__ == "__main__":
    main()
