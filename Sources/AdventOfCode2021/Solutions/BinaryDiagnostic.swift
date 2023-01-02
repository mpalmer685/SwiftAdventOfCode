import AOCKit

struct BinaryDiagnostic: Puzzle {
    static let day = 3

    func part1() throws -> Int {
        let data = parseInput()
        let bitCount = data[0].count
        guard data.allSatisfy({ $0.count == bitCount }) else {
            throw BinaryDiagnosticError.inconsistentBitCount
        }

        let gammaRateBits = try (0 ..< bitCount).map { index in
            let digits = data.map { $0[index] }
            let mostCommonDigit = try selectValue(in: digits, using: { $0.max(by: \.value) })
            return String(mostCommonDigit)
        }.joined()
        let epsilonRateBits = try invert(gammaRateBits)

        guard let gammaRate = Int(gammaRateBits, radix: 2),
              let epsilonRate = Int(epsilonRateBits, radix: 2)
        else {
            throw BinaryDiagnosticError.invalidResult
        }

        return gammaRate * epsilonRate
    }

    func part2() throws -> Int {
        let data = parseInput()
        let bitCount = data[0].count
        guard data.allSatisfy({ $0.count == bitCount }) else {
            throw BinaryDiagnosticError.inconsistentBitCount
        }

        var oxygenGeneratorData = data
        var index = 0
        while oxygenGeneratorData.count > 1, index < bitCount {
            let digits = oxygenGeneratorData.map { $0[index] }
            let digitToSelect = try selectValue(
                in: digits,
                using: selectMax,
                withTieBreaker: "1"
            )
            oxygenGeneratorData.removeAll { $0[index] != digitToSelect }
            index += 1
        }

        var scrubberData = data
        index = 0
        while scrubberData.count > 1, index < bitCount {
            let digits = scrubberData.map { $0[index] }
            let digitToSelect = try selectValue(
                in: digits,
                using: selectMin,
                withTieBreaker: "0"
            )
            scrubberData.removeAll { $0[index] != digitToSelect }
            index += 1
        }

        guard let oxygenGeneratorBits = oxygenGeneratorData.first?.map(String.init),
              let co2ScrubberBits = scrubberData.first?.map(String.init),
              let oxygenGeneratorRating = Int(oxygenGeneratorBits.joined(), radix: 2),
              let co2ScrubberRating = Int(co2ScrubberBits.joined(), radix: 2)
        else {
            throw BinaryDiagnosticError.invalidResult
        }

        return oxygenGeneratorRating * co2ScrubberRating
    }

    private func parseInput() -> [[Character]] {
        input().lines.characters
    }
}

private typealias ElementSelector<Key: Hashable, Value> = ([Key: Value]) -> Dictionary<Key, Value>
    .Element?

private let selectMin: ElementSelector<Character, Int> = { $0.min(by: \.value) }
private let selectMax: ElementSelector<Character, Int> = { $0.max(by: \.value) }

private func selectValue(
    in digits: [Character],
    using select: ElementSelector<Character, Int>,
    withTieBreaker tieBreaker: Character = " "
) throws -> Character {
    let counts: [Character: Int] = digits.reduce(into: [:]) { counts, digit in
        counts[digit] = (counts[digit] ?? 0) + 1
    }

    if counts.allSatisfy({ $0.value == counts.first?.value }) {
        return tieBreaker
    }

    guard let selected = select(counts)?.key else { throw BinaryDiagnosticError.computeError }
    return selected
}

private func invert(_ binaryString: String) throws -> String {
    func inverted(_ bit: Character) throws -> String {
        switch bit {
            case "0": return "1"
            case "1": return "0"
            default: throw BinaryDiagnosticError.invalidResult
        }
    }

    return try Array(binaryString).map(inverted).joined()
}

private enum BinaryDiagnosticError: Error {
    case inconsistentBitCount, invalidResult, computeError
}
