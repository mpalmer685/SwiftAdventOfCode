enum PuzzleError: Error {
    case noSavedResults
    case dayNotImplemented(_ day: Int)
    case partNotImplemented(_ part: Int)
}

extension PuzzleError: CustomStringConvertible {
    public var description: String {
        switch self {
            case .noSavedResults:
                return "No saved results yet."
            case let .dayNotImplemented(day):
                return "Solution for day \(day) not implemented"
            case let .partNotImplemented(part):
                return "Part \(part) not implemented"
        }
    }
}
