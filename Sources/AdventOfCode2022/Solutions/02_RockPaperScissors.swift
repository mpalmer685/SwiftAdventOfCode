import AOCKit

struct RockPaperScissors: Puzzle {
    static let day = 2

    func part1(input: Input) throws -> Int {
        input.lines.map { line in
            let moves = line.words.raw.map(Shape.fromInput)
            guard moves.count == 2 else { fatalError() }

            let theirs = moves[0]
            let mine = moves[1]
            let outcome = mine.result(against: theirs)
            return mine.score + outcome.score
        }.sum
    }

    func part2(input: Input) throws -> Int {
        input.lines.map { line in
            let parts = line.words.raw
            guard parts.count == 2 else { fatalError() }

            let theirs = Shape.fromInput(parts[0])
            let outcome = Outcome.fromInput(parts[1])
            let mine = theirs.match(for: outcome)
            return mine.score + outcome.score
        }.sum
    }
}

private enum Shape {
    case rock, paper, scissors

    var score: Int {
        switch self {
            case .rock:
                return 1
            case .paper:
                return 2
            case .scissors:
                return 3
        }
    }

    func result(against other: Shape) -> Outcome {
        if self == other {
            return .draw
        }

        if Self.wins[self] == other {
            return .win
        }

        return .lose
    }

    func match(for outcome: Outcome) -> Shape {
        switch outcome {
            case .draw:
                return self
            case .lose:
                return Self.wins[self]!
            case .win:
                return Self.wins.first { $0.value == self }!.key
        }
    }

    private static let wins: [Shape: Shape] = [
        .rock: .scissors,
        .scissors: .paper,
        .paper: .rock,
    ]

    static func fromInput(_ input: String) -> Shape {
        switch input {
            case "A", "X":
                return .rock
            case "B", "Y":
                return .paper
            case "C", "Z":
                return .scissors
            default:
                fatalError("Invalid input: \(input)")
        }
    }
}

private enum Outcome {
    case win, lose, draw

    var score: Int {
        switch self {
            case .win:
                return 6
            case .lose:
                return 0
            case .draw:
                return 3
        }
    }

    static func fromInput(_ input: String) -> Outcome {
        switch input {
            case "X":
                return .lose
            case "Y":
                return .draw
            case "Z":
                return .win
            default:
                fatalError("Invalid input: \(input)")
        }
    }
}
