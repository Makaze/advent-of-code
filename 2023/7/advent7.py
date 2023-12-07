# Advent of Code 2023-12-07
# @makaze 

class Hand:
    types = [
        {"singles": 5, "uniques": 5},
        {"singles": 3, "uniques": 4},
        {"singles": 1, "uniques": 3},
        {"singles": 2, "uniques": 3},
        {"singles": 0, "uniques": 2},
        {"singles": 1, "uniques": 2},
        {"singles": 0, "uniques": 1}
    ]
    
    def __init__(self, cards: str, bid: int, part: int=1):
        if part == 1:
            self.card_values = ["2","3","4","5","6","7","8","9","T","J","Q","K","A"]
        else:
            self.card_values = ["J","2","3","4","5","6","7","8","9","T","Q","K","A"]
        
        self.part = part
        self.bid = bid
        self.letters = cards
        self.cards = list(map(self.get_values, self.letters))
        self.counts = {card: self.cards.count(card) for card in self.cards}
        self.type = self.get_type()
        
    def get_values(self, card: str) -> int:
        return self.card_values.index(card) + 1
    
    def get_type(self) -> int:
        if self.part == 1:
            singles = len([i for i, cnt in self.counts.items() if cnt == 1])
            uniques = len(self.counts.keys())
        else:
            wilds = 0 if 1 not in self.counts.keys() else self.counts[1]
            singles = len([i for i, cnt in self.counts.items() if cnt == 1 and i != 1])
            uniques = len([i for i in self.counts.keys() if i != 1])
            uniques += 1 if not uniques else 0
            singles -= 1 if singles == uniques and wilds else 0
        
        for i in range(len(Hand.types)):
            t = Hand.types[i]
            if t["singles"] == singles and t["uniques"] == uniques:
                return i
            
    def __lt__(self, b) -> bool:
        if self.type == b.type:
            return self.cards < b.cards
        return self.type < b.type        
            

def main():
    #with open("test.txt") as f:
    with open("data.txt") as f:
        s = f.read()

    hand_strings = list(map(str.split, s.split("\n")))
    hands1 = [Hand(s[0], int(s[1])) for s in hand_strings]
    hands2 = [Hand(s[0], int(s[1]), 2) for s in hand_strings]
    
    ranked1 = sorted(hands1)
    ranked2 = sorted(hands2)
    
    winnings1 = 0
    winnings2 = 0

    for i in range(len(ranked1)):
        winnings1 += (i + 1) * ranked1[i].bid
        winnings2 += (i + 1) * ranked2[i].bid
        
    print(f"Winngings Part 1: {winnings1}")
    print(f"Winngings Part 2: {winnings2}")

if __name__ == "__main__":
    main()