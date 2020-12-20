public struct PuzzleDay {
    let day: Int
    let part1: StringPuzzleSolution
    let part2: StringPuzzleSolution

    public static func day<T: Puzzle>(_ day: Int, _ puzzle: T) -> PuzzleDay {
        PuzzleDay(
            day: day,
            part1: wrap(puzzle.part1Solution),
            part2: wrap(puzzle.part2Solution)
        )
    }

    private static func wrap<T: CustomStringConvertible>(_ solution: @escaping PuzzleSolution<T>)
        -> StringPuzzleSolution
    {
        { try solution($0).description }
    }
}
