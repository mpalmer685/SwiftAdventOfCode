import AOCKit

struct GiantSquid: Puzzle {
    static let day = 4

    func part1() throws -> Int {
        var (numbers, boards) = parseInput()

        for number in numbers {
            for i in boards.indices {
                boards[i].play(number)
                if boards[i].hasWon {
                    return number * boards[i].currentScore
                }
            }
        }

        fatalError("Didn't find a solution.")
    }

    func part2() throws -> Int {
        var (numbers, boards) = parseInput()

        var lastPlayedNumber: Int?
        var lastWinningBoard: Board?

        for number in numbers {
            for i in boards.indices where !boards[i].hasWon {
                boards[i].play(number)
                if boards[i].hasWon {
                    lastPlayedNumber = number
                    lastWinningBoard = boards[i]
                }
            }
        }

        guard let lastPlayedNumber = lastPlayedNumber,
              let lastWinningBoard = lastWinningBoard
        else {
            fatalError("Didn't find a winner.")
        }

        return lastPlayedNumber * lastWinningBoard.currentScore
    }

    private func parseInput() -> ([Int], [Board]) {
        let groups = input().lines.split(whereSeparator: \.isEmpty)

        let numbers = groups[0][0].csvWords.integers

        let boards = groups[1...].map { Board(input: Array($0)) }

        return (numbers, boards)
    }
}

private struct Board {
    private var groups: [[Int]]

    var currentScore: Int {
        groups.map(\.sum).sum / 2
    }

    var hasWon: Bool {
        groups.contains(where: \.isEmpty)
    }

    init(input: [Line]) {
        let rows = input.map { line in
            line.words.integers
        }

        let columns = (0 ..< rows[0].count).map { col in
            rows.map { $0[col] }
        }

        groups = rows + columns
    }

    mutating func play(_ number: Int) {
        for i in groups.indices {
            groups[i].removeAll(number)
        }
    }
}

private extension Array where Element: Hashable {
    mutating func removeAll(_ value: Element) {
        self = filter { $0 != value }
    }
}
