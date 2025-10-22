enum PuzzleError: Error {
    case noSavedResults
    case dayNotImplemented(_ day: Int)
    case partNotImplemented(_ part: Int)
    case noPuzzleInput(_ day: Int)
    case testableNotImplemented
    case noTestCases
}

extension PuzzleError: CustomStringConvertible {
    var description: String {
        switch self {
            case let .noPuzzleInput(day):
                "Could not find or download an input file for day \(day)"
            case .noSavedResults:
                "No saved results yet."
            case let .dayNotImplemented(day):
                "Solution for day \(day) not implemented"
            case let .partNotImplemented(part):
                "Part \(part) not implemented"
            case .testableNotImplemented:
                "TestablePuzzle not implemented"
            case .noTestCases:
                "No test cases found"
        }
    }
}
