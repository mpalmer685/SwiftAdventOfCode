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
        if isSafe {
            return true
        }

        for index in indices {
            var copy = self
            copy.remove(at: index)
            if copy.isSafe {
                return true
            }
        }

        return false
    }

    func isChanging(by allowedDifferences: Set<Int>) -> Bool {
        adjacentPairs().allSatisfy { left, right in
            allowedDifferences.contains(right - left)
        }
    }
}
