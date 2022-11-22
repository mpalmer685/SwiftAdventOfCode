import AOCKit

struct SonarSweep: Puzzle {
    static let day = 1

    func part1() throws -> Int {
        let measurements = getMeasurements()
        return countIncreases(in: measurements)
    }

    func part2() throws -> Int {
        let measurements = getMeasurements().windowed(3).map(sum)
        return countIncreases(in: measurements)
    }

    private func getMeasurements() -> [Int] {
        input().lines.integers
    }
}

private func countIncreases(in measurements: [Int]) -> Int {
    measurements.indices.count { $0 > 0 && measurements[$0] > measurements[$0 - 1] }
}

private func sum(_ values: [Int]) -> Int {
    values.reduce(0, +)
}

private extension Array {
    func windowed(_ windowSize: Int) -> [[Element]] {
        (0 ... count - windowSize).map { Array(self[$0 ..< $0 + windowSize]) }
    }
}
