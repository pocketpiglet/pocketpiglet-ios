var PuzzleMap = [];

function mapSolved() {
    for (var i = 0; i < PuzzleMap.length; i++) {
        for (var j = 0; j < PuzzleMap[i].length; j++) {
            if (i === PuzzleMap.length - 1 && j === PuzzleMap[i].length - 1) {
                if (PuzzleMap[i][j] !== 0) {
                    return false;
                }
            } else {
                if (PuzzleMap[i][j] !== j * PuzzleMap.length + i + 1) {
                    return false;
                }
            }
        }
    }

    return true;
}

function createMap(complexity) {
    var map_width      = 0;
    var map_height     = 0;
    var element_width  = 0;
    var element_height = 0;
    var used_elements;
    var puzzle_elements;

    if (complexity === "medium") {
        map_width       = 3;
        map_height      = 3;
        element_width   = 120;
        element_height  = 120;
        puzzle_elements = gameFieldRectangle.puzzleElementsMedium;
    } else {
        map_width       = 4;
        map_height      = 4;
        element_width   = 90;
        element_height  = 90;
        puzzle_elements = gameFieldRectangle.puzzleElementsHard;
    }

    PuzzleMap = [];

    for (var i = 0; i < map_height; i++) {
        var line = [];

        for (var j = 0; j < map_width; j++) {
            var element;

            if (i === map_height - 1 && j === map_width - 1) {
                element = 0;
            } else {
                element = j * map_width + i + 1;
            }

            line[j] = element;
        }

        PuzzleMap[i] = line;
    }

    while (mapSolved()) {
        var zero_h = map_width  - 1;
        var zero_v = map_height - 1;

        do {
            var rand = Math.random();
            var tmp;

            if (rand < 0.25) {
                if (zero_h > 0) {
                    tmp                           = PuzzleMap[zero_v][zero_h - 1];
                    PuzzleMap[zero_v][zero_h - 1] = 0;
                    PuzzleMap[zero_v][zero_h]     = tmp;

                    zero_h = zero_h - 1;
                }
            } else if (rand < 0.5) {
                if (zero_h < map_width - 1) {
                    tmp                           = PuzzleMap[zero_v][zero_h + 1];
                    PuzzleMap[zero_v][zero_h + 1] = 0;
                    PuzzleMap[zero_v][zero_h]     = tmp;

                    zero_h = zero_h + 1;
                }
            } else if (rand < 0.75) {
                if (zero_v > 0) {
                    tmp                           = PuzzleMap[zero_v - 1][zero_h];
                    PuzzleMap[zero_v - 1][zero_h] = 0;
                    PuzzleMap[zero_v][zero_h]     = tmp;

                    zero_v = zero_v - 1;
                }
            } else {
                if (zero_v < map_height - 1) {
                    tmp                           = PuzzleMap[zero_v + 1][zero_h];
                    PuzzleMap[zero_v + 1][zero_h] = 0;
                    PuzzleMap[zero_v][zero_h]     = tmp;

                    zero_v = zero_v + 1;
                }
            }
        } while (zero_h !== map_width  - 1 || zero_v !== map_height - 1);
    }

    for (var k = 0; k < map_height; k++) {
        for (var l = 0; l < map_width; l++) {
            puzzle_elements[PuzzleMap[l][k]].x = l * element_width  * pigletPuzzlePage.screenScale;
            puzzle_elements[PuzzleMap[l][k]].y = k * element_height * pigletPuzzlePage.screenScale;
        }
    }
}

function moveElement(complexity, element) {
    var puzzle_elements;

    if (complexity === "medium") {
        puzzle_elements = gameFieldRectangle.puzzleElementsMedium;
    } else {
        puzzle_elements = gameFieldRectangle.puzzleElementsHard;
    }

    for (var i = 0; i < PuzzleMap.length; i++) {
        for (var j = 0; j < PuzzleMap[i].length; j++) {
            if (PuzzleMap[i][j] === element) {
                var zero_i = -1;
                var zero_j = -1;

                if (i > 0 && PuzzleMap[i - 1][j] === 0) {
                    zero_i = i - 1;
                    zero_j = j;
                } else if (i < PuzzleMap.length - 1 && PuzzleMap[i + 1][j] === 0) {
                    zero_i = i + 1;
                    zero_j = j;
                } else if (j > 0 && PuzzleMap[i][j - 1] === 0) {
                    zero_i = i;
                    zero_j = j - 1;
                } else if (j < PuzzleMap[i].length - 1 && PuzzleMap[i][j + 1] === 0) {
                    zero_i = i;
                    zero_j = j + 1;
                }

                if (zero_i !== -1 && zero_j !== -1) {
                    PuzzleMap[i][j]           = 0;
                    PuzzleMap[zero_i][zero_j] = element;

                    var x = puzzle_elements[element].x;
                    var y = puzzle_elements[element].y;

                    puzzle_elements[element].x = puzzle_elements[0].x;
                    puzzle_elements[element].y = puzzle_elements[0].y;

                    puzzle_elements[0].x = x;
                    puzzle_elements[0].y = y;
                }

                return mapSolved();
            }
        }
    }
}
