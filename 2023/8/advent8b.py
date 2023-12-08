# Advent of Code 2023-12-08
# Part 2
# @makaze

import math
import re

def main():
    # with open("test.txt") as f:
    with open("data.txt") as f:
        s = f.read()
        
    s = s.split("\n")
    instructs = s[0]
    nodes = { sep[0]: (sep[1], sep[2]) for sep in list(map(lambda x: re.split(r"\W+", x), s[2:])) }
    
    next = [A for A in nodes.keys() if A.endswith("A")]
    Zs = [None for A in next]
    
    steps = 0
    
    end = False
    
    while not end:
        these_nodes = {key: val for key, val in nodes.items() if key in next}
        step = instructs[steps % len(instructs)]
        
        next = [n for n in list(map(lambda x: x[0] if step == "L" else x[1], these_nodes.values()))]
        
        steps += 1
        end = True if all(n.endswith("Z") for n in next) else False
        
        for i in range(len(Zs)):
            if next[i].endswith("Z") and not Zs[i]:
                Zs[i] = steps
                
                print(f"{Zs=}, {next=}, {these_nodes=} {step=}")
        
        if all(Zs):
            LCM = math.lcm(*Zs)
            
            steps = LCM
            end = True
    
    print(f"Steps: {steps}")

if __name__ == "__main__":
    main()