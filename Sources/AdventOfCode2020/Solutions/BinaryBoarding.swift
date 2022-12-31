import AOCKit

struct BinaryBoarding: Puzzle {
    static let day = 5

    func part1() throws -> UInt {
        input().lines.raw.map(BoardingPass.init).map(\.seatId).max()!
    }

    func part2() throws -> UInt {
        let seatIds = input().lines.raw.map(BoardingPass.init).map(\.seatId).sorted()
        return binarySearchFindMissing(from: seatIds)
    }

    private func bruteForceFindMissing(from seats: [UInt]) -> UInt {
        let (min, max) = extent(of: seats)
        let allSeats = Array(min ... max)
        return allSeats
            .first { !seats.contains($0) && seats.contains($0 + 1) && seats.contains($0 - 1) }!
    }

    private func offByOneFindMissing(from seats: [UInt]) -> UInt {
        for (i, seatId) in seats.enumerated()
            where i > 0 && i < seats.endIndex - 1 && seats[i + 1] - seatId > 1
        {
            return seatId + 1
        }
        return 0
    }

    private func binarySearchFindMissing(from seats: [UInt]) -> UInt {
        var low = 0,
            high = seats.count - 1,
            mid = 0
        while high - low > 1 {
            mid = (high + low) / 2
            if (seats[low] - UInt(low)) != (seats[mid] - UInt(mid)) {
                high = mid
            } else if (seats[high] - UInt(high)) != (seats[mid] - UInt(mid)) {
                low = mid
            }
        }
        return seats[low] + 1
    }

    private func extent<T: Comparable>(of array: [T]) -> (min: T, max: T) {
        let min = array.min()!
        let max = array.max()!
        return (min, max)
    }
}

private struct BoardingPass {
    private var row: UInt
    private var column: UInt

    var seatId: UInt { row * 8 + column }

    init(string: String) {
        row = Self.parseValue(from: string[0 ..< 7], upperHalfSymbol: "B")
        column = Self.parseValue(from: string[7 ..< 10], upperHalfSymbol: "R")
    }

    private static func parseValue(from regions: Substring, upperHalfSymbol: Character) -> UInt {
        let binaryString = regions.map { $0 == upperHalfSymbol ? "1" : "0" }.joined()
        return UInt(binaryString, radix: 2)!
    }
}

private extension String {
    subscript(range: Range<Int>) -> Substring {
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)
        return self[start ..< end]
    }
}
