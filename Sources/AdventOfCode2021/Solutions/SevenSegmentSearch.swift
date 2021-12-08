import AOCKit

struct SevenSegmentSearch: Puzzle {
    func part1Solution(for input: String) throws -> Int {
        let outputDigits = parse(input).flatMap(\.output)
        let uniqueDigitLengths = [2, 3, 4, 7]
        return outputDigits.count { uniqueDigitLengths.contains($0.count) }
    }

    func part2Solution(for input: String) throws -> Int {
        parse(input).map(decode).compactMap(Int.init).reduce(0, +)
    }

    private func parse(_ input: String) -> [Entry] {
        getLines(from: input).map { line in
            let parts = line.components(separatedBy: " | ")
            let patterns = parts[0].components(separatedBy: .whitespaces)
            let output = parts[1].components(separatedBy: .whitespaces)
            return (output, patterns)
        }
    }
}

private typealias Entry = (output: [String], patterns: [String])

private func decode(_ digits: [String], using patterns: [String]) -> String {
    var patterns = patterns
    var decodedDigits = findUniqueDigits(in: &patterns)
    for pattern in patterns {
        let set = Set(pattern)
        switch pattern.count {
            case 5:
                if set.isStrictSuperset(of: decodedDigits[7]!) {
                    decodedDigits[3] = pattern
                } else if set.intersection(decodedDigits[4]!).count == 3 {
                    decodedDigits[5] = pattern
                } else {
                    decodedDigits[2] = pattern
                }
            case 6:
                if set.isStrictSuperset(of: decodedDigits[4]!) {
                    decodedDigits[9] = pattern
                } else if set.isStrictSuperset(of: decodedDigits[7]!) {
                    decodedDigits[0] = pattern
                } else {
                    decodedDigits[6] = pattern
                }
            default:
                fatalError("Unexpected pattern length: \(pattern.count)")
        }
    }

    return digits
        .map { findDecodedDigit(for: $0, in: decodedDigits) }
        .joined()
}

private func findDecodedDigit(for digit: String, in mapping: [Int: String]) -> String {
    guard let mappingEntry = mapping.first(where: { Set($0.value) == Set(digit) }) else {
        print("digit: \(digit)")
        print("mapping: \(mapping)")
        fatalError("Could not find mapping for digit.")
    }
    return String(mappingEntry.key)
}

private func findUniqueDigits(in patterns: inout [String]) -> [Int: String] {
    func findDigit(_ digit: String, withCount count: Int) -> String {
        guard let found = patterns.removeFirst(where: { $0.count == count }) else {
            fatalError("Could not find pattern for \(digit)")
        }
        return found
    }

    return [
        1: findDigit("1", withCount: 2),
        4: findDigit("4", withCount: 4),
        7: findDigit("7", withCount: 3),
        8: findDigit("8", withCount: 7),
    ]
}

private extension Array {
    mutating func removeFirst(where predicate: (Element) -> Bool) -> Element? {
        guard let index = firstIndex(where: predicate) else { return nil }
        return remove(at: index)
    }
}
