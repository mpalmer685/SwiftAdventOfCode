import AOCKit

struct ReportRepair: Puzzle {
    func part1Solution(for input: String) throws -> Int {
        let entries = getLines(from: input).compactMap(Int.init)
        guard let (first, second) = findPair(totaling: 2020, in: entries) else {
            throw ReportRepairError.noMatchesFound
        }
        return first * second
    }

    func part2Solution(for input: String) throws -> Int {
        let entries = getLines(from: input).compactMap(Int.init).sorted()
        for (i, entry) in entries.enumerated() {
            let goalTotal = 2020 - entry
            if let (first, second) = findPair(
                totaling: goalTotal,
                in: entries[i + 1 ..< entries.endIndex]
            ) {
                return entry * first * second
            }
        }
        throw ReportRepairError.noMatchesFound
    }

    private func findPair<T: Collection>(totaling goal: Int, in array: T) -> (Int, Int)?
        where T.Element == Int
    {
        let sorted = array.sorted()
        var low = sorted.startIndex
        var high = sorted.endIndex - 1
        while low < high {
            let first = sorted[low]
            let second = sorted[high]
            let total = first + second

            if total < goal {
                low += 1
            } else if total > goal {
                high -= 1
            } else {
                return (first, second)
            }
        }
        return nil
    }
}

enum ReportRepairError: Error {
    case noMatchesFound
}
