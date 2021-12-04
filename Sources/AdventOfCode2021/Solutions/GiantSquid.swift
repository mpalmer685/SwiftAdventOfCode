import AOCKit

struct GiantSquid: Puzzle {
    func part1Solution(for input: String) throws -> Int {
        var (numbers, boards) = parse(input)

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

    func part2Solution(for input: String) throws -> Int {
        var (numbers, boards) = parse(input)

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

    private func parse(_ input: String) -> ([Int], [Board]) {
        let groups = getLines(from: input, omittingEmptyLines: false)
            .split(whereSeparator: \.isEmpty)

        let numbers = groups[0][0].split(separator: ",").compactMap { Int(String($0)) }

        let boards = groups[1...].map { Board(input: Array($0)) }

        return (numbers, boards)
    }
}

private struct Board {
    private var groups: [[Int]]

    var currentScore: Int {
        groups.reduce(0) { $0 + $1.reduce(0, +) } / 2
    }

    var hasWon: Bool {
        groups.contains(where: \.isEmpty)
    }

    init(input: [String]) {
        let rows = input.map { line in
            line.components(separatedBy: .whitespaces).compactMap(Int.init)
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
