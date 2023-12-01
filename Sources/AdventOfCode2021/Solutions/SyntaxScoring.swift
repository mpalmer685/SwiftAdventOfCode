import AOCKit

struct SyntaxScoring: Puzzle {
    static let day = 10

    func part1(input: Input) throws -> Int {
        let characterScores: [Character: Int] = [
            ")": 3,
            "]": 57,
            "}": 1197,
            ">": 25137,
        ]

        return input.lines
            .map { process(line: $0) }
            .reduce(0) { total, state in
                guard case let .corrupted(c) = state else { return total }
                guard let score = characterScores[c] else {
                    fatalError("Unrecognized character: \(c)")
                }
                return total + score
            }
    }

    func part2(input: Input) throws -> Int {
        let characterScores: [Character: Int] = [
            ")": 1,
            "]": 2,
            "}": 3,
            ">": 4,
        ]

        func incompleteScore(for characters: Stack<Character>) -> Int {
            var characters = characters
            var totalScore = 0
            while !characters.isEmpty, let c = characters.pop() {
                guard let score = characterScores[c.closingCharacter] else {
                    fatalError()
                }
                totalScore = 5 * totalScore + score
            }
            return totalScore
        }

        let scores: [Int] = input.lines
            .map { process(line: $0) }
            .reduce(into: []) { scores, state in
                guard case let .incomplete(remaining) = state else { return }
                scores.append(incompleteScore(for: remaining))
            }
        return median(of: scores)
    }
}

private func process(line: Line) -> LineState {
    var stack = Stack<Character>()
    for c in line.characters {
        if c.isOpeningCharacter {
            stack.push(c)
        } else if stack.peek()?.closingCharacter == c {
            _ = stack.pop()
        } else {
            return .corrupted(invalid: c)
        }
    }
    return .incomplete(remaining: stack)
}

private enum LineState {
    case corrupted(invalid: Character)
    case incomplete(remaining: Stack<Character>)
}

private extension Character {
    var isOpeningCharacter: Bool {
        ["(", "[", "{", "<"].contains(self)
    }

    var closingCharacter: Self {
        switch self {
            case "(": return ")"
            case "[": return "]"
            case "{": return "}"
            case "<": return ">"
            default: fatalError("Unrecognized character: \(self)")
        }
    }
}
