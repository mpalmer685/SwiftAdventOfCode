import AOCKit

class MonkeyMath: Puzzle {
    static let day = 21

    private lazy var monkeys: [String: Monkey] = {
        input().lines.reduce(into: [:]) { monkeys, line in
            let (name, monkey) = Monkey.from(line: line)
            monkeys[name] = monkey
        }
    }()

    func part1() throws -> Int {
        let root = monkeys["root"]!
        return Int(root.yell(using: monkeys))
    }

    func part2() throws -> Int {
        var monkeys = monkeys
        var root = monkeys["root"]!
        if case let .op(l, r, _) = root {
            root = .op(l, r, -)
        }

        var range = 0 ... Int.max - 1
        while range.count > 1 {
            let midpoint = range.lowerBound + range.count / 2
            monkeys["humn"] = .int(Double(midpoint))
            let result = root.yell(using: monkeys)
            switch result {
                case _ where result > 0:
                    // answer was too low
                    range = midpoint ... range.upperBound
                case _ where result < 0:
                    // answer was too high
                    range = range.lowerBound ... midpoint
                default:
                    // midpoint was the answer
                    range = midpoint ... midpoint
            }
        }

        return range.lowerBound
    }
}

private enum Monkey {
    // These should be Ints, but apparently the monkeys perform
    // floating-point arithmetic before returning an integer answer.
    typealias Operation = (Double, Double) -> Double

    case int(Double)
    case op(String, String, Operation)

    func yell(using monkeys: [String: Monkey]) -> Double {
        switch self {
            case let .int(value):
                return value
            case let .op(a, b, op):
                let lhs = monkeys[a]!.yell(using: monkeys)
                let rhs = monkeys[b]!.yell(using: monkeys)
                return op(lhs, rhs)
        }
    }

    static func from(line: Line) -> (String, Self) {
        let parts = line.words(separatedBy: ": ")
        let name = parts[0].raw
        if let value = parts.integers.first {
            return (name, .int(Double(value)))
        }

        let symbols = parts[1].words(separatedBy: .whitespaces).raw
        let lhs = symbols[0]
        let rhs = symbols[2]
        switch symbols[1] {
            case "+": return (name, .op(lhs, rhs, +))
            case "-": return (name, .op(lhs, rhs, -))
            case "*": return (name, .op(lhs, rhs, *))
            case "/": return (name, .op(lhs, rhs, /))
            default: fatalError()
        }
    }
}
