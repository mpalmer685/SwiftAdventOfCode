import AOCKit

struct ComboBreaker: Puzzle {
    func part1Solution(for input: String) throws -> Int {
        let (cardPublicKey, doorPublicKey) = parse(input)

        var cardValue = 1,
            doorValue = 1,
            loopTest = 1

        while loopTest != cardPublicKey, loopTest != doorPublicKey {
            cardValue.transform(subjectNumber: doorPublicKey)
            doorValue.transform(subjectNumber: cardPublicKey)
            loopTest.transform(subjectNumber: 7)
        }

        return loopTest == cardPublicKey ? cardValue : doorValue
    }

    private func parse(_ input: String) -> (Int, Int) {
        let keys = getLines(from: input).compactMap(Int.init)
        return (keys[0], keys[1])
    }
}

private extension Int {
    mutating func transform(subjectNumber: Int) {
        self = (self * subjectNumber) % 20_201_227
    }
}
