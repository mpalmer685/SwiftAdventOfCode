import AOCKit

struct Cafeteria: Puzzle {
    static let day = 5

    func part1(input: Input) async throws -> Int {
        let (ranges, ids) = parseDatabase(from: input)
        return ids.count { id in
            ranges.contains { $0.contains(id) }
        }
    }

    func part2(input: Input) async throws -> Int {
        let (ranges, _) = parseDatabase(from: input)
        let mergedRanges = ranges.sorted(using: \.lowerBound)
            .reduce(into: [ClosedRange<Int>]()) { result, range in
                if let last = result.last, let merged = last.merged(with: range) {
                    result[result.count - 1] = merged
                } else {
                    result.append(range)
                }
            }
        return mergedRanges.reduce(0) { $0 + ($1.upperBound - $1.lowerBound + 1) }
    }

    private func parseDatabase(from input: Input) -> (ranges: [ClosedRange<Int>], ids: [Int]) {
        let parts = input.lines.split(whereSeparator: \.isEmpty)
        let ranges = parts[0].map { line -> ClosedRange<Int> in
            let bounds = line.words(separatedBy: "-").compactMap(\.integer)
            return bounds[0] ... bounds[1]
        }
        let ids = parts[1].compactMap(\.integer)

        return (ranges, ids)
    }
}

private extension ClosedRange<Int> {
    func merged(with other: ClosedRange) -> Self? {
        guard overlaps(other) || upperBound + 1 == other.lowerBound else {
            return nil
        }
        return Swift.min(lowerBound, other.lowerBound) ... Swift.max(upperBound, other.upperBound)
    }
}

extension Cafeteria: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.example).expects(part1: 3, part2: 14),
        ]
    }
}
