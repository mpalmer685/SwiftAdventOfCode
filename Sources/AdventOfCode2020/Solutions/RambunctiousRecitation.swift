import AOCKit

struct RambunctiousRecitation: Puzzle {
    static let day = 15
    static let rawInput: String? = "5,1,9,18,13,8,0"

    func part1() throws -> Int {
        let startingNumbers = input().csvWords.integers
        return play(turns: 2020, startingWith: startingNumbers)
    }

    func part2() throws -> Int {
        let startingNumbers = input().csvWords.integers
        return play(turns: 30_000_000, startingWith: startingNumbers)
    }

    private func play(turns: Int, startingWith startingNumbers: [Int]) -> Int {
        var numbersRead: [Int: (Int, Int?)] =
            Dictionary(uniqueKeysWithValues: zip(startingNumbers, 0...).map { ($0.0, ($0.1, nil)) })
        var lastNumber = startingNumbers.last!

        func addTurn(_ turn: Int, for number: Int) {
            if let (lastTurn, _) = numbersRead[number] {
                numbersRead[number] = (turn, lastTurn)
            } else {
                numbersRead[number] = (turn, nil)
            }
        }

        for turn in startingNumbers.count ..< turns {
            guard let (lastTurn, priorTurn) = numbersRead[lastNumber] else { fatalError() }
            if let priorTurn = priorTurn {
                lastNumber = lastTurn - priorTurn
            } else {
                lastNumber = 0
            }
            addTurn(turn, for: lastNumber)
        }

        return lastNumber
    }
}
