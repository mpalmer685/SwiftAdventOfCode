import AOCKit

struct ReportRepair: Puzzle {
    func part1Solution(for input: String) throws -> Int {
        let entries = getLines(from: input).compactMap(Int.init)
        guard let (first, second) = entries.findPair(totaling: 2020) else {
            throw ReportRepairError.noMatchesFound
        }
        return first * second
    }

    func part2Solution(for input: String) throws -> Int {
        let entries = getLines(from: input).compactMap(Int.init).sorted()
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
