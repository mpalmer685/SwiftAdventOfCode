import AOCKit

struct AdapterArray: Puzzle {
    static let day = 10

    func part1() throws -> Int {
        let adapters = getAdapters().sorted()
        var differencesOfOne = 0
        var differencesOfThree = 0

        for i in 1 ..< adapters.count {
            let difference = adapters[i] - adapters[i - 1]
            guard difference < 4 else { throw AdapterArrayError.unexpectedInput }

            switch difference {
                case 1:
                    differencesOfOne += 1
                case 3:
                    differencesOfThree += 1
                default:
                    break
            }
        }

        return differencesOfOne * differencesOfThree
    }

    func part2() throws -> Int {
        let adapters = getAdapters().sorted()
        var scores = [Int](repeating: 0, count: adapters.count)
        scores[0] = 1

        for i in 0 ..< adapters.count - 1 {
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
