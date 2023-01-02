import AOCKit

struct SonarSweep: Puzzle {
    static let day = 1

    func part1() throws -> Int {
        let measurements = getMeasurements()
        return countIncreases(in: measurements)
    }

    func part2() throws -> Int {
        let measurements = getMeasurements().windows(ofCount: 3).map(\.sum)
        return countIncreases(in: measurements)
    }

    private func getMeasurements() -> [Int] {
        input().lines.integers
    }
}

private func countIncreases(in measurements: [Int]) -> Int {
    measurements.adjacentPairs().count(where: <)
}
