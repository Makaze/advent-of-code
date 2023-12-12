# Advent of Code 2023-12-
# @makaze

def main():
    # with open("test.txt") as f:
    with open("data.txt") as f:
        s = f.read().split("\n")

    print(f"Part 1:", solve(s, 2))
    print(f"Part 2:", solve(s, 1000000))

def transpose(lst: iter) -> list:
    return list(map(list, zip(*lst)))

def solve(lines, M):
    y_shift, x_shift, M = [0], [0], M-1
    shift = lambda l, coord, s, M: (s[-1] + M if not s.append(s[-1] + M) else coord) if all(c == '.' for c in l) else s[-1]
    _y = [shift(line, y, y_shift, M) for y, line in enumerate(lines)]
    _x = [shift(line, x, x_shift, M) for x, line in enumerate(transpose(lines))] # Transposed
    galaxies = [(_y[y] + y, _x[x] + x) for y, line in enumerate(lines) for x, char in enumerate(line) if char == '#']
    pairs = {(galaxies[a], galaxies[b]) for a in range(len(galaxies)) for b in range(a)}
    distances = [(abs(a[0] - b[0]) + abs(a[1] - b[1])) for a, b in pairs]

    return sum(distances)

if __name__ == "__main__":
    main()