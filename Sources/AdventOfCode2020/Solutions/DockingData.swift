import AOCKit

struct DockingData: Puzzle {
    static let day = 14

    func part1(input: Input) throws -> Int {
        let instructions = input.lines.raw.map(Instruction.init)
        var memory: [Int: Int] = [:]
        var mask = MaskV1("1")
        for instruction in instructions {
            switch instruction {
                case let .updateMask(newMask):
                    mask = MaskV1(newMask)
                case let .writeValue(value, address):
                    memory[address] = mask.modify(value)
            }
        }
        return memory.values.reduce(0, +)
    }

    func part2(input: Input) throws -> Int {
        let instructions = input.lines.raw.map(Instruction.init)
        var memory: [Int: Int] = [:]
        var mask = MaskV2("1")
        for instruction in instructions {
            switch instruction {
                case let .updateMask(newMask):
                    mask = MaskV2(newMask)
                case let .writeValue(value, address):
                    for memAddress in mask.modify(address) {
                        memory[memAddress] = value
                    }
            }
        }
        return memory.values.reduce(0, +)
    }
}

private struct MaskV1 {
    private var andMask: Int
    private var orMask: Int

    init(_ string: String) {
        let andPattern = string.replacingOccurrences(of: "X", with: "1")
        let orPattern = string.replacingOccurrences(of: "X", with: "0")

        andMask = Int(andPattern, radix: 2)!
        orMask = Int(orPattern, radix: 2)!
    }

    func modify(_ value: Int) -> Int {
        value & andMask | orMask
    }
}

private struct MaskV2 {
    private var masks: [MaskV1]

    init(_ string: String) {
        var masks = [""]

        for ch in string {
            switch ch {
                case "0": masks = masks.map { $0 + "X" }
                case "1": masks = masks.map { $0 + "1" }
                case "X":
                    masks = masks.map { $0 + "0" } + masks.map { $0 + "1" }
                default:
                    fatalError()
            }
        }

        self.masks = masks.map(MaskV1.init)
    }

    func modify(_ value: Int) -> [Int] {
        masks.map { $0.modify(value) }
    }
}

private enum Instruction {
    case updateMask(mask: String)
    case writeValue(value: Int, address: Int)

    private static let maskPattern = NSRegularExpression("mask = ([10X]{36})")
    private static let writePattern = NSRegularExpression("mem\\[(\\d+)\\] = (\\d+)")

    init(_ line: String) {
        if let match = Self.maskPattern.match(line) {
            self = .updateMask(mask: match[1])
        } else if let match = Self.writePattern.match(line) {
            self = .writeValue(value: Int(match[2])!, address: Int(match[1])!)
        } else {
            fatalError()
        }
    }
}
