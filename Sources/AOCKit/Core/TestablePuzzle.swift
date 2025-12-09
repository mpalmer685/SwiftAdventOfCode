import Files

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

    private init(
        input: InputSource,
        part1: Part1Result? = nil,
        part2: Part2Result? = nil,
    ) {
        self.input = input
        expectedPart1 = part1
        expectedPart2 = part2
    }

    public static func given(_ input: InputSource) -> Self {
        .init(input: input)
    }

    public func expects(part1: Part1Result) -> Self {
        .init(input: input, part1: part1, part2: expectedPart2)
    }

    public func expects(part2: Part2Result) -> Self {
        .init(input: input, part1: expectedPart1, part2: part2)
    }

    public func expects(part1: Part1Result, part2: Part2Result) -> Self {
        .init(input: input, part1: part1, part2: part2)
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

    private init(
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

    public static func given(_ input: InputSource, config: Config) -> Self {
        .init(input: input, config: config)
    }

    public func expects(part1: Part1Result) -> Self {
        .init(input: input, config: config, part1: part1, part2: expectedPart2)
    }

    public func expects(part2: Part2Result) -> Self {
        .init(input: input, config: config, part1: expectedPart1, part2: part2)
    }

    public func expects(part1: Part1Result, part2: Part2Result) -> Self {
        .init(input: input, config: config, part1: part1, part2: part2)
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
