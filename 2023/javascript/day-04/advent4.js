(function() {
    let text = document.querySelector('pre').innerHTML
    .replace(/Card\s+(\d+):\s+/g, "\"$1\":{\"wins\":[")
    .replace(/\s+\|\s+/g, "],\"haves\":[")
    .replace(/\n/g, "]},\n")
    .replace(/(\d+)\s+/g, "$1,")
    .replace(/\s+/g, "")
    .replace(/\,$/g, "")
             + "}";

    let cards = JSON.parse(text.trim());
    let points = {};
    let cardCounts = {};
    let normal = 0;
    let total = 0;

    for (let id in cards) {
        let card = cards[id];
        let wins = card.wins;
        let haves = card.haves;
        let thisScore = 0;
        let winningCount = 0;

        if (!cardCounts[id]) {
            cardCounts[id] = 1;
        }

        wins.forEach(function(item) {
            if (haves.includes(item)) {
                if (!thisScore) thisScore = 1; else thisScore *= 2; 
                winningCount += 1;
            }
        });

        for (let k = 0; k < cardCounts[id]; k++) {
            for (let i = 0; i < winningCount; i++) {
                if (!cards.hasOwnProperty((parseInt(id) + i + 1).toString())) break;
                let nextCard = cardCounts[(parseInt(id) + i + 1).toString()];
                if (!nextCard) cardCounts[(parseInt(id) + i + 1).toString()] = 2;
                else cardCounts[(parseInt(id) + i + 1).toString()] += 1;
            }
        }

        points[id] = thisScore;
    }

    for (let id in points) {
        normal += points[id];
        total += cardCounts[id];
    }

    console.log("Points:", normal);
    console.log("Extra total:", total);
})();