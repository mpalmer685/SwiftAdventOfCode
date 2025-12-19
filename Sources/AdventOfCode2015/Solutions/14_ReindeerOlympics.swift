import AOCKit

struct ReindeerOlympics: Puzzle {
    static let day = 14

    func part1(input: Input) async throws -> Int {
        try await part1(input: input, 2503)
    }

    func part1(input: Input, _ maxTime: Int) async throws -> Int {
        let reindeer = parseReindeer(from: input)
        return reindeer.max { $0.distanceFlown(after: maxTime) }!
    }

    func part2(input: Input) async throws -> Int {
        try await part2(input: input, 2503)
    }

    func part2(input: Input, _ maxTime: Int) async throws -> Int {
        let reindeer = parseReindeer(from: input)
        var scores = Dictionary(uniqueKeysWithValues: reindeer.map { ($0.name, 0) })

        for time in 1 ... maxTime {
            let distances = reindeer.map { ($0.name, $0.distanceFlown(after: time)) }
            let maxDistance = distances.map(\.1).max()!

            for (name, distance) in distances where distance == maxDistance {
                scores[name]! += 1
            }
        }

        return scores.max(of: \.value)!
    }

    private func parseReindeer(from input: Input) -> [Reindeer] {
        let parser = Parse(input: Substring.self, Reindeer.init) {
            Prefix { !$0.isWhitespace }.map(String.init)
            " can fly "
            Int.parser()
            " km/s for "
            Int.parser()
            " seconds, but then must rest for "
            Int.parser()
            " seconds."
        }

        return input.lines.raw.compactMap { try? parser.parse($0) }
    }
}

private struct Reindeer {
    let name: String
    let speed: Int
    let flightDuration: Int
    let restDuration: Int

    func distanceFlown(after time: Int) -> Int {
        let cycleTime = flightDuration + restDuration
        let (fullCycles, remainingTime) = time.quotientAndRemainder(dividingBy: cycleTime)
        let additionalFlightTime = min(remainingTime, flightDuration)
        return speed * (fullCycles * flightDuration + additionalFlightTime)
    }
}

extension ReindeerOlympics: TestablePuzzleWithConfig {
    typealias Config = Int

    var testCases: [TestCaseWithConfig<Int, Int, Config>] {
        [
            .given(.example, config: 1000).expects(part1: 1120, part2: 689),
        ]
    }
}
