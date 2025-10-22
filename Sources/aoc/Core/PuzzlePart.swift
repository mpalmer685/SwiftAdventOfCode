import AOCKit
import ArgumentParser

public enum PuzzlePart: Int, CaseIterable, Sendable {
    case partOne = 1
    case partTwo = 2
}

extension PuzzlePart: CustomStringConvertible {
    public var description: String {
        String(rawValue)
    }
}

extension PuzzlePart: ExpressibleByArgument {}
