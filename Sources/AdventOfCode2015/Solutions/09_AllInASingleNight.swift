import AOCKit

struct AllInASingleNight: Puzzle {
    static let day = 9

    func part1(input: Input) async throws -> Int {
        let distances = parseDistances(from: input)
        let locations = Array(distances.keys)

        return locations.permutations().min { permutation in
            permutation.adjacentPairs().sum { from, to in
                distances[from]![to]!
            }
        }!
    }

    func part2(input: Input) async throws -> Int {
        let distances = parseDistances(from: input)
        let locations = Array(distances.keys)

        return locations.permutations().max { permutation in
            permutation.adjacentPairs().sum { from, to in
                distances[from]![to]!
            }
        }!
    }

    private func parseDistances(from input: Input) -> [String: [String: Int]] {
        input.lines.reduce(into: [:]) { distances, line in
            let parts = line.words(separatedBy: " = ")
            let distance = Int(parts[1].raw)!
            let locations = parts[0].words(separatedBy: " to ").raw
            let from = locations[0]
            let to = locations[1]

            distances[from, default: [:]][to] = distance
            distances[to, default: [:]][from] = distance
        }
    }
}

extension AllInASingleNight: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.example).expects(part1: 605, part2: 982),
        ]
    }
}
