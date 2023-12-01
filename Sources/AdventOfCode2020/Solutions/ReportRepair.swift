import AOCKit

struct ReportRepair: Puzzle {
    static let day = 1

    func part1(input: Input) throws -> Int {
        let entries = input.lines.integers
        guard let (first, second) = entries.findPair(totaling: 2020) else {
            throw ReportRepairError.noMatchesFound
        }
        return first * second
    }

    func part2(input: Input) throws -> Int {
        let entries = input.lines.integers.sorted()
        for (i, entry) in entries.enumerated() {
            let goalTotal = 2020 - entry
            let collection = entries[(i + 1)...]
            if let (first, second) = collection.findPair(totaling: goalTotal) {
                return entry * first * second
            }
        }
        throw ReportRepairError.noMatchesFound
    }
}

enum ReportRepairError: Error {
    case noMatchesFound
}
