# Advent of Code 2023-12-09
# @makaze

with open("data.txt") as f:
    lines = f.read().split("\n")
    
lines = [list(map(int, i)) for i in list(map(str.split, lines))]

p1_nexts = []
p2_nexts = []

for line in lines:
    triangle = []
    while any(line):
        triangle.append(line)
        line = [line[i] - line[i-1] for i in range(1, len(line))]
        
    p1_next = p2_next = 0
    triangle.reverse()
    
    for line in triangle:
        p1_next += line[-1]
        p2_next = line[0] - p2_next
    
    p1_nexts.append(p1_next)
    p2_nexts.append(p2_next)
    
print("Part 1:", sum(p1_nexts))
print("Part 2:", sum(p2_nexts))