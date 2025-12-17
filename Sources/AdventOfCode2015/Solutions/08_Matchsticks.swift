import AOCKit

struct Matchsticks: Puzzle {
    static let day = 8

    func part1(input: Input) async throws -> Int {
        let replacements = [
            (/^"/, ""),
            (/"$/, ""),
            (/\\"/, "_"),
            (/\\\\/, "_"),
            (/\\x[0-9a-fA-F]{2}/, "_"),
        ]

        return input.lines.raw.sum { line in
            let memoryCharacters = replacements.reduce(line) { str, pair in
                let (pattern, replacement) = pair
                return str.replacing(pattern, with: replacement)
            }
            return line.count - memoryCharacters.count
        }
    }

    func part2(input: Input) async throws -> Int {
        input.lines.raw.sum { line in
            let escapedLine = line
                .replacing(/\\/, with: "\\\\")
                .replacing(/"/, with: "\\\"")
            return escapedLine.count + 2 - line.count
        }
    }
}

extension Matchsticks: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.example).expects(part1: 12, part2: 19),
        ]
    }
}
