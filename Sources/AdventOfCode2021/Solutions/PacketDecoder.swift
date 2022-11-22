import AOCKit

private let testInput1 = "D2FE28"
private let testInput2 = "38006F45291200"
private let testInput3 = "EE00D40C823060"
private let testInput4 = "8A004A801A8002F478"
private let testInput5 = "620080001611562C8802118E34"
private let testInput6 = "C0015000016115A2E0802F182340"
private let testInput7 = "A0016C880162017C3686B18A3D4780"

struct PacketDecoder: Puzzle {
    static let day = 16

    func part1() throws -> Int {
        let bits = bits(from: input())
        let packet = parsePacket(from: bits)
        return packet.versionSum
    }

    func part2() throws -> Int {
        let bits = bits(from: input())
        let packet = parsePacket(from: bits)
        return packet.value
    }
}

private func bits(from input: Input) -> [Character] {
    input.characters.reduce(into: []) { bits, hexDigit in
        guard let i = Int(hexDigit, radix: 16) else { fatalError() }
        let s = String(i, radix: 2).padded(toLength: 4, withPad: "0", padding: .left)
        bits += Array(s)
    }
}

private func parsePacket(from bits: [Character]) -> Packet {
    var bits = bits
    return parsePacket(from: &bits).packet
}

private func parsePacket(from bits: inout [Character]) -> (packet: Packet, bitsUsed: Int) {
    let originalLength = bits.count
    let (version, type) = parseHeader(from: &bits)
    let packet: Packet = type == 4
        ? .literal(version: version, value: parseLiteralValue(from: &bits))
        : .operation(version: version, type: type, packets: parseOperatorPackets(from: &bits))
    return (packet, originalLength - bits.count)
}

private func parseHeader(from bits: inout [Character]) -> (version: Int, type: Int) {
    guard bits.count > 6 else { fatalError("Not enough bits left") }
    let versionBits = bits[0 ..< 3].map(String.init).joined()
    let typeBits = bits[3 ..< 6].map(String.init).joined()
    bits.removeFirst(6)
    guard let version = Int(versionBits, radix: 2), let type = Int(typeBits, radix: 2) else {
        fatalError()
    }
    return (version, type)
}

private func parseLiteralValue(from bits: inout [Character]) -> Int {
    var valueBits = [Character]()
    repeat {
        let indicator = bits.first
        valueBits += bits[1 ... 4]
        bits.removeFirst(5)
        if indicator != "1" {
            break
        }
    } while true
    guard let value = Int(valueBits.map(String.init).joined(), radix: 2) else {
        fatalError()
    }
    return value
}

private func parseOperatorPackets(from bits: inout [Character]) -> [Packet] {
    guard let lengthType = bits.first else { fatalError() }
    if lengthType == "0" {
        let lengthBits = bits[1 ... 15].map(String.init).joined()
        guard let length = Int(lengthBits, radix: 2) else { fatalError() }
        bits.removeFirst(16)

        var packets = [Packet]()
        var totalRead = 0
        while totalRead < length {
            let (packet, bitsUsed) = parsePacket(from: &bits)
            packets.append(packet)
            totalRead += bitsUsed
        }
        return packets
    } else if lengthType == "1" {
        let lengthBits = bits[1 ... 11].map(String.init).joined()
        guard let length = Int(lengthBits, radix: 2) else { fatalError() }
        bits.removeFirst(12)

        var packets = [Packet]()
        while packets.count < length {
            packets.append(parsePacket(from: &bits).packet)
        }
        return packets
    }

    fatalError()
}

private enum Packet {
    case literal(version: Int, value: Int)
    case operation(version: Int, type: Int, packets: [Packet])

    var versionSum: Int {
        switch self {
            case let .literal(version: v, value: _):
                return v
            case let .operation(version: v, type: _, packets: packets):
                return v + packets.reduce(0) { $0 + $1.versionSum }
        }
    }

    var value: Int {
        switch self {
            case let .literal(version: _, value: value):
                return value
            case let .operation(version: _, type: type, packets: packets):
                return calculateValue(of: packets, withOperationType: type)
        }
    }
}

private func calculateValue(of packets: [Packet], withOperationType type: Int) -> Int {
    switch type {
        case 0:
            return packets.reduce(0) { $0 + $1.value }
        case 1:
            return packets.reduce(1) { $0 * $1.value }
        case 2:
            guard let min = packets.min(by: \.value)?.value else { fatalError() }
            return min
        case 3:
            guard let max = packets.max(by: \.value)?.value else { fatalError() }
            return max
        case 5:
            guard packets.count == 2 else { fatalError() }
            return packets[0].value > packets[1].value ? 1 : 0
        case 6:
            guard packets.count == 2 else { fatalError() }
            return packets[0].value < packets[1].value ? 1 : 0
        case 7:
            guard packets.count == 2 else { fatalError() }
            return packets[0].value == packets[1].value ? 1 : 0
        default:
            fatalError("Unknown operation type \(type)")
    }
}

private extension Int {
    init?(_ character: Character, radix: Int = 10) {
        self.init(String(character), radix: radix)
    }
}
