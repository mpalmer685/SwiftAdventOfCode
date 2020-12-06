import ArgumentParser

typealias PuzzleSolution<T: CustomStringConvertible> = (String) throws -> T
typealias StringPuzzleSolution = (String) throws -> String

enum PuzzlePart: Int, ExpressibleByArgument {
    case partOne = 1
    case partTwo = 2
}

extension PuzzlePart: CustomStringConvertible {
    public var description: String {
        String(rawValue)
    }
}

public protocol Puzzle {
    associatedtype Part1Result: CustomStringConvertible
    associatedtype Part2Result: CustomStringConvertible

    init()

    func part1Solution(for input: String) throws -> Part1Result
    func part2Solution(for input: String) throws -> Part2Result
}

public extension Puzzle {
    func part1Solution(for input: String) throws -> String {
        throw PuzzleError.partNotImplemented(.partOne)
    }

    func part2Solution(for input: String) throws -> String {
        throw PuzzleError.partNotImplemented(.partTwo)
    }
}

public extension Puzzle {
    func split(_ input: String, on character: Character, omittingEmptySubsequences: Bool = true) -> [String] {
        input.split(separator: character, omittingEmptySubsequences: omittingEmptySubsequences).map(String.init)
    }

    func getLines(from input: String, omittingEmptyLines: Bool = true) -> [String] {
        split(
            input.trimmingCharacters(in: .whitespacesAndNewlines),
            on: "\n",
            omittingEmptySubsequences: omittingEmptyLines
        )
    }
}

enum PuzzleError: Error {
    case dayNotImplemented(_ day: UInt8)
    case partNotImplemented(_ part: PuzzlePart)
}

extension PuzzleError: CustomStringConvertible {
    public var description: String {
        switch self {
            case .dayNotImplemented(let day):
                return "Solution for day \(day) not implemented"
            case .partNotImplemented(let part):
                return "Part \(part) not implemented"
        }
    }
}
