import AOCKit

struct Scratchcards: Puzzle {
    static let day = 4

    // static let rawInput: String? = """
    // Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
    // Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
    // Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
    // Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
    // Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
    // Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    // """

    func part1(input: Input) throws -> Decimal {
        input.lines.map { line in
            let count = winningNumberCount(for: line)
            return count == 0 ? 0 : pow(2, count - 1)
        }.sum
    }

    func part2(input: Input) throws -> Int {
        let lines = input.lines
        var counts = Array(1 ... lines.count).reduce(into: [:]) { $0[$1] = 1 }
        for (index, line) in lines.enumerated() {
            let currentCount = counts[index + 1]!
            let winCount = winningNumberCount(for: line)
            guard winCount > 0 else { continue }
            for i in 1 ... winCount {
                counts[index + 1 + i]! += currentCount
            }
        }

        return counts.sum(of: \.value)
    }

    private func winningNumberCount(for line: Line) -> Int {
        let numbers = line.words(separatedBy: ": ")[1].words(separatedBy: " | ")
        let winningNumbers = Set(numbers[0].words(separatedBy: .whitespaces).integers)
        let cardNumbers = Set(numbers[1].words(separatedBy: .whitespaces).integers)
        return winningNumbers.intersection(cardNumbers).count
    }
}
