# Advent of Code 2023-12-
# @makaze

def print_grid(grid):
    lines = []
    for row in grid:
        line = ""
        for cell in row:
            line += str(cell)
        lines.append(line)
            
    print("\n".join(lines))
    
def transpose(lst):
    return list(map(list, zip(*lst)))

def main():
    # with open("test.txt") as f:
    with open("data.txt") as f:
        s = f.read().split("\n")

    print(f"Part 1:", p1(s))
    print(f"Part 2:", p2(s))


def expand(lines):
    double = [lambda x: x,                                       # Print the line normally
              lambda x: x if all(c == '.' for c in x) else None] # Print the line again if all periods
    lines = [f(line) for line in lines for f in double if f(line)]
    lines = transpose([f(line) for line in transpose(lines) for f in double if f(line)]) # Double Transposed
    
    return lines


def p1(s):
    universe = expand(s)
    galaxies = [(y, x) for y, line in enumerate(universe) for x, char in enumerate(line) if char == '#']
    pairs = {(galaxies[a], galaxies[b]) for a in range(len(galaxies)) for b in range(a)}
    distances = [(abs(a[0] - b[0]) + abs(a[1] - b[1])) for a, b in pairs]
        
    return sum(distances)


def p2(s):
    # universe = expand(s)
    pass


if __name__ == "__main__":
    main()