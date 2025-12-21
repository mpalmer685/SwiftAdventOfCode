import AOCKit

struct LetItSnow: Puzzle {
    static let day = 25

    func part1(input: Input) async throws -> Int {
        let ints = input.lines[0].integers
        let row = ints[0]
        let column = ints[1]
        let targetIndex = triangleIndex(for: (row, column))

        return (0 ..< targetIndex).reduce(20_151_125) { currentCode, _ in
            (currentCode * 252_533) % 33_554_393
        }
    }

    private func triangleIndex(for position: (row: Int, column: Int)) -> Int {
        let (row, column) = position
        let diagonal = row + column - 1
        let diagonalStartIndex = (diagonal - 1) * diagonal / 2
        return diagonalStartIndex + (column - 1)
    }
}
