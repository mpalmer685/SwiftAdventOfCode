public struct PuzzleDay {
    let day: UInt8
    let part1: StringPuzzleSolution
    let part2: StringPuzzleSolution

    public static func day<T: Puzzle>(_ day: UInt8, _ puzzleType: T.Type) -> PuzzleDay {
        let puzzle = T()
        return PuzzleDay(
            day: day,
            part1: wrap { try puzzle.part1Solution(for: $0) },
            part2: wrap { try puzzle.part2Solution(for: $0) }
        )
    }

    private static func wrap<T: CustomStringConvertible>(_ solution: @escaping PuzzleSolution<T>) -> StringPuzzleSolution {
        { try solution($0).description }
    }
}
