import Files

public protocol Puzzle {
    associatedtype Part1Result: CustomStringConvertible
    associatedtype Part2Result: CustomStringConvertible

    static var day: Int { get }
    static var rawInput: String? { get }

    func part1(input: Input) throws -> Part1Result
    func part2(input: Input) throws -> Part2Result
}

public extension Puzzle {
    static var rawInput: String? { nil }

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
    let input: InputSource
    let expectedPart1: Part1Result?
    let expectedPart2: Part2Result?

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
    let input: InputSource
    let expectedPart1: Part1Result?
    let expectedPart2: Part2Result?
    let config: Config

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
}
