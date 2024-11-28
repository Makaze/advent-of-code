import math


def gen_map(s):
    return list(map(int, " ".join(s.split("\n")[1:]).split()))


def follow(id, m):
    print(f"{len(m)=}, m/3={len(m)/3}")
    for i in range(int(len(m) / 3)):
        mod = i*3
        origin_start = m[mod]
        dest_start = m[mod+1]
        distance = m[mod+2]
        shift = dest_start - origin_start
        
        if origin_start >= id <= origin_start + distance:
            return id + shift
    
    return id


def main():
    with open("data.txt") as f:
        s = f.read()

    map_sets = s.split("\n\n")
    seeds = list(map(int, map_sets[0].split("seeds: ")[1].split()))
    maps = list(map(gen_map, map_sets[1:]))
    
    print(f"{maps=}")
    
    lowest = math.inf
    
    for id in seeds:
        for m in maps:
            id = follow(id, m)
        
        lowest = min(id, lowest)
    
    print(lowest)
    

if __name__ == "__main__":
    main()