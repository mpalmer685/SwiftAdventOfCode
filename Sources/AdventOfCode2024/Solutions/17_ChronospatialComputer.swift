import AOCKit

struct ChronospatialComputer: Puzzle {
    static let day = 17

    func part1(input: Input) throws -> String {
        var computer = Computer.parse(from: input)
        computer.run()
        return computer.output
    }

    func part2(input: Input) throws -> Int {
        let base = Computer.parse(from: input)
        let target = base.program.map(String.init).joined(separator: ",")

        var frontier = Stack<Int>()
        frontier.push(contentsOf: 0 ... 7)

        var explored = Set<Int>()
        explored.formUnion(0 ... 7)

        while let current = frontier.pop() {
            var computer = base.cloned(registerA: current)
            computer.run()
            let output = computer.output

            if output == target {
                return current
            }

            if target.hasSuffix(output) {
                for digit in (0 ... 7).reversed() {
                    let next = (current << 3) + digit
                    if !explored.contains(next) {
                        frontier.push(next)
                        explored.insert(next)
                    }
                }
            }
        }

        fatalError("No solution found")
    }
}

private struct Computer {
    private var registerA: Int
    private var registerB: Int
    private var registerC: Int

    private var outputBuffer: [Int] = []

    private var instructionPointer = 0

    let program: [Int]

    var output: String {
        outputBuffer.map(String.init).joined(separator: ",")
    }

    private init(registerA: Int, registerB: Int, registerC: Int, program: [Int]) {
        self.registerA = registerA
        self.registerB = registerB
        self.registerC = registerC
        self.program = program
    }

    static func parse(from input: Input) -> Self {
        let lines = input.lines
        let registerA = lines[0].integers[0]
        let registerB = lines[1].integers[0]
        let registerC = lines[2].integers[0]
        let program = lines[4].integers
        return Self(
            registerA: registerA,
            registerB: registerB,
            registerC: registerC,
            program: program
        )
    }

    func cloned(registerA: Int) -> Self {
        Self(registerA: registerA, registerB: registerB, registerC: registerC, program: program)
    }

    mutating func run() {
        while instructionPointer < program.count {
            executeCurrentInstruction()
        }
    }

    mutating func executeCurrentInstruction() {
        let instruction = Instruction(
            opCode: OpCode(rawValue: program[instructionPointer])!,
            operand: program[instructionPointer + 1]
        )

        switch instruction.opCode {
            case .adv:
                let numerator = Double(registerA)
                let denominator = pow(2, Double(combo(instruction.operand)))
                registerA = Int(numerator / denominator)
            case .bxl:
                registerB ^= instruction.operand
            case .bst:
                registerB = combo(instruction.operand).modulo(8)
            case .jnz:
                // do nothing, just jump later
                _ = 0
            case .bxc:
                registerB ^= registerC
            case .out:
                outputBuffer.append(combo(instruction.operand).modulo(8))
            case .bdv:
                let numerator = Double(registerA)
                let denominator = pow(2, Double(combo(instruction.operand)))
                registerB = Int(numerator / denominator)
            case .cdv:
                let numerator = Double(registerA)
                let denominator = pow(2, Double(combo(instruction.operand)))
                registerC = Int(numerator / denominator)
        }

        moveInstructionPointer(for: instruction)
    }

    mutating func moveInstructionPointer(for instruction: Instruction) {
        switch instruction.opCode {
            case .jnz:
                if registerA == 0 {
                    instructionPointer += 2
                } else {
                    instructionPointer = instruction.operand
                }
            default:
                instructionPointer += 2
        }
    }

    private func combo(_ operand: Int) -> Int {
        switch operand {
            case 0 ... 3: operand
            case 4: registerA
            case 5: registerB
            case 6: registerC
            default: fatalError("Invalid combo operand: \(operand)")
        }
    }

    struct Instruction {
        let opCode: OpCode
        let operand: Int
    }

    enum OpCode: Int {
        case adv = 0
        case bxl = 1
        case bst = 2
        case jnz = 3
        case bxc = 4
        case out = 5
        case bdv = 6
        case cdv = 7
    }
}

private extension Int {
    func modulo(_ other: Self) -> Self {
        (self % other + other) % other
    }
}

extension ChronospatialComputer: TestablePuzzle {
    var testCases: [TestCase<String, Int>] {
        [
            .init(input: .example(1), part1: "4,6,3,5,6,3,5,2,1,0"),
            .init(input: .example(2), part2: 117_440),
        ]
    }
}
