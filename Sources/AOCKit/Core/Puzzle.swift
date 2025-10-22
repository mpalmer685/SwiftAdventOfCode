import Files

public protocol Puzzle: Sendable {
    associatedtype Part1Result: CustomStringConvertible
    associatedtype Part2Result: CustomStringConvertible

    static var day: Int { get }

    func part1(input: Input) throws -> Part1Result
    func part2(input: Input) throws -> Part2Result
}

public extension Puzzle {
    func part1(input: Input) throws -> Int {
        throw PuzzleError.partNotImplemented(1)
    }

    func part2(input: Input) throws -> Int {
        throw PuzzleError.partNotImplemented(2)
    }
}

public protocol TestablePuzzle: Puzzle {
    var testCases: [TestCase<Part1Result, Part2Result>] { get }
}

public protocol TestablePuzzleWithConfig: Puzzle {
    associatedtype Config

    var testCases: [TestCaseWithConfig<Part1Result, Part2Result, Config>] { get }

    func part1(input: Input, _ config: Config) throws -> Part1Result
    func part2(input: Input, _ config: Config) throws -> Part2Result
}

public struct TestCase<
    Part1Result: CustomStringConvertible,
    Part2Result: CustomStringConvertible
> {
    public let input: InputSource
    public let expectedPart1: Part1Result?
    public let expectedPart2: Part2Result?

    public init(
        input: InputSource,
        part1: Part1Result? = nil,
        part2: Part2Result? = nil
    ) {
        self.input = input
        expectedPart1 = part1
        expectedPart2 = part2
    }
}

public struct TestCaseWithConfig<
    Part1Result: CustomStringConvertible,
    Part2Result: CustomStringConvertible,
    Config
> {
    public let input: InputSource
    public let expectedPart1: Part1Result?
    public let expectedPart2: Part2Result?
    public let config: Config

    public init(
        input: InputSource,
        config: Config,
        part1: Part1Result? = nil,
        part2: Part2Result? = nil
    ) {
        self.input = input
        self.config = config
        expectedPart1 = part1
        expectedPart2 = part2
    }
}

public enum InputSource {
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
