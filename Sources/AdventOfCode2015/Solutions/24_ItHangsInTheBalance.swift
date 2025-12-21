import AOCKit

struct ItHangsInTheBalance: Puzzle {
    static let day = 24

    func part1(input: Input) async throws -> Int {
        bestGrouping(count: 3, from: input.lines.integers)
    }

    func part2(input: Input) async throws -> Int {
        bestGrouping(count: 4, from: input.lines.integers)
    }

    private func bestGrouping(count: Int, from weights: [Int]) -> Int {
        let totalWeight = weights.sum
        let targetWeight = totalWeight / count
        let groupings = groupings(from: weights, targetWeight: targetWeight).sorted(using: \.count)

        let minimalGroupSize = groupings.first!.count
        let minimalGroups = groupings.prefix(while: { $0.count == minimalGroupSize })
        return minimalGroups.min(of: \.product)!
    }

    private func groupings(from weights: [Int], targetWeight: Int) -> [[Int]] {
        var result: [[Int]] = []

        func backtrack(current: [Int], remaining: [Int], currentSum: Int) {
            if currentSum == targetWeight {
                result.append(current)
                return
            }
            if currentSum > targetWeight {
                return
            }

            for index in remaining.indices {
                var newCurrent = current
                newCurrent.append(remaining[index])
                let newRemaining = Array(remaining.dropFirst(index + 1))
                backtrack(
                    current: newCurrent,
                    remaining: newRemaining,
                    currentSum: currentSum + remaining[index],
                )
            }
        }

        backtrack(current: [], remaining: weights, currentSum: 0)
        return result
    }
}
