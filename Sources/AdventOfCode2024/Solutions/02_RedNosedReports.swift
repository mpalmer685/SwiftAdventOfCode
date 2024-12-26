import AOCKit

struct RedNosedReports: Puzzle {
    static let day = 2

    func part1(input: Input) throws -> Int {
        let reports = input.lines.map(\.integers)
        return reports.count(where: \.isSafe)
    }

    func part2(input: Input) throws -> Int {
        let reports = input.lines.map(\.integers)
        return reports.count(where: \.isSafeWithDampener)
    }
}

private extension [Int] {
    var isSafe: Bool {
        isChanging(by: [1, 2, 3]) || isChanging(by: [-1, -2, -3])
    }

    var isSafeWithDampener: Bool {
        isSafe || indices.contains { index in
            var copy = self
            copy.remove(at: index)
            return copy.isSafe
        }
    }

    func isChanging(by allowedDifferences: Set<Int>) -> Bool {
        adjacentPairs().allSatisfy { left, right in
            allowedDifferences.contains(right - left)
        }
    }
}
