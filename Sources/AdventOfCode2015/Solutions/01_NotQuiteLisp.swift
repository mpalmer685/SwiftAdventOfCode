import AOCKit

struct NotQuiteLisp: Puzzle {
    static let day = 1

    func part1(input: Input) async throws -> Int {
        input.characters
            .compactMap(Direction.init)
            .sum(of: \.intValue)
    }

    func part2(input: Input) async throws -> Int {
        let directions = input.characters.map { char in
            guard let direction = Direction(rawValue: char) else {
                fatalError("Invalid character in input: \(char)")
            }
            return direction.intValue
        }

        var floor = 0
        for (index, change) in directions.enumerated() {
            floor += change
            if floor == -1 {
                return index + 1 // +1 for 1-based index
            }
        }

        fatalError("Basement not reached in input")
    }
}

private enum Direction: Character {
    case up = "("
    case down = ")"

    var intValue: Int {
        switch self {
            case .up: 1
            case .down: -1
        }
    }
}

extension NotQuiteLisp: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.raw("(())")).expects(part1: 0),
            .given(.raw("()()")).expects(part1: 0),
            .given(.raw("(((")).expects(part1: 3),
            .given(.raw("(()(()(")).expects(part1: 3),
            .given(.raw("))(((((")).expects(part1: 3),
            .given(.raw("())")).expects(part1: -1),
            .given(.raw("))(")).expects(part1: -1),
            .given(.raw(")))")).expects(part1: -3),
            .given(.raw(")())())")).expects(part1: -3),

            .given(.raw(")")).expects(part2: 1),
            .given(.raw("()())")).expects(part2: 5),
        ]
    }
}
