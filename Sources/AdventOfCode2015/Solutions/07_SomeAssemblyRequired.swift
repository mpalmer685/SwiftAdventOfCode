import AOCKit

struct SomeAssemblyRequired: Puzzle {
    static let day = 7

    func part1(input: AOCKit.Input) async throws -> Int {
        let instructions = parseInstructions(from: input)
        var signalCache = [String: Int]()
        return getInputSignal(to: "a", instructions: instructions, cache: &signalCache)
    }

    func part2(input: AOCKit.Input) async throws -> Int {
        let instructions = parseInstructions(from: input)
        var signalCache = [String: Int]()
        let signalA = getInputSignal(to: "a", instructions: instructions, cache: &signalCache)

        var modifiedInstructions = instructions
        modifiedInstructions["b"] = .signal(signalA)

        signalCache.removeAll()
        return getInputSignal(to: "a", instructions: modifiedInstructions, cache: &signalCache)
    }

    private func getInputSignal(
        to wire: String,
        instructions: [String: Input],
        cache: inout [String: Int],
    ) -> Int {
        func getInputSignal(to wire: String) -> Int {
            if let cachedValue = cache[wire] {
                return cachedValue
            }

            if let value = Int(wire) {
                cache[wire] = value
                return value
            }

            guard let input = instructions[wire] else {
                fatalError("No instruction for wire \(wire)")
            }

            let signal: Int = switch input {
                case let .signal(value):
                    value
                case let .wire(sourceWire):
                    getInputSignal(to: sourceWire)
                case let .gate(operation):
                    getInputSignal(to: operation)
            }

            cache[wire] = signal
            return signal
        }

        func getInputSignal(to operation: Operation) -> Int {
            switch operation {
                case let .and(leftWire, rightWire):
                    getInputSignal(to: leftWire) & getInputSignal(to: rightWire)
                case let .or(leftWire, rightWire):
                    getInputSignal(to: leftWire) | getInputSignal(to: rightWire)
                case let .leftShift(sourceWire, shiftAmount):
                    getInputSignal(to: sourceWire) << shiftAmount
                case let .rightShift(sourceWire, shiftAmount):
                    getInputSignal(to: sourceWire) >> shiftAmount
                case let .not(sourceWire):
                    ~getInputSignal(to: sourceWire) & 0xFFFF
            }
        }

        return getInputSignal(to: wire)
    }

    private func parseInstructions(from input: AOCKit.Input) -> [String: Input] {
        input.lines.reduce(into: [:]) { instructions, line in
            let parts = line.words(separatedBy: " -> ")
            let outputWire = parts[1].raw
            let expression = parts[0]
            if let signalValue = Int(expression.raw) {
                instructions[outputWire] = .signal(signalValue)
            } else if expression.raw.contains("AND") {
                let operands = expression.raw.components(separatedBy: " AND ")
                instructions[outputWire] = .gate(.and(operands[0], operands[1]))
            } else if expression.raw.contains("OR") {
                let operands = expression.raw.components(separatedBy: " OR ")
                instructions[outputWire] = .gate(.or(operands[0], operands[1]))
            } else if expression.raw.contains("LSHIFT") {
                let operands = expression.raw.components(separatedBy: " LSHIFT ")
                instructions[outputWire] = .gate(.leftShift(operands[0], Int(operands[1])!))
            } else if expression.raw.contains("RSHIFT") {
                let operands = expression.raw.components(separatedBy: " RSHIFT ")
                instructions[outputWire] = .gate(.rightShift(operands[0], Int(operands[1])!))
            } else if expression.raw.starts(with: "NOT ") {
                let operand = String(expression.raw.dropFirst(4))
                instructions[outputWire] = .gate(.not(operand))
            } else {
                instructions[outputWire] = .wire(expression.raw)
            }
        }
    }
}

private enum Input {
    case signal(Int)
    case wire(String)
    case gate(Operation)
}

private enum Operation {
    case and(String, String)
    case or(String, String)
    case leftShift(String, Int)
    case rightShift(String, Int)
    case not(String)
}
