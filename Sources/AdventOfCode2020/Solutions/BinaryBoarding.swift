import AOCKit
import Foundation

struct BinaryBoarding: Puzzle {
    func part1Solution(for input: String) throws -> UInt {
        getLines(from: input).map(BoardingPass.init).map(\.seatId).max()!
    }

    func part2Solution(for input: String) throws -> UInt {
        let seatIds = getLines(from: input).map(BoardingPass.init).map(\.seatId).sorted()
        let min = seatIds.min()!
        let max = seatIds.max()!
        let allSeats = Array(min...max)
        return allSeats.first { !seatIds.contains($0) && seatIds.contains($0 + 1) && seatIds.contains($0 - 1) }!
    }
}

fileprivate struct BoardingPass {
    private var row: UInt
    private var column: UInt

    var seatId: UInt { row * 8 + column }

    init(string: String) {
        row = Self.parseValue(from: string[0..<7], upperHalfSymbol: "B")
        column = Self.parseValue(from: string[7..<10], upperHalfSymbol: "R")
    }

    private static func parseValue(from regions: Substring, upperHalfSymbol: Character) -> UInt {
        let binaryString = regions.map { $0 == upperHalfSymbol ? "1" : "0" }.joined()
        return UInt(binaryString, radix: 2)!
    }
}

fileprivate extension String {
    subscript(range: Range<Int>) -> Substring {
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)
        return self[start..<end]
    }
}
