public class AdventOfCodeEvent {
    let year: Int
    let puzzles: [any Puzzle]

    var savedResults: SavedResults

    public init(year: Int, puzzles: [any Puzzle]) {
        self.year = year
        self.puzzles = puzzles

        savedResults = SavedResults(year: year)
    }
}
