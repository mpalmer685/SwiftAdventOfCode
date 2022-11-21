import AOCKit

struct EncodingError: Puzzle {
    static let day = 9

    func part1() throws -> Int {
        let data = input().lines.integers
        return findInvalidNumber(in: data)
    }

    func part2() throws -> Int {
        let data = input().lines.integers
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

    private func isValid<T: Collection>(value: Int, in collection: T) -> Bool
        where T.Element == Int
    {
        collection.findPair(totaling: value) != nil
    }
}
