import AOCKit

struct SonarSweep: Puzzle {
    static let day = 1

    func part1(input: Input) throws -> Int {
        let measurements = getMeasurements(from: input)
        return countIncreases(in: measurements)
    }

    func part2(input: Input) throws -> Int {
        let measurements = getMeasurements(from: input).windows(ofCount: 3).map(\.sum)
        return countIncreases(in: measurements)
    }

    private func getMeasurements(from input: Input) -> [Int] {
        input.lines.integers
    }
}

private func countIncreases(in measurements: [Int]) -> Int {
    measurements.adjacentPairs().count(where: <)
}
