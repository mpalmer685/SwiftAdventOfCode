public class PuzzleCollection {
    private let puzzleDays: [UInt8 : PuzzleDay]

    public init(_ puzzles: [PuzzleDay]) {
        self.puzzleDays = puzzles.reduce(into: [:]) { $0[$1.day] = $1 }
    }

    func runPuzzle(day: UInt8, part: PuzzlePart, input: String) throws -> String {
        guard let puzzle = puzzleDays[day] else {
            throw PuzzleError.dayNotImplemented(day)
        }

        let runPuzzle = part == .partOne ? puzzle.part1 : puzzle.part2
        return try runPuzzle(input)
    }
}
