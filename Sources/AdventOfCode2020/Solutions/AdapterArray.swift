import AOCKit

struct AdapterArray: Puzzle {
    static let day = 10

    func part1() throws -> Int {
        let adapters = getAdapters().sorted(by: >)
        let differences = adapters.adjacentPairs().map(-)
        let differencesOfOne = differences.count(of: 1)
        let differencesOfThree = differences.count(of: 3)

        return differencesOfOne * differencesOfThree
    }

    func part2() throws -> Int {
        let adapters = getAdapters().sorted()
        var scores = [Int](repeating: 0, count: adapters.count)
        scores[0] = 1

        for i in adapters.indices {
            let value = adapters[i]
            let score = scores[i]

            for j in (i + 1) ... (i + 3) where j < adapters.count && adapters[j] - value < 4 {
                scores[j] += score
            }
        }

        return scores.last!
    }

    private func getAdapters() -> [Int] {
        let data = input().lines.integers
        return [0] + data + [data.max()! + 3]
    }
}

enum AdapterArrayError: Error {
    case unexpectedInput
}

private extension Collection where Element: Equatable {
    func count(of element: Element) -> Int {
        count(where: { $0 == element })
    }
}
