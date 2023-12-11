# Advent of Code 2023-12-10
# @makaze

import colorama
from enum import IntFlag

colorama.init()

DIR = IntFlag('Dir', ['NORTH', 'SOUTH', 'EAST', 'WEST'])
PIPES = {
    "|": DIR.NORTH | DIR.SOUTH,
    "-": DIR.EAST | DIR.WEST,
    "L": DIR.NORTH | DIR.EAST,
    "J": DIR.NORTH | DIR.WEST,
    "7": DIR.SOUTH | DIR.WEST,
    "F": DIR.EAST | DIR.SOUTH,
    ".": 0,
    "S": DIR.NORTH | DIR.SOUTH | DIR.EAST | DIR.WEST,
}
CHARS = {val: key for key, val in PIPES.items()}
MOVES = {
    DIR.NORTH: (-1, 0), 
    DIR.SOUTH: (1, 0),
    DIR.EAST: (0, 1),
    DIR.WEST: (0, -1)
}
OPPOSITES = {
    DIR.NORTH: DIR.SOUTH, 
    DIR.SOUTH: DIR.NORTH,
    DIR.EAST: DIR.WEST,
    DIR.WEST: DIR.EAST
}

explored = set()
outside = set()
start = ()
start_char = "S"

def main():
    global outside
    # with open("test.txt") as f:
    with open("data.txt") as f:
        s = f.read().split("\n")
        
    outside |= {(0, x) for x in range(len(s[0]))} # top
    outside |= {(len(s)-1, x) for x in range(len(s[0]))} # bottom
    outside |= {(x, 0) for x in range(len(s))} # left
    outside |= {(x, len(s[0])-1) for x in range(len(s))} # right
    
    print(f"Part 1:", p1(s))
    print(f"Part 2:", p2(s))
            

def p1(s):
    global start
    global explored
    global start_char
    
    lines = []
    max_distance = 0
    for i, line in enumerate(s):
        if "S" in line:
            start = (i, line.index("S"))
            explored.add(start)
        lines.append(list(map(lambda x: PIPES[x], line)))
    
    end, pos, distance, last_move = False, start, 0, (0,0)
    
    moves_from_start = []
    
    while end != start:
        curr_pipe = lines[pos[0]][pos[1]]
        next_items = []
        
        # print()

        # print(f"On a new pipe: {pos=}, {curr_pipe=}, DISTANCE: {distance}\n")
        explored.add(pos)
        
        if len(moves_from_start) == 2:
            s_type = moves_from_start[0] | moves_from_start[1]
            for key, val in PIPES.items():
                if val == s_type:
                    start_char = key
        
        for dir, move in MOVES.items():
            next_pos = tuple(map(sum, zip(move, pos)))
            
            # # print(f"{explored=}, {start=}, {next_pos=}, {next_pipe=}")
            if dir & curr_pipe == 0:
                # print(f"Invalid direction: {dir=}, {CHARS[curr_pipe]=}")
                continue
            if not (0 <= next_pos[0] < len(lines)): # Not in y range
                # print(f"Not in Y range: {dir=}, {pos=}, {next_pos=}")
                continue
            if not (0 <= next_pos[1] < len(lines[0])): # Not in x range
                # print(f"Not in X range: {dir=}, {pos=}, {next_pos=}")
                continue
            
            next_pipe = lines[next_pos[0]][next_pos[1]]
            
            if tuple(map(sum, zip(move, last_move))) == (0, 0): # Going backwards
                # print(f"Going backwards: {dir=}, {pos=}, {next_pos=}, {move=}, {last_move=}")
                continue
            if OPPOSITES[dir] & next_pipe == 0: # Next pipe doesn't attach
                # print(f"\nDoesn't attach: {dir=}, {CHARS[next_pipe]=}, {pos=}, {next_pos=}, {next_pipe=}, {OPPOSITES[dir]=}")
                continue
            if next_pos == start and distance > 0:
                # print(f"\nFound start!")
                end, distance = start, distance + 1
                break
            if next_pos in explored:
                continue
            else:
                # print(f"\nAttached! {dir=}, {CHARS[next_pipe]=}, {pos=}, {next_pos=}, {next_pipe=}, {OPPOSITES[dir]=}")
                # print(f"Moving on...")
                pos, distance, last_move = next_pos, distance + 1, move
                if len(moves_from_start) < 2:
                    moves_from_start.append(dir)
                break
        
    if end == start:
        max_distance = int((distance + 1) / 2)
    
    return max_distance

def highlight(s, sel):
    y, x = sel
    lit = s.copy()
    lit[y] = lit[y][:x-(1 if x else 0)] + \
        colorama.Fore.RED + lit[y][x] + colorama.Fore.RESET + \
            lit[y][(x if x else x+1):]
    
    print()
    
    for line in lit:
        print(line)


def p2(s):
    global outside
    global explored
    global start
    global start_char
    
    inside = set()
    allowed_pipes = ['F', '|', 'J']
    
    for y, line in enumerate(s):
        pipe_count = 0
        for x, char in enumerate(line):
            point = (y, x)
            if point in explored:
                if point == start:
                    char = start_char
                if char in allowed_pipes:
                    pipe_count += 1
                continue
        
            line = list(line)
            line[x] = '.'
            
            if pipe_count % 2 != 0:
                inside.add(point)
            
        print("".join(line))
                
    return len(inside)
                

if __name__ == "__main__":
    main()