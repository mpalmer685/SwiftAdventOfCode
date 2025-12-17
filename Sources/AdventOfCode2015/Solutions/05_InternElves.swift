import AOCKit

struct InternElves: Puzzle {
    static let day = 5

    func part1(input: Input) async throws -> Int {
        input.lines.count { line in
            let vowels = line.characters.count(where: { "aeiou".contains($0) })
            let hasDoubleLetter = line.characters.adjacentPairs().contains(where: { $0 == $1 })
            let hasNaughtySubstring = ["ab", "cd", "pq", "xy"]
                .contains(where: { line.raw.contains($0) })

            return vowels >= 3 && hasDoubleLetter && !hasNaughtySubstring
        }
    }

    func part2(input: Input) async throws -> Int {
        input.lines.count { line in
            let pairs = line.characters
                .adjacentPairs()
                .enumerated()
                .reduce(into: [String: [Int]]()) { seen, pair in
                    let key = [pair.element.0, pair.element.1].map(String.init).joined()
                    seen[key, default: []].append(pair.offset)
                }
            let hasRepeatedPair = pairs.values.contains { indices in
                guard let first = indices.first else { return false }
                return indices.contains(where: { $0 - first >= 2 })
            }

            let hasSandwichedLetter = line.characters.windows(ofCount: 3).contains { window in
                window.first == window.last
            }

            return hasRepeatedPair && hasSandwichedLetter
        }
    }
}

extension InternElves: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.example(1)).expects(part1: 2),
            .given(.example(2)).expects(part2: 2),
        ]
    }
}
