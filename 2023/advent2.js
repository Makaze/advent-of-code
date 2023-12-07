(function() {
    document.querySelector('pre').innerHTML = "{" + document.querySelector('pre').innerHTML
    .replace(/Game (\d+):/g, "\"$1\":\n\t")
    .replace(/\t (.*)\n/g, "\t[ {$1} ],\n")
    .replace(/\; /g, "}, {")
    .replace(/(\d+) (red|blue|green)/g, "\"$2\": $1")
    .replace(/\s+/g, "")
    .replace(/\,$/g, "")
             + "}";

    let games = JSON.parse(document.querySelector('pre').innerHTML.trim());

    let max = {
        red: 12,
        green: 13,
        blue: 14
    };

    let sum = 0;
    let powerSum = 0;

    for (let id in games) {
        let skip = false;
        let mins = {
            red: 0, blue: 0, green: 0
        }

        games[id].forEach(function(draw) {
            for (let color in draw) {
                if (draw[color] > max[color]) {
                    skip = true;
                }
                mins[color] = Math.max(draw[color], mins[color]);
            }
        });

        let power = mins.red * mins.blue * mins.green;
        powerSum += power;

        if (skip) {
            continue;
        } else {
            sum += parseInt(id);
        }
    }

    console.log("Possible sum:", sum);
    console.log("Power sum:", powerSum);
})();