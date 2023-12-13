# Advent of Code 2023-12-12
# @makaze

import colorama
from enum import IntFlag
from typing import List


def highlight(s, x, length=1):
    return (
        s[:x]
        + colorama.Fore.RED
        + s[x : x + length]
        + colorama.Fore.RESET
        + s[(x + length) + (0 if x else 1) :]
    )


def main():
    with open("test.txt") as f:
        # with open("data.txt") as f:
        s = f.read().split("\n")

    print(f"Part 1:", p1(s))
    print(f"Part 2:", p2(s))


class Block:
    def __init__(self, width=1, min_start=0, max_start=0):
        self.width: int = width
        self.min_start: int = min_start
        self.max_start: int = max_start
        self.known: set = set()  # Coordinates known to be a part of this block

    def force(self, n):
        if n > 0:
            self.min_start += n
        else:
            self.max_start -= n
        return self

    def set(self, x):
        self.known.add(x)
        return self

    def solved(self):
        return len(self.known) == self.width

    def __str__(self):
        return f"{self.width}"

    def __repr__(self):
        return str(self)


class Nono:
    STATE = IntFlag("State", ("BLOCK", "EMPTY", "UNFILLED"))
    SYMBOL = {"#": STATE.BLOCK, ".": STATE.EMPTY, "?": STATE.UNFILLED}
    SYMBOL |= {val: key for key, val in SYMBOL.items()}

    def __init__(self, string: str):
        string: List[str] = string.split()
        self.original: str = string[0]
        self.width: int = len(self.original)
        self.sizes: List[int] = list(map(int, string[1].split(",")))
        self.blocks: List[Block] = list(map(Block, self.sizes))
        self.fill_amount: int = self.width - (sum(self.sizes) + len(self.sizes) - 1)

        for i, block in enumerate(self.blocks):  # From the left
            s = self.sizes[:i]
            if i > 1:
                block.min_start = sum(s) + len(s) - 1

        r = self.blocks[:]
        r.reverse()
        for i, block in enumerate(r):  # From the right
            s = self.sizes[:i]
            if i > 1:
                block.max_start = block.width + sum(s) + len(s) - 1

        self.state = self.make_list()
        self.first_fill()

    def first_fill(self):
        pos = 0
        new = self.state[:]
        if not any(b > self.fill_amount for b in self.sizes):
            return False
        for block in self.blocks:
            contd = False
            if block.width - self.fill_amount <= 0:
                pos += block.width + 1
                # print(f"\nSkipping small {block.width=} as {pos=} for {self.fill_amount=}")
                # contd = True
                continue
            print(contd)
            pos += self.fill_amount
            for i in range(block.width - self.fill_amount):
                # print(
                #     f"\n{pos=}\n{block.width=}\nself={highlight(self.original,pos,1)}\n{new[-1]=}\n{self.fill_amount=}\n{self.sizes=}\n{sum(self.sizes)=}\n{self.width=}"
                # )
                if self.state[pos] & Nono.STATE.EMPTY:
                    raise TypeError("Contradiction with empty space")
                new[pos] = Nono.STATE.BLOCK
                pos += 1
            pos += 1
        self.state = new

    def force_and_glue(self, reverse: bool = False):
        s = self.state[:]
        if reverse:
            s.reverse()
            first, last = self.sizes[-1], self.sizes[0]
        else:
            first, last = self.sizes[0], self.sizes[-1]

        start = 0
        empties = [i for i, x in enumerate(s) if x & Nono.STATE.EMPTY]

        for e in empties:
            if e < start + first:
                start += e + (1 if reverse else 0)
            else:
                break

        fulls = [
            i
            for i, x in enumerate(s)
            if x & Nono.STATE.BLOCK and start <= i < start + first
        ]

        if fulls:
            for i in range((start + first) - fulls[0]):
                s[i] = Nono.STATE.BLOCK
                self.blocks[0].set(i)

    def simple(self):
        simple = [
            [Nono.STATE.BLOCK] * x
            + ([Nono.STATE.EMPTY] if i < len(self.sizes) - 1 else [])
            for i, x in enumerate(self.sizes)
        ]
        min_start, push, pull = 0

        fulls = [i for i, x in enumerate(self.state) if x & Nono.STATE.BLOCK]
        empties = [i for i, x in enumerate(self.state) if x & Nono.STATE.EMPTY]

        pull += max(fulls[i] - (min_start + self.sizes[i] - 1), 0)
        push = (empties[i] + 1) if min_start <= empties[i] < self.sizes[i] else push
        for i, full in fulls:
            if fulls[i] < empties[i]:
                min_start = fulls[i] - (len(self.sizes[i]) - 1)
            else:
                pass

    def combinations(self, search_width):
        if search_width > self.width:
            return 0
        elif search_width < self.width:
            return self.width - search_width

    def make_list(self, string=""):
        state = []
        if not string:
            string = self.original
        for c in string:
            state.append(Nono.SYMBOL[c])
        return state

    def __str__(self):
        return "".join([Nono.SYMBOL[s] for s in self.state])

    def __repr__(self):
        return str(self)


def p1(s):
    nonos = [Nono(line) for line in s]

    print([(n.blocks, n.fill_amount, n.original) for n in nonos])

    return list(map(str, nonos))


def p2(s):
    pass


if __name__ == "__main__":
    main()
