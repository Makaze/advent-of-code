# Advent of Code 2023-12-12
# @makaze

import colorama
from enum import IntFlag
import math
from typing import List
from icecream import ic
from itertools import product, combinations
import re

ic.configureOutput(includeContext=True)
# ic.disable()


def highlight(s, x, length=1):
    return (
        s[:x]
        + colorama.Fore.RED
        + s[x : x + length]
        + colorama.Fore.RESET
        + s[(x + length) + (0 if x else 1) :]
    )


def consecutive_groups(lst):
    if not lst:
        return dict()
    start = lst[0]
    end = lst[0]
    result = {start: 1}
    l = 1
    for i, num in enumerate(lst[1:]):
        if num == end + 1:
            l += 1
        else:
            result[start] = l
            start = num
            l = 1
        end = num
    result[start] = l
    return result


def main():
    # file = "test.txt"
    file = "data.txt"
    with open(file) as f:
        s = f.read().split("\n")

    ic(p1(s))
    ic(p2(s))


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
        ic(x, self)
        return self

    def get(self):
        return sorted(list(self.known))

    def solved(self):
        return len(self.known) == self.width

    def __str__(self):
        return f"{self.width}: {self.known}"

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
        self.solve()
        self.force_and_glue()
        # self.force_and_glue(reverse=True)
        self.solve()
        # self.fill_perfect_solves()
        self.possible()

    def first_fill(self):
        pos = 0
        new = self.state[:]
        if not any(b > self.fill_amount for b in self.sizes):
            return self
        for block in self.blocks:
            if block.width - self.fill_amount <= 0:
                pos += block.width + 1
                continue
            pos += self.fill_amount
            for i in range(block.width - self.fill_amount):
                if self.state[pos] & Nono.STATE.EMPTY:
                    raise TypeError("Contradiction with empty space")
                new[pos] = Nono.STATE.BLOCK
                pos += 1
            pos += 1
        self.state = new

        ic(self)

        return self

    def force_and_glue(self, reverse=False):
        ic(self)

        while True:
            cont = False
            s = self.state[:]
            b = self.blocks[:]
            step = -1 if reverse else 1
            if reverse:
                s.reverse()
                b.reverse()
                first, last = self.sizes[-1], self.sizes[0]
            else:
                first, last = self.sizes[0], self.sizes[-1]

            start = 0

            known_blocks = sum([list(k.known) for k in b if k.known], [])

            empties = consecutive_groups(
                [i for i, x in enumerate(s) if x & Nono.STATE.EMPTY]
            )
            unfilled = consecutive_groups(
                [i for i, x in enumerate(s) if x & Nono.STATE.UNFILLED]
            )
            fulls = consecutive_groups(
                [i for i, x in enumerate(s) if x & Nono.STATE.BLOCK]
            )

            first_empty = None if not empties else list(empties.items())[0]
            first_unfilled = None if not unfilled else list(unfilled.items())[0]
            first_full = None if not fulls else list(fulls.items())[0]

            if first_full and first_unfilled and first_unfilled[0] <= b[0].width + 1:
                start = first_full[0]
                ic(first_full)
                for i in range(start, start + first_full[1]):
                    b_pos = first_full[0] - 1
                    a_pos = first_full[0] + first_full[1]
                    if reverse:
                        i = len(self.state) - 1 - i
                        b_pos = len(self.state) - 1 - b_pos
                        a_pos = len(self.state) - 1 - a_pos
                    self.set(i)
                    b[0].set(i)
                    if b[0].solved():
                        if first_full[0] > 0:
                            self.set(b_pos, Nono.STATE.EMPTY)
                        if first_full[0] + first_full[1] + 1 < len(self.state):
                            self.set(a_pos, Nono.STATE.EMPTY)
                    cont = True
            else:
                return self

            known_blocks = sum([list(k.known) for k in b if k.known], [])

            ic(known_blocks)

            ic(self.blocks[0].known, self.blocks[0].width)

            ic(self)
            # if not cont:
            break

        return self

    def get_data(self):
        l = s = u = u_s = 0
        s_lengths = []
        u_lengths = []
        starts = []
        u_starts = []

        for i, full in enumerate(self.state):
            if full & Nono.STATE.BLOCK:
                if not s:  # Start of block
                    starts.append(i)
                    s = i
                l += 1
                if i == len(self.state) - 1:
                    s_lengths.append(l)
            elif l:
                s_lengths.append(l)

                l = 0
                s = 0
            if full & Nono.STATE.UNFILLED:
                if not u_s:
                    u_starts.append(i)
                    u_s = i
                u += 1
            elif u:
                u_lengths.append(u)
                u = 0
                u_s = 0
        if u:
            u_lengths.append(u)
        if l:
            s_lengths.append(l)

        return starts, s_lengths, u_starts, u_lengths

    def solve(self):
        s_lengths = []
        starts = []
        u_starts = []

        starts, s_lengths, u_starts, u_lengths = self.get_data()

        for i, block in enumerate(self.blocks):
            if i < len(starts):
                if i < len(u_starts):
                    correct_index = starts[i] < u_starts[i]
                else:
                    correct_index = True
            else:
                break
            if i < len(s_lengths) and correct_index and block.width == s_lengths[i]:
                ic(block, self, i)

                [
                    block.set(x) and self.set(x)
                    for x in range(starts[i], starts[i] + s_lengths[i])
                ]
            if block.solved():
                k = block.get()

                first = k[0]
                last = k[-1]
                if first > 0 and self.state[first - 1] & Nono.STATE.UNFILLED:
                    self.set(first - 1, Nono.STATE.EMPTY)
                if last < self.width - 1 and self.state[last + 1] & Nono.STATE.UNFILLED:
                    self.set(last + 1, Nono.STATE.EMPTY)

        self.fill_perfect_solves()

        return self

    def fill_perfect_solves(self):
        starts, s_lengths, u_starts, u_lengths = self.get_data()
        ic(self)

        potential_blocks = list(
            consecutive_groups(
                [i for i, x in enumerate(self.state) if x & Nono.STATE.EMPTY == 0]
            ).items()
        )

        p_sizes = [i[1] for i in potential_blocks]

        ic(potential_blocks, p_sizes)

        if p_sizes == self.sizes:
            for i, block in enumerate(self.blocks):
                p_start, p_end = (
                    potential_blocks[i][0],
                    potential_blocks[i][0] + potential_blocks[i][1],
                )
                for j in range(p_start, p_end):
                    block.set(j)
                    self.set(j)

            return self

        for i, block in enumerate(self.blocks):
            if not block.solved():
                ic(block.min_start, block.known)
                if block.known:
                    b_index = min(block.known)
                    a_index = max(block.known)
                    b_index -= 1 if b_index > 0 else 0
                    a_index += 1 if a_index < len(self.state) - 1 else 0
                    before = self.state[b_index]
                    after = self.state[a_index]
                    if (
                        before & Nono.STATE.UNFILLED
                        and after & Nono.STATE.UNFILLED == 0
                    ):
                        block.set(b_index)
                        self.set(b_index)
                    elif (
                        after & Nono.STATE.UNFILLED
                        and before & Nono.STATE.UNFILLED == 0
                    ):
                        block.set(a_index)
                        self.set(a_index)

            if block.solved():
                k = block.get()

                first = k[0]
                last = k[-1]

                ic(block, self, i, k)

                if first > 0 and self.state[first - 1] & Nono.STATE.UNFILLED:
                    self.set(first - 1, Nono.STATE.EMPTY)
                if last < self.width - 1 and self.state[last + 1] & Nono.STATE.UNFILLED:
                    self.set(last + 1, Nono.STATE.EMPTY)

                ic(block, self, i, k)

        un = [str(b) for b in self.blocks if not b.solved()]
        if all(b.solved() for b in self.blocks):
            [
                self.set(x, Nono.STATE.EMPTY)
                for x, val in enumerate(self.state)
                if val & Nono.STATE.UNFILLED
            ]
        else:
            ic(un)

        ic(self)

        return self

    def simple(self):
        simple = [
            [Nono.STATE.BLOCK] * x
            + ([Nono.STATE.EMPTY] if i < len(self.sizes) - 1 else [])
            for i, x in enumerate(self.sizes)
        ]
        min_start, push, pull = 0

        ic(self)

        fulls = [i for i, x in enumerate(self.state) if x & Nono.STATE.BLOCK]
        empties = [i for i, x in enumerate(self.state) if x & Nono.STATE.EMPTY]

        pull += max(fulls[i] - (min_start + self.sizes[i] - 1), 0)
        push = (empties[i] + 1) if min_start <= empties[i] < self.sizes[i] else push
        for i, full in fulls:
            if fulls[i] < empties[i]:
                min_start = fulls[i] - (len(self.sizes[i]) - 1)
            else:
                pass

        ic(self)

    def make_list(self, string=""):
        state = []
        if not string:
            string = self.original
        for c in string:
            state.append(Nono.SYMBOL[c])
        return state

    def set(self, x, val=False):
        val = Nono.STATE.BLOCK if not val else val
        ic(self, x, val)
        self.state[x] = val

    def possible(self):
        unsolved = [block for block in self.blocks if not block.solved()]
        known_solved = [k for b in unsolved for k in b.known]

        unfilled_x = [
            i
            for i, x in enumerate(self.state)
            if x & Nono.STATE.EMPTY == 0 and i not in known_solved
        ]

        ic(unfilled_x, known_solved)

        if not unfilled_x:
            return 1

        # last_u = False
        # unfilled_starts = []
        # u = 0
        # u_len = 1
        # unfilled_lengths = []
        # for i, u in enumerate(unfilled_x):
        #     ic(u, last_u, unfilled_starts, unfilled_lengths)
        #     if last_u == False:
        #         unfilled_starts.append(u)
        #         last_u = u
        #     if u > last_u + 1:
        #         unfilled_starts.append(u)
        #         unfilled_lengths.append(u_len)
        #         u_len = 1
        #         last_u = u
        #     else:
        #         u_len += 1
        #         last_u = u

        # unfilled_lengths.append(u_len)

        ux = consecutive_groups(unfilled_x)
        unfilled_starts, unfilled_lengths = list(ux.keys()), list(ux.values())

        ic(unfilled_starts, unfilled_lengths)

        possible_moves = []
        j = 0
        for i in range(min(len(unfilled_starts), len(unfilled_lengths))):
            adjustor = 0
            unsolved_inside = []
            inside_width = 0

            for j, un_in in enumerate(unsolved):
                adjustor = 1 if j < len(unsolved) - 1 else 0
                if inside_width + un_in.width + adjustor <= unfilled_lengths[i]:
                    un_in.min_start = unfilled_starts[i] + inside_width
                    inside_width += un_in.width + adjustor
                    unsolved_inside.append(un_in)
                else:
                    break

            if unsolved_inside:
                ic(unfilled_starts, unfilled_lengths)
                possible_moves.append(
                    self.count_configurations(
                        unsolved_inside, unfilled_starts[i], unfilled_lengths[i]
                    )
                )

        return sum(possible_moves)

    def count_configurations(self, b, start, line_length):
        clues = [c.width if type(c) is not int else c for c in b]

        before = False if start <= 0 else self.state[start - 1]
        after = (
            False
            if start + line_length >= len(self.state)
            else self.state[start + line_length]
        )

        ic(b, self, start, before, after, clues, line_length)

        configurations = 0
        # Generate all possible combinations of blocks and spaces
        clue_blocks = [
            ("#" * c) + ("." if i < len(clues) - 1 else "") for i, c in enumerate(clues)
        ]
        regex = r"".join(
            [
                (r"(^\.+|^)" if not i else "")
                + re.escape(c)
                + (r"+" if i < len(clues) - 1 else "(\.+$|$)")
                for i, c in enumerate(clue_blocks)
            ]
        )
        space_blocks = [
            ("." * s if s else "")
            for s in range(line_length - len("".join(clue_blocks)) + 1)
        ]
        all_blocks = clue_blocks + space_blocks
        configs = set()

        for arrangement in product(all_blocks, repeat=len(all_blocks)):
            line = "".join(arrangement)
            if (
                len(line) == line_length
                and line not in configs
                and re.match(regex, line)
            ):
                configs.add(line)
                configurations += 1
        return configurations

    def __str__(self):
        return "".join([Nono.SYMBOL[s] for s in self.state])

    def __repr__(self):
        return str(self)


def p1(s):
    nonos = [Nono(line) for line in s]

    ic(list(map(str, nonos)))
    [ic(n.blocks) for n in nonos]
    return sum([n.possible() for n in nonos])


def p2(s):
    pass


if __name__ == "__main__":
    main()
