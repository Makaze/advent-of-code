(function() {
    let text = document.querySelectorAll('code')[0].textContent;

    let lines = text.split(/\s+/);
    let bottom = lines.length - 1;
    let right = lines[0].length - 1;

    let numre = /\d+/g;
    let symre = /[^0-9\.]/g;

    let sum = 0;
    let gearSum = 0;

    for (let i = 0; i < lines.length; i++) {
        let match = null;
        let line = lines[i];

        let symreForNumbers = /[^0-9\.]/g;
        let symLineMatch = null;

        while ((symLineMatch = symreForNumbers.exec(line)) != null) {
            let linesForSymbol = [];
            let symbolPos = symLineMatch.index;
            let validNums = [];
            let coordsForSymbol = [];
            let $symbolSearch = [];
            let leftSearch = symbolPos - 1 >= 0 ? symbolPos - 1 : symbolPos;
            let rightSearch = symbolPos + 1 <= right ? symbolPos + 1 : symbolPos + 1;

            if (i > 0) {
                linesForSymbol.push(lines[i - 1]);
                coordsForSymbol.push([i - 1, leftSearch], [i - 1, symbolPos], [i - 1, rightSearch]);
                $symbolSearch.push(lines[i - 1].slice(leftSearch, rightSearch + 1));
            }
            
            linesForSymbol.push(line);
            coordsForSymbol.push([i, leftSearch], [i, rightSearch]);
            $symbolSearch.push(lines[i].slice(leftSearch, rightSearch + 1));

            if (i < bottom) {
                linesForSymbol.push(lines[i + 1]);
                coordsForSymbol.push([i + 1, leftSearch], [i + 1, symbolPos], [i + 1, rightSearch]);
                $symbolSearch.push(lines[i + 1].slice(leftSearch, rightSearch + 1));
            }

            coordsForSymbol = coordsForSymbol.map((x) => JSON.stringify(x));

            for (j = -1; j < 2; j++) {
                let numReForSymbol = /\d+/g;
                let row = i + j;

                if (row < 0) continue;
                if (row >= lines.length) continue;

                while ((numSearch = numReForSymbol.exec(linesForSymbol[j + 1])) != null) {
                    let numPos = numSearch.index;
                    let numLen = numSearch[0].length;
                    let num = parseInt(numSearch[0]);
                    let numCoords = [];

                    for (c = numPos; c < numPos + numLen; c++) {
                        numCoords.push(JSON.stringify([row, c]));

                        if (coordsForSymbol.includes(JSON.stringify([row, c]))) {
                            validNums.push(num);
                            break;
                        }
                    }

                    //console.log(`numAroundSymbol="${num}", numCoords=${JSON.stringify(numCoords)}`);
                }
            }

            if (symLineMatch[0] == "*" && validNums.length == 2) {
                gearSum += validNums.reduce((a, b) => a * b, 1);
            } else if (validNums.length) {
                // sum += validNums.reduce((a, b) => a + b, 0);
            }

            console.log(`coordsForSymbol="${JSON.stringify(coordsForSymbol)}", validNums=${JSON.stringify(validNums)}`);
            console.log("$symbolSearch=\n" + $symbolSearch.join("\n"));
        }

        while ((match = numre.exec(line)) != null) {
            let numLen = match[0].length;
            let num = parseInt(match[0]);
            let pos = match.index;
            let leftSearch = pos - 1 >= 0 ? pos - 1 : pos;
            let rightSearch = pos + numLen + 1 <= right ? pos + numLen + 1 : pos + numLen;
            let symMatch = null;

            let $search = []

            // Above
            if (i > 0) {
                $search.push(lines[i - 1].slice(leftSearch, rightSearch));
                symMatch = lines[i - 1].slice(leftSearch, rightSearch).match(symre);
            }

            $search.push(line.slice(leftSearch, rightSearch));

            // Same line
            if (!symMatch) {
                symMatch = line.slice(leftSearch, rightSearch).match(symre);
            }

            if (i < bottom) {
                $search.push(lines[i + 1].slice(leftSearch, rightSearch));

                // Below
                if (!symMatch) {
                    symMatch = lines[i + 1].slice(leftSearch, rightSearch).match(symre);
                }
            }

            // console.log(`match=${match}, pos=[${i},${pos}], numLen=${numLen}, rightSearch=${rightSearch}, ${symMatch}`);

            // console.log($search.join("\n"));

            if (symMatch) sum += num;
        }
    }

    console.log("Possible sum:", sum);
    console.log("Gear sum:", gearSum);
})();