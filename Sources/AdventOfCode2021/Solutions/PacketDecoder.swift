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

    func part1(input: Input) throws -> Int {
        var scanner = Scanner(bits(from: input))
        let packet = scanner.scanPacket()
        return packet.versionSum
    }

    func part2(input: Input) throws -> Int {
        var scanner = Scanner(bits(from: input))
        let packet = scanner.scanPacket()
        return packet.value
    }
}

private func bits(from input: Input) -> [Character] {
    input.characters.flatMap { hexDigit -> [Character] in
        guard let i = Int(hexDigit, radix: 16) else { fatalError() }
        let s = String(i, radix: 2).padded(toLength: 4, withPad: "0", padding: .left)
        return Array(s)
    }
}

private extension Scanner where C == [Character] {
    mutating func scanPacket() -> Packet {
        scanNextPacket().packet
    }

    private mutating func scanNextPacket() -> (packet: Packet, bitsUsed: Int) {
        let start = location
        let (version, type) = scanHeader()
        let packet: Packet = type == 4
            ? .literal(version: version, value: scanLiteralValue())
            : .operation(version: version, type: type, packets: scanOperatorPackets())
        return (packet, location - start)
    }

    private mutating func scanHeader() -> (version: Int, type: Int) {
        let version = Int(bits: scan(count: 3).bits)
        let type = Int(bits: scan(count: 3).bits)
        return (version, type)
    }

    private mutating func scanLiteralValue() -> Int {
        var valueBits = [Bool]()
        while true {
            let indicator = next()
            valueBits += scan(count: 4).bits
            if indicator != "1" {
                break
            }
        }
        return Int(bits: valueBits)
    }

    private mutating func scanOperatorPackets() -> [Packet] {
        let lengthType = next()
        if lengthType == "0" {
            let length = Int(bits: scan(count: 15).bits)
            var packets = [Packet]()
            var totalRead = 0

            while totalRead < length {
                let (packet, bitsUsed) = scanNextPacket()
                packets.append(packet)
                totalRead += bitsUsed
            }
            return packets
        }
        if lengthType == "1" {
            let length = Int(bits: scan(count: 11).bits)
            var packets = [Packet]()

            while packets.count < length {
                packets.append(scanNextPacket().packet)
            }
            return packets
        }
        fatalError()
    }
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
            return packets.sum(of: \.value)
        case 1:
            return packets.product(of: \.value)
        case 2:
            return packets.min(of: \.value)!
        case 3:
            return packets.max(of: \.value)!
        case 5:
            return (packets[0].value > packets[1].value).bit
        case 6:
            return (packets[0].value < packets[1].value).bit
        case 7:
            return (packets[0].value == packets[1].value).bit
        default:
            fatalError("Unknown operation type \(type)")
    }
}

private extension Int {
    init?(_ character: Character, radix: Int = 10) {
        self.init(String(character), radix: radix)
    }
}

private extension Character {
    var bit: Bool { self == "1" }
}

private extension Sequence where Element == Character {
    var bits: [Bool] { map(\.bit) }
}

private extension Bool {
    var bit: Int { self ? 1 : 0 }
}
