/*
 $ aoc2020
   Run all saved puzzles and check that solutions still return correctly

 $ aoc2020 -d 1
   Run all saved puzzles for the given day and check that solutions
   still return correctly

 $ aoc2020 -d 1 -p 1
   Run saved puzzle for the given day and part, and check that solution
   still returns correctly

 $ aoc2020 -d 1 -p 1 -i 1000
   Run puzzle for given day and part using the provided input, display the
   output, and prompt user to save answer if correct.
 */

public enum AOC {
    public static func run(puzzles: [PuzzleDay], resultsPath: String) {
        Command.puzzleCollection = PuzzleCollection(puzzles)
        Command
            .savedResults = (try? .load(from: resultsPath)) ??
            // swiftlint:disable:next force_try
            (try! SavedResults(path: resultsPath))
        Command.main()
    }
}
