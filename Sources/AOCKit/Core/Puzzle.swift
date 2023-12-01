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

public extension Puzzle {
    func input(_: StaticString = #file) -> Input {
        fatalError("input() is deprecated: day \(Self.day)")
    }
}
