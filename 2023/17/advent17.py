# Advent of Code 2023-12-17
# @makaze

from functools import lru_cache
from icecream import ic

ic.configureOutput(includeContext=True)


def main():
    file = "test.txt"
    # file = "data.txt"
    with open(file) as f:
        s = f.read().split("\n")

    ic(part1(s))
    ic(part2(s))


class Node:
    def __init__(
        self, state: tuple[int], value: int, parent: "Node", action: tuple[int]
    ) -> None:
        self.state: tuple[int] = state
        self.y, self.x = state
        self.action: tuple[int] = action
        self.value: int = int(value)
        self.parent: Node = parent

    def __add__(self, other: "Node") -> int:
        return self.value + other.value

    def __lt__(self, other: "Node") -> bool:
        return self.cost() < other.cost()

    def __eq__(self, other: "Node") -> bool:
        return self.state == other.state and self.cost() == other.cost()

    # @lru_cache
    def cost(self) -> int:
        c = self
        total: int = self.value
        while c := c.parent:
            total += c.value
        return total

    # @lru_cache
    def valid_path(self) -> bool:
        n = self
        for _ in range(3):
            p = n.parent
            if n.action != p.action:
                return True
            # ic(_, n.action, p.action, n.action != p.action)
            n = p

        return False

    # @lru_cache
    def contains(self, node: "Node") -> bool:
        p = self
        while p:
            if p.state == node.state:
                return True
            p = p.parent
        return False

    # @lru_cache
    def neighbors(self, s: list[str]) -> list["Node"]:
        nodes = []
        coords = (-1, 0, 1)
        for y in coords:
            for x in coords:
                if (y, x) == (0, 0) or abs(x) + abs(y) > 1:
                    continue

                new_x = self.x + x
                if not (new_x >= 0 and new_x < len(s[0])):
                    new_x = self.x
                    x = 0

                new_y = self.y + y
                if not (new_y >= 0 and new_y < len(s)):
                    new_y = self.y
                    y = 0

                if (y, x) == (0, 0):
                    continue

                new_node = Node(
                    state=(new_y, new_x),
                    value=s[new_y][new_x],
                    parent=self,
                    action=(y, x),
                )

                if self.contains(new_node):
                    continue

                if new_node.valid_path():
                    nodes.append(new_node)
        return nodes

    def __str__(self) -> str:
        return f"<Node {self.state}: {self.value}, {self.cost()}>"

    def __repr__(self) -> str:
        return str(self)


def a_star(s: list[str]) -> int:
    s = [list(map(int, line)) for line in s]

    start = Node(state=(0, 0), value=0, parent=None, action=None)
    end = (len(s) - 1, len(s[0]) - 1)
    frontier = [start]
    explored = set()
    solves = []

    while len(frontier):
        node = frontier.pop(0)
        pos = node.state
        explored.add(str(node))
        if pos == end:
            solves.append(node)
            # return node.cost()
        else:
            for n in node.neighbors(s):
                if n.state == end:
                    solves.append(n)
                    # return n.cost()
                else:
                    frontier.append(n)
        frontier.sort()
        # ic(frontier)

    ic(solves, min(solves))


def part1(s):
    return a_star(s)


def part2(s):
    pass


if __name__ == "__main__":
    main()
