import AOCKit

struct CrossedWires: Puzzle {
    static let day = 24

    func part1(input: Input) throws -> Int {
        let (inputs, gates) = parse(input)
        var computed = inputs

        func compute(_ id: String) -> Bool {
            if let value = computed[id] { return value }
            let gate = gates[id]!
            let inputs = gate.inputs.map(compute)
            let value = gate(inputs[0], inputs[1])
            computed[id] = value
            return value
        }

        let bits = gates.keys
            .filter { $0.hasPrefix("z") }
            .map { id in (id: id, value: compute(id)) }
            .sorted(using: \.id)
            .reversed()
            .map(\.value)

        return Int(bits: bits)
    }

    func part2(input: Input) throws -> String {
        let (inputs, gates) = parse(input)

        let inputBitCount = inputs.count / 2
        let allGates = Set(gates.values)
        var misplaced = Set<Gate>()

        /*
                   HA1        HA2
                  ╔═══╗      ╔═══╗
          A─────┬─╢ X ║  ┌───╢ X ║
                │ ║ O ╟──┤   ║ O ╟──────────S
          B────┬──╢ R ║  │┌──╢ R ║
               ││ ╚═══╝  ││  ╚═══╝
               ││ ╔═══╗  ││  ╔═══╗
               │└─╢ A ║  └───╢ A ║   ╔═══╗
               │  ║ N ╟─┐ │  ║ N ╟───╢ O ║
               └──╢ D ║ │ ├──╢ D ║   ║   ╟──Cout
                  ╚═══╝ │ │  ╚═══╝ ┌─╢ R ║
                        └──────────┘ ╚═══╝
          Cin─────────────┘
         */

        let ha1XORs = allGates.filter { $0.isInput && $0.operation == .xor }
        // No XOR gates in the first half-adder should lead to a sum output
        // except for the least significant bit.
        misplaced.formUnion(ha1XORs.filter { gate in
            gate.isFirst ? gate.output != "z00" : gate.isOutput
        })

        let ha2XORs = allGates.filter { $0.operation == .xor && !$0.isInput }
        // XOR gates in the second half-adder should lead to a sum output.
        misplaced.formUnion(ha2XORs.filter { !$0.isOutput })

        let outputGates = allGates.filter(\.isOutput)
        // All gates that lead to an output bit should be XOR gates, except
        // for the most significant bit which should be an OR gate.
        misplaced.formUnion(outputGates.filter { gate in
            let isLast = gate.output == "z\(inputBitCount)"
            return isLast ? gate.operation != .or : gate.operation != .xor
        })

        var checkNext = Set<Gate>()

        // All XOR gates in the first half-adder should be used as inputs
        // in a second half-adder.
        for gate in ha1XORs {
            guard !misplaced.contains(gate), gate.output != "z00" else { continue }
            if ha2XORs.contains(where: { $0.hasInput(gate.output) }) { continue }

            checkNext.insert(gate)
            misplaced.insert(gate)
        }

        for gate in checkNext {
            let a = gate.inputs[0]

            // An XOR gate in a first half-adder should take inputs An and Bn,
            // and lead to an XOR gate that outputs Zn.
            let intendedResult = "z\(a.dropFirst())"
            let matches = ha2XORs.filter { $0.output == intendedResult }

            guard matches.count == 1 else {
                fatalError("Critical error! Check your input?")
            }

            let match = matches.first!

            let orMatches = allGates.filter {
                $0.operation == .or && match.inputs.contains($0.output)
            }

            guard orMatches.count == 1 else {
                fatalError("Critical error! This solver is not able to solve this input.")
            }

            let orMatchOutput = orMatches.first!.output

            let correctOutput = match.inputs.first { $0 != orMatchOutput }!
            let correctGate = allGates.first { $0.output == correctOutput }!
            misplaced.insert(correctGate)
        }

        guard misplaced.count == 8 else {
            fatalError("Critical error! This solver is not able to solve this input.")
        }

        return misplaced.map(\.output).sorted().joined(separator: ",")
    }

    private func parse(_ input: Input) -> (inputs: [String: Bool], gates: [String: Gate]) {
        let sections = input.lines.split(whereSeparator: \.isEmpty)
        assert(sections.count == 2)

        let inputs = sections[0].reduce(into: [String: Bool]()) { values, line in
            guard let (_, id, value) = try? /^(.*): (0|1)$/.wholeMatch(in: line.raw)?.output
            else { fatalError("Bad input \(line.raw)") }
            values[String(id)] = value == "1"
        }

        let gates = sections[1].reduce(into: [String: Gate]()) { gates, line in
            guard let (_, left, op, right, output) = try? /^(.*) (AND|OR|XOR) (.*) -> (.*)$/
                .wholeMatch(in: line.raw)?.output
            else { fatalError("Bad input \(line.raw)") }

            let outputId = String(output)
            gates[outputId] = Gate(
                inputs: [String(left), String(right)],
                output: outputId,
                operation: Gate.Operation(rawValue: String(op))!,
            )
        }

        return (inputs, gates)
    }
}

@dynamicCallable
private struct Gate: Hashable {
    let inputs: [String]
    let output: String
    let operation: Operation

    func dynamicallyCall(withArguments args: [Bool]) -> Bool {
        switch operation {
            case .and: args[0] && args[1]
            case .or: args[0] || args[1]
            case .xor: args[0] != args[1]
        }
    }

    var isOutput: Bool { output.hasPrefix("z") }

    var isInput: Bool {
        inputs.contains { $0.hasPrefix("x") }
    }

    var isFirst: Bool {
        inputs.allSatisfy { $0.hasSuffix("00") }
    }

    func hasInput(_ id: String) -> Bool {
        inputs.contains(id)
    }

    enum Operation: String {
        case and = "AND", or = "OR", xor = "XOR"
    }
}

extension CrossedWires: TestablePuzzle {
    var testCases: [TestCase<Int, String>] {
        [
            .init(input: .example("small"), part1: 4),
            .init(input: .example("large"), part1: 2024),
        ]
    }
}
