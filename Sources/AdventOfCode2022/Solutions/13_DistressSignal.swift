import AOCKit

struct DistressSignal: Puzzle {
    static let day = 13

    private func packets(from input: Input) -> [Packet] {
        input.lines.raw.filter(\.isNotEmpty).map(parsePacket)
    }

    func part1(input: Input) throws -> Int {
        packets(from: input).pairs().enumerated().sum { offset, pair -> Int in
            pair.0 < pair.1 ? offset + 1 : 0
        }
    }

    func part2(input: Input) throws -> Int {
        let divider1 = parsePacket("[[2]]")
        let divider2 = parsePacket("[[6]]")

        let sortedPackets = (packets(from: input) + [divider1, divider2]).sorted(by: <)

        let divider1Index = sortedPackets.firstIndex(of: divider1)! + 1
        let divider2Index = sortedPackets.firstIndex(of: divider2)! + 1

        return divider1Index * divider2Index
    }

    private func parsePacket(_ line: String) -> Packet {
        func parsePacket(_ scanner: inout Scanner<String>) -> Packet? {
            guard scanner.hasMore, scanner.peek() != "]" else { return nil }
            if scanner.peek() == "[" {
                scanner.next()
                var list = [Packet]()
                while let packet = parsePacket(&scanner) {
                    list.append(packet)
                    scanner.skip(",")
                }
                scanner.expect("]")
                return .list(list)
            } else {
                let value = scanner.scanInt()!
                return .integer(value)
            }
        }

        var scanner = Scanner(line)
        return parsePacket(&scanner)!
    }
}

private enum Packet {
    case list([Packet])
    case integer(Int)
}

extension Packet: Comparable {
    static func == (lhs: Self, rhs: Self) -> Bool { compare(lhs, to: rhs) == .orderedSame }
    static func < (lhs: Self, rhs: Self) -> Bool { compare(lhs, to: rhs) == .orderedAscending }
    static func > (lhs: Self, rhs: Self) -> Bool { compare(lhs, to: rhs) == .orderedDescending }

    private static func compare(_ lhs: Self, to rhs: Self) -> ComparisonResult {
        switch (lhs, rhs) {
            case let (.integer(l), .integer(r)):
                return l.compare(r)

            case let (.list(l), .list(r)):
                for (pl, pr) in zip(l, r) {
                    let result = compare(pl, to: pr)
                    if result != .orderedSame {
                        return result
                    }
                }
                if l.count < r.count { return .orderedAscending }
                if l.count > r.count { return .orderedDescending }
                return .orderedSame

            case (.integer, .list):
                return compare(.list([lhs]), to: rhs)

            case (.list, .integer):
                return compare(lhs, to: .list([rhs]))
        }
    }
}

extension Packet: CustomStringConvertible {
    public var description: String {
        switch self {
            case let .integer(i): String(i)
            case let .list(l): "[" + l.map(String.init).joined(separator: ",") + "]"
        }
    }
}

private extension Collection {
    func pairs() -> [(Element, Element)] {
        var pairs: [(Element, Element)] = []

        var i = makeIterator()
        while let first = i.next(), let second = i.next() {
            pairs.append((first, second))
        }

        return pairs
    }
}

private extension Comparable {
    func compare(_ other: Self) -> ComparisonResult {
        if self < other { return .orderedAscending }
        if self == other { return .orderedSame }
        return .orderedDescending
    }
}
