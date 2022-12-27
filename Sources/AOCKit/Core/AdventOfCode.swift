public class AdventOfCode {
    var year: Int
    var puzzles: [any Puzzle]
    var savedResults: SavedResults

    public init(year: Int, puzzles: [any Puzzle]) {
        self.year = year
        self.puzzles = puzzles

        savedResults = .load(from: "Results/\(year).json")
    }
}

extension AdventOfCode {
    func hasSavedResult(for day: Int, _ part: PuzzlePart) -> Bool {
        savedResults.answer(for: day, part) != nil
    }

    func runPuzzle(for day: Int, part: PuzzlePart) throws -> String {
        guard let puzzle = puzzles.first(where: { type(of: $0).day == day }) else {
            throw PuzzleError.dayNotImplemented(day)
        }

        let runPuzzle = part == .partOne ? puzzle.part1 : puzzle.part2
        return try runPuzzle().description
    }
}
