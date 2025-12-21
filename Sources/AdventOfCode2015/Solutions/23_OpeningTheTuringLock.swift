import AOCKit

struct OpeningTheTuringLock: Puzzle {
    static let day = 23

    func part1(input: Input) async throws -> Int {
        let instructions = input.lines.map { Computer.Instruction.from($0) }
        var computer = Computer(instructions: instructions)
        computer.run()
        return computer.registerB
    }

    func part2(input: Input) async throws -> Int {
        let instructions = input.lines.map { Computer.Instruction.from($0) }
        var computer = Computer(instructions: instructions)
        computer.registers[.a] = 1
        computer.run()
        return computer.registerB
    }
}

private struct Computer {
    enum Register: String {
        case a, b
    }

    enum Instruction {
        case hlf(Register)
        case tpl(Register)
        case inc(Register)
        case jmp(Int)
        case jie(Register, Int)
        case jio(Register, Int)

        static func from(_ line: Line) -> Self {
            if line.raw.hasPrefix("hlf") {
                let register = Register(rawValue: line.words[1].raw)!
                return .hlf(register)
            } else if line.raw.hasPrefix("tpl") {
                let register = Register(rawValue: line.words[1].raw)!
                return .tpl(register)
            } else if line.raw.hasPrefix("inc") {
                let register = Register(rawValue: line.words[1].raw)!
                return .inc(register)
            } else if line.raw.hasPrefix("jmp") {
                let offset = line.words[1].integer!
                return .jmp(offset)
            } else if line.raw.hasPrefix("jie") {
                let pair = line.raw.dropFirst(4).components(separatedBy: ", ")
                let register = Register(rawValue: String(pair[0]))!
                let offset = Int(pair[1])!
                return .jie(register, offset)
            } else if line.raw.hasPrefix("jio") {
                let pair = line.raw.dropFirst(4).components(separatedBy: ", ")
                let register = Register(rawValue: String(pair[0]))!
                let offset = Int(pair[1])!
                return .jio(register, offset)
            } else {
                fatalError("Unknown instruction: \(line.raw)")
            }
        }
    }

    var registers: [Register: Int] = [.a: 0, .b: 0]
    var instructions: [Instruction]
    var pointer = 0

    var registerA: Int {
        registers[.a]!
    }

    var registerB: Int {
        registers[.b]!
    }

    init(instructions: [Instruction]) {
        self.instructions = instructions
    }

    mutating func run() {
        while pointer < instructions.count {
            guard pointer >= 0 else {
                fatalError("Pointer out of bounds")
            }

            let instruction = instructions[pointer]
            execute(instruction)
        }
    }

    private mutating func execute(_ instruction: Instruction) {
        switch instruction {
            case let .hlf(register):
                registers[register]! /= 2
                pointer += 1
            case let .tpl(register):
                registers[register]! *= 3
                pointer += 1
            case let .inc(register):
                registers[register]! += 1
                pointer += 1
            case let .jmp(offset):
                pointer += offset
            case let .jie(register, offset):
                if registers[register]!.isEven {
                    pointer += offset
                } else {
                    pointer += 1
                }
            case let .jio(register, offset):
                if registers[register]! == 1 {
                    pointer += offset
                } else {
                    pointer += 1
                }
        }
    }
}
