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

public protocol TestablePuzzle: Puzzle {
    var testCases: [TestCase<Part1Result, Part2Result>] { get }
}

public protocol TestablePuzzleWithConfig: Puzzle {
    associatedtype Config: Sendable

    var testCases: [TestCaseWithConfig<Part1Result, Part2Result, Config>] { get }

    func part1(input: Input, _ config: Config) async throws -> Part1Result
    func part2(input: Input, _ config: Config) async throws -> Part2Result
}

public struct TestCase<
    Part1Result: CustomStringConvertible & Sendable,
    Part2Result: CustomStringConvertible & Sendable,
>: Sendable {
    public let input: InputSource
    public let expectedPart1: Part1Result?
    public let expectedPart2: Part2Result?

    public init(
        input: InputSource,
        part1: Part1Result? = nil,
        part2: Part2Result? = nil,
    ) {
        self.input = input
        expectedPart1 = part1
        expectedPart2 = part2
    }
}

public struct TestCaseWithConfig<
    Part1Result: CustomStringConvertible & Sendable,
    Part2Result: CustomStringConvertible & Sendable,
    Config: Sendable,
>: Sendable {
    public let input: InputSource
    public let expectedPart1: Part1Result?
    public let expectedPart2: Part2Result?
    public let config: Config

    public init(
        input: InputSource,
        config: Config,
        part1: Part1Result? = nil,
        part2: Part2Result? = nil,
    ) {
        self.input = input
        self.config = config
        expectedPart1 = part1
        expectedPart2 = part2
    }
}

public enum InputSource: Sendable {
    case raw(String)
    case file(String)

    public static var example: Self { .file("example") }

    public static func example(_ number: Int) -> Self {
        .file("example\(number)")
    }

    public static func example(_ prefix: String) -> Self {
        .file("\(prefix).example")
    }
}
