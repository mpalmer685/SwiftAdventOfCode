import AOCKit

struct EncodingError: Puzzle {
    func part1Solution(for input: String) throws -> Int {
        let data = getLines(from: input).compactMap(Int.init)
        return findInvalidNumber(in: data)
    }

    func part2Solution(for input: String) throws -> Int {
        let data = getLines(from: input).compactMap(Int.init)
        let invalidNumber = findInvalidNumber(in: data)
        guard let range = data.findContiguousRange(totaling: invalidNumber) else {
            fatalError()
        }
        return range.min()! + range.max()!
    }

    private func findInvalidNumber(in data: [Int]) -> Int {
        let preambleLength = 25
        for index in preambleLength ..< data.count where !isValid(
            value: data[index],
            in: data[index - preambleLength ... index - 1]
        ) {
            return data[index]
        }
        fatalError()
    }

    private func isValid<T: Collection>(value: Int, in collection: T) -> Bool where T.Element == Int {
        collection.findPair(totaling: value) != nil
    }
}
