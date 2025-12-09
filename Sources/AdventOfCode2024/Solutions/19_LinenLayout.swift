import AOCKit

struct LinenLayout: Puzzle {
    static let day = 19

    func part1(input: Input) throws -> Int {
        Towels.parse(from: input).countPossiblePatterns()
    }

    func part2(input: Input) throws -> Int {
        Towels.parse(from: input).countArrangements()
    }
}

private struct Towels {
    private let stripes: Set<String>
    private let patterns: Set<String>

    private let countArrangementsForPattern: (String) -> Int

    private init(stripes: Set<String>, patterns: Set<String>) {
        self.stripes = stripes
        self.patterns = patterns

        countArrangementsForPattern =
            recursiveMemoize { (countArrangements, pattern: String) -> Int in
                guard pattern.isNotEmpty else { return 1 }
                return stripes
                    .filter { pattern.hasPrefix($0) }
                    .sum { countArrangements(pattern.dropPrefix($0)) }
            }
    }

    static func parse(from input: Input) -> Self {
        let lines = input.lines
        let stripes = lines[0].words(separatedBy: ", ").map(\.raw)
        let patterns = lines[2...].map(\.raw)

        return .init(stripes: Set(stripes), patterns: Set(patterns))
    }

    func countPossiblePatterns() -> Int {
        patterns.count { countArrangementsForPattern($0) > 0 }
    }

    func countArrangements() -> Int {
        patterns.sum(of: countArrangementsForPattern)
    }
}

private extension String {
    func dropPrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }
}

extension LinenLayout: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.example).expects(part1: 6, part2: 16),
        ]
    }
}
