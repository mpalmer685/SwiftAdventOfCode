import AOCKit

struct SecretEntrance: Puzzle {
    static let day = 1

    func part1(input: Input) async throws -> Int {
        let rotations = instructions(from: input)
        let steps = rotations.reductions(50) { current, rotation in
            (current + rotation).modulo(100)
        }

        return steps.count(of: 0)
    }

    func part2(input: Input) async throws -> Int {
        let instructions = instructions(from: input)
        let stops = instructions.reduce((crossings: 0, position: 50)) { current, instruction in
            var crossings = current.crossings + instruction.steps / 100
            let nextPosition = (current.position + instruction).modulo(100)

            if current.position != 0 {
                if nextPosition == 0 {
                    crossings += 1
                } else if case .left = instruction, nextPosition > current.position {
                    crossings += 1
                } else if case .right = instruction, nextPosition < current.position {
                    crossings += 1
                }
            }

            return (crossings, nextPosition)
        }

        return stops.crossings
    }

    private func instructions(from input: Input) -> [Instruction] {
        let pattern = /^(L|R)(\d+)$/

        return input.lines.compactMap { line -> Instruction? in
            guard let match = line.raw.firstMatch(of: pattern) else { return nil }
            let distance = Int(match.2)!
            return match.1 == "L" ? .left(distance) : .right(distance)
        }
    }
}

private enum Instruction {
    case left(Int)
    case right(Int)

    var steps: Int {
        switch self {
            case let .left(steps), let .right(steps):
                steps
        }
    }

    var rotation: Int {
        switch self {
            case .left: -1
            case .right: 1
        }
    }

    static func + (lhs: Int, rhs: Instruction) -> Int {
        lhs + rhs.steps * rhs.rotation
    }
}

extension SecretEntrance: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .init(input: .example, part1: 3, part2: 6),
            .init(input: .raw("""
            R50
            R50
            L50
            L50
            R75
            L50
            L25
            L75
            R50
            """), part2: 6),

            // Simple cases to verify wrapping logic
            .init(input: .raw("L50\nR50\n"), part2: 1),
            .init(input: .raw("L50\nL50\n"), part2: 1),
            .init(input: .raw("R50\nL50\n"), part2: 1),
            .init(input: .raw("R50\nR50\n"), part2: 1),
            .init(input: .raw("L150\nL50\n"), part2: 2),
            .init(input: .raw("L150\nR50\n"), part2: 2),
            .init(input: .raw("R150\nL50\n"), part2: 2),
            .init(input: .raw("R150\nR50\n"), part2: 2),
            .init(input: .raw("R50\nL101\n"), part2: 2),
        ]
    }
}
