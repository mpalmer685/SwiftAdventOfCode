import AOCKit

struct SonarSweep: Puzzle {
    func part1Solution(for input: String) throws -> Int {
        let measurements = getMeasurements(from: input)
        return countIncreases(in: measurements)
    }

    func part2Solution(for input: String) throws -> Int {
        let measurements = getMeasurements(from: input).windowed(3).map(sum)
        return countIncreases(in: measurements)
    }

    private func getMeasurements(from input: String) -> [Int] {
        getLines(from: input).compactMap(Int.init)
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
