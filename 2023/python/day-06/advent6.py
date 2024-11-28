# Advent of Code 2023-12-06
# @makaze 

import math


def main():
    #with open("test.txt") as f:
    with open("data.txt") as f:
        s = f.read()

    times, records = s.split("\n")
    big_time = int("".join(times.split()[1:]))
    big_record = int("".join(records.split()[1:]))
    times = list(map(int, times.split()[1:]))
    records = list(map(int, records.split()[1:]))
    
    product = 1
    
    # Part 1
    # Use quadratic formula
    for i in range(len(times)):
        b = times[i]
        a = 1
        c = records[i] + 0.5
        
        lower = math.ceil((b - math.sqrt(b**2 - 4*a*c)) / 2)
        upper = math.ceil((b + math.sqrt(b**2 - 4*a*c)) / 2)
        
        ways = upper - lower
        print(f"{upper=}, {lower=}, {ways=}")
        
        product *= upper - lower
    
    # Part 2
    
    b = big_time
    a = 1
    c = big_record + 0.5
    
    lower = math.ceil((b - math.sqrt(b**2 - 4*a*c)) / 2)
    upper = math.ceil((b + math.sqrt(b**2 - 4*a*c)) / 2)
    
    ways = upper - lower
    print(f"{upper=}, {lower=}, {ways=}")
    
    big_product = upper - lower
    
    print(f"{product=}, {big_product=}")


if __name__ == "__main__":
    main()