import math
import copy


def chunks(lst, n):
    """Yield successive n-sized chunks from lst."""
    for i in range(0, len(lst), n):
        yield lst[i:i + n]


def gen_map(s):
    return sorted(chunks(list(map(int, " ".join(s.split("\n")[1:]).split())), 3), key=lambda item: item[2])


def follow(id, m):
    for mod in range(len(m)):
        origin_start = m[mod][1]
        dest_start = m[mod][0]
        distance = m[mod][2]
        shift = dest_start - origin_start
        
        if origin_start <= id <= origin_start + distance:
            return id + shift
    
    return id


def shift_map(original, sub_map):
    ranges = []
    
    for r in range(len(original)):
        start, stop = original[r]
        
        origin_start = sub_map[1]
        dest_start = sub_map[0]
        distance = sub_map[2]
        shift = dest_start - origin_start
        
        if start >= origin_start:
            if stop <= origin_start + distance:
                ranges.append([start + shift, stop + shift])
            else:
                ranges.append([start + shift, origin_start + shift])
                ranges.append([origin_start + distance + 1, stop])
        elif start <= origin_start + distance:
            if stop <= origin_start + distance:
                ranges.append([start, origin_start - 1])
                ranges.append([origin_start + shift, stop + shift])
            else:
                ranges.append([start, origin_start - 1])
                ranges.append([origin_start + shift, origin_start + distance + shift])
                ranges.append([origin_start + distance + 1, stop])
                
    return ranges


def main():
    with open("data.txt") as f:
        s = f.read()

    map_sets = s.split("\n\n")
    seeds = sorted(chunks(list(map(int, map_sets[0].split("seeds: ")[1].split())), 2), key=lambda item: item[0])
    
    maps = list(map(gen_map, map_sets[1:]))
    
    lowest = math.inf
    
    for m in maps:
        for m2 in m:
            seeds = shift_map(seeds, m2)
        
    for seed in seeds:
        id = seed[0]
        for m in maps:
            for m2 in m:
                id = follow(id, m2)
        
        lowest = min(id, lowest)
    
    print(lowest)  # correct is 1928058
    

if __name__ == "__main__":
    main()