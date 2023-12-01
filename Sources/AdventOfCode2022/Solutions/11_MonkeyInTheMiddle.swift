import AOCKit

class MonkeyInTheMiddle: Puzzle {
    static let day = 11

    func part1(input: Input) throws -> Int {
        var monkeys = monkeys(from: input)
        var monkeyCounts = Array(repeating: 0, count: monkeys.count)

        for _ in 0 ..< 20 {
            for i in monkeys.indices {
                monkeyCounts[i] += monkeys[i].items.count

                for item in monkeys[i].items {
                    var worryLevel = monkeys[i].operation(item)
                    worryLevel /= 3
                    let dest = worryLevel.isMultiple(of: monkeys[i].divisibleByTest)
                        ? monkeys[i].trueDest
                        : monkeys[i].falseDest
                    monkeys[dest].items.append(worryLevel)
                }

                monkeys[i].items.removeAll()
            }
        }

        return monkeyCounts.max(count: 2).product
    }

    func part2(input: Input) throws -> Int {
        var monkeys = monkeys(from: input)
        var monkeyCounts = Array(repeating: 0, count: monkeys.count)

        let divisor = monkeys.map(\.divisibleByTest).product

        for _ in 0 ..< 10000 {
            for i in monkeys.indices {
                monkeyCounts[i] += monkeys[i].items.count

                for item in monkeys[i].items {
                    let worryLevel = monkeys[i].operation(item) % divisor
                    let dest = worryLevel.isMultiple(of: monkeys[i].divisibleByTest)
                        ? monkeys[i].trueDest
                        : monkeys[i].falseDest
                    monkeys[dest].items.append(worryLevel)
                }

                monkeys[i].items.removeAll()
            }
        }

        return monkeyCounts.max(count: 2).product
    }

    private func monkeys(from input: Input) -> [Monkey] {
        input.lines.split(whereSeparator: \.isEmpty).map { slice -> Monkey in
            let lines = Array(slice)
            let operand = lines[2].integers.first
            let op = lines[2].raw.first(where: \.isOperator)!

            return Monkey(
                id: lines[0].integers[0],
                items: lines[1].integers,
                operation: { old in
                    let operand = operand ?? old
                    switch op {
                        case "+": return old + operand
                        case "-": return old - operand
                        case "*": return old * operand
                        case "/": return old / operand
                        default: fatalError()
                    }
                },
                divisibleByTest: lines[3].integers[0],
                trueDest: lines[4].integers[0],
                falseDest: lines[5].integers[0]
            )
        }
    }
}

private struct Monkey {
    let id: Int

    var items: [Int]
    var operation: (Int) -> Int
    var divisibleByTest: Int
    var trueDest: Int
    var falseDest: Int
}

private extension Character {
    var isOperator: Bool {
        ["+", "-", "*", "/"].contains(self)
    }
}
