import AOCKit

struct SonarSweep: Puzzle {
    func part1Solution(for input: String) throws -> Int {
        let measurements = getMeasurements(from: input)
        return countIncreases(in: measurements)
    }

    func part2Solution(for input: String) throws -> Int {
        let measurements = groupMeasurements(getMeasurements(from: input), groupSize: 3)
        return countIncreases(in: measurements)
    }

    private func getMeasurements(from input: String) -> [Int] {
        getLines(from: input).compactMap(Int.init)
    }
}

private func countIncreases(in measurements: [Int]) -> Int {
    measurements.enumerated().reduce(0) { total, item in
        let (index, measurement) = item
        let previousMeasurement = index == 0 ? measurement : measurements[index - 1]
        let delta = measurement - previousMeasurement
        let unitDelta = delta == 0 ? 0 : max(0, delta / abs(delta))
        return total + unitDelta
    }
}

private func groupMeasurements(_ measurements: [Int], groupSize: Int) -> [Int] {
    var grouped: [Int] = []

    for i in 0 ..< measurements.count - 2 {
        grouped.append(measurements[i] + measurements[i + 1] + measurements[i + 2])
    }

    return grouped
}
