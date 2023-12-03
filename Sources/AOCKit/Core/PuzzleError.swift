enum PuzzleError: Error {
    case noSavedResults
    case dayNotImplemented(_ day: Int)
    case partNotImplemented(_ part: Int)
    case noPuzzleInput(_ day: Int)
}

extension PuzzleError: CustomStringConvertible {
    public var description: String {
        switch self {
            case let .noPuzzleInput(day):
                return "Could not find or download an input file for day \(day)"
            case .noSavedResults:
                return "No saved results yet."
            case let .dayNotImplemented(day):
                return "Solution for day \(day) not implemented"
            case let .partNotImplemented(part):
                return "Part \(part) not implemented"
        }
    }
}
