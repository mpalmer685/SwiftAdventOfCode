import AOCKit

struct EncodingError: Puzzle {
    static let day = 9

    func part1(input: Input) throws -> Int {
        let data = input.lines.integers
        return findInvalidNumber(in: data)
    }

    func part2(input: Input) throws -> Int {
        let data = input.lines.integers
        let invalidNumber = findInvalidNumber(in: data)
        guard let range = data.findContiguousRange(totaling: invalidNumber) else {
            fatalError()
        }
        return range.min()! + range.max()!
    }

    private func findInvalidNumber(in data: [Int]) -> Int {
        let preambleLength = 25
        let index = (preambleLength ..< data.count).first { i in
            !data[i - preambleLength ..< i].containsPair(totaling: data[i])
        }
        guard let index else { fatalError() }
        return data[index]
    }
}

private extension Collection where Element == Int {
    func containsPair(totaling target: Int) -> Bool {
        findPair(totaling: target) != nil
    }
}
