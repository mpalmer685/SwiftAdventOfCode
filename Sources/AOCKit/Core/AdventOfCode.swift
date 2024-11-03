public class AdventOfCode {
    var year: Int
    var puzzles: [any Puzzle]
    var savedResults: SavedResults

    public init(year: Int, puzzles: [any Puzzle]) {
        self.year = year
        self.puzzles = puzzles

        savedResults = SavedResults(year: year)
    }
}

extension AdventOfCode {
    func hasSavedResult(for day: Int, _ part: PuzzlePart) -> Bool {
        savedResults.answer(for: day, part) != nil
    }

    func puzzle(for day: Int) throws -> any Puzzle {
        guard let puzzle = puzzles.first(where: { type(of: $0).day == day }) else {
            throw PuzzleError.dayNotImplemented(day)
        }

        return puzzle
    }

    func run(_ puzzle: any Puzzle, part: PuzzlePart, with input: Input) throws -> String {
        let runPuzzle = part == .partOne ? puzzle.part1(input:) : puzzle.part2(input:)
        return try runPuzzle(input).description
    }
}
