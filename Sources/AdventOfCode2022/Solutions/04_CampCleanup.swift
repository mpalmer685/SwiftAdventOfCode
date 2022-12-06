import AOCKit
import Foundation

private let inputPattern = NSRegularExpression("(\\d+)-(\\d+),(\\d+)-(\\d+)")

struct CampCleanup: Puzzle {
    static let day = 4

    func part1() throws -> Int {
        getPairs().count { pair in
            pair.first.fullyContains(pair.second) || pair.second.fullyContains(pair.first)
        }
    }

    func part2() throws -> Int {
        getPairs().count { pair in
            pair.first.overlaps(pair.second)
        }
    }

    private func getPairs() -> [(first: ClosedRange<Int>, second: ClosedRange<Int>)] {
        input().lines.raw.compactMap { line in
            guard let match = inputPattern.match(line) else { return nil }

            return (
                first: Int(match[1])! ... Int(match[2])!,
                second: Int(match[3])! ... Int(match[4])!
            )
        }
    }
}

private extension ClosedRange {
    func fullyContains(_ other: ClosedRange) -> Bool {
        lowerBound <= other.lowerBound && upperBound >= other.upperBound
    }
}
