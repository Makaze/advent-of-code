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

def solve(lines, multiplier):
    y_shift, x_shift, multiplier = [0], [0], multiplier - 1
    shift = lambda line, shifted, multiplier: (shifted[-1] + multiplier if not shifted.append(shifted[-1] + multiplier) else None) if all(c == '.' for c in line) else shifted[-1]
    _y = [shift(line, y_shift, multiplier) for line in lines]
    _x = [shift(line, x_shift, multiplier) for line in transpose(lines)] # Transposed
    galaxies = [(_y[y] + y, _x[x] + x) for y, line in enumerate(lines) for x, char in enumerate(line) if char == '#']
    pairs = {(galaxies[a], galaxies[b]) for a in range(len(galaxies)) for b in range(a)}
    distances = [(abs(a[0] - b[0]) + abs(a[1] - b[1])) for a, b in pairs]

    return sum(distances)

if __name__ == "__main__":
    main()