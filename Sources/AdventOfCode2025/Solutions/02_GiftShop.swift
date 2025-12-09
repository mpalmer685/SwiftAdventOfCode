import AOCKit

struct GiftShop: Puzzle {
    static let day = 2

    func part1(input: Input) async throws -> Int {
        sumOfInvalidIds(in: input) { id in
            let idString = String(id)
            guard idString.count.isMultiple(of: 2) else {
                return false
            }

            let midIndex = idString.index(idString.startIndex, offsetBy: idString.count / 2)
            return idString[idString.startIndex ..< midIndex] ==
                idString[midIndex ..< idString.endIndex]
        }
    }

    func part2(input: Input) async throws -> Int {
        let multiples = [
            1: [],
            2: [11],
            3: [111],
            4: [101],
            5: [11111],
            6: [1001, 10101],
            7: [1_111_111],
            8: [1_010_101, 10001],
            9: [1_001_001],
            10: [101_010_101, 100_001],
        ]

        return sumOfInvalidIds(in: input) { id in
            let idLength = Int(log10(Double(id))) + 1
            guard let targetMultiples = multiples[idLength] else {
                fatalError("No multiples defined for id length \(idLength)")
            }
            return targetMultiples.contains { id.isMultiple(of: $0) }
        }
    }

    private func sumOfInvalidIds(in input: Input, using isInvalidId: (Int) -> Bool) -> Int {
        let ranges = input.csvWords.map { word in
            let parts = word.words(separatedBy: "-")
            guard let lower = parts[0].integer, let upper = parts[1].integer else {
                fatalError("Invalid input \(word)")
            }
            return lower ... upper
        }

        return ranges.sum { $0.filter(isInvalidId).sum }
    }
}

extension GiftShop: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.example).expects(part1: 1_227_775_554, part2: 4_174_379_265),
        ]
    }
}
