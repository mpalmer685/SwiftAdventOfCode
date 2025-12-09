import Files

public protocol Puzzle: Sendable {
    associatedtype Part1Result: CustomStringConvertible & Sendable
    associatedtype Part2Result: CustomStringConvertible & Sendable

    static var day: Int { get }

    func part1(input: Input) async throws -> Part1Result
    func part2(input: Input) async throws -> Part2Result
}

public extension Puzzle {
    func part1(input: Input) async throws -> Int {
        throw PuzzleError.partNotImplemented(1)
    }

    func part2(input: Input) async throws -> Int {
        throw PuzzleError.partNotImplemented(2)
    }
}

private let durationFormatter = Duration.UnitsFormatStyle(
    allowedUnits: [.seconds, .milliseconds],
    width: .narrow,
    zeroValueUnits: .hide,
    fractionalPart: .show(length: 3),
)

public extension Puzzle {
    func measure<T>(label: String, _ work: () throws -> T) rethrows -> T {
        let clock = ContinuousClock()
        var result: T!
        let duration = try clock.measure {
            result = try work()
        }
        print("\(label): \(duration.formatted(durationFormatter))")
        return result
    }

    func measure<T>(label: String, _ work: () async throws -> T) async rethrows -> T {
        let clock = ContinuousClock()
        var result: T!
        let duration = try await clock.measure {
            result = try await work()
        }
        print("\(label): \(duration.formatted(durationFormatter))")
        return result
    }
}
