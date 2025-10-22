public final class AdventOfCodeEvent: Sendable {
    public let year: Int
    public let puzzles: [any Puzzle]

    public init(year: Int, puzzles: [any Puzzle]) {
        self.year = year
        self.puzzles = puzzles
    }

    public func puzzle(for day: Int) throws -> any Puzzle {
        guard let puzzle = puzzles.first(where: { type(of: $0).day == day }) else {
            throw PuzzleError.dayNotImplemented(day)
        }

        return puzzle
    }
}
