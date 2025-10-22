enum PuzzlePart: Int, CaseIterable {
    case partOne = 1
    case partTwo = 2
}

extension PuzzlePart: CustomStringConvertible {
    var description: String {
        String(rawValue)
    }
}
