import AOCKit

struct CathodeRayTube: Puzzle {
    static let day = 10

    func part1(input: Input) throws -> Int {
        let circuit = ClockCircuit(input: input)
        let cyclesToObserve = [20, 60, 100, 140, 180, 220]

        var observedCycles: [Int: Int] = [:]

        circuit.run { cycle, x in
            if cyclesToObserve.contains(cycle) {
                observedCycles[cycle] = x
            }
        }

        return observedCycles
            .map { $0.key * $0.value }
            .sum
    }

    func part2(input: Input) throws -> String {
        let circuit = ClockCircuit(input: input)
        var output: [[Character]] = Array(repeating: Array(repeating: ".", count: 40), count: 6)

        circuit.run { cycle, x in
            let (row, col) = (cycle - 1).quotientAndRemainder(dividingBy: 40)
            if (x - 1 ... x + 1).contains(col) {
                output[row][col] = "#"
            }
        }

        return output.map { String($0) }.joined(separator: "\n")
    }
}

private class ClockCircuit {
    private let instructions: [Instruction]

    private var x = 1
    private var cycle = 0

    init(input: Input) {
        instructions = input.lines.map { line in
            if line.raw == "noop" {
                return .noop
            }
            let value = line.words[1].integer!
            return .addx(value)
        }
    }

    func run(onCycle: (Int, Int) -> Void) {
        for instruction in instructions {
            for _ in 0 ..< instruction.cycleCount {
                cycle += 1
                onCycle(cycle, x)
            }

            if case let .addx(amount) = instruction {
                x += amount
            }
        }
    }
}

private enum Instruction {
    case addx(Int)
    case noop

    var cycleCount: Int {
        switch self {
            case .noop: 1
            case .addx: 2
        }
    }
}
