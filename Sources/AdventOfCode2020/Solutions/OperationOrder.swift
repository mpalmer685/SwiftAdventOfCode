import AOCKit

struct OperationOrder: Puzzle {
    func part1Solution(for input: String) throws -> Int {
        try getLines(from: input)
            .map { try evaluate(string: $0, using: .part1) }
            .reduce(0, +)
    }

    func part2Solution(for input: String) throws -> Int {
        try getLines(from: input)
            .map { try evaluate(string: $0, using: .part2) }
            .reduce(0, +)
    }

    private func evaluate(string: String, using operatorSet: Operator.OperatorSet) throws -> Int {
        let tokens = try tokenize(string, using: operatorSet)
        var stack = convertToPostfix(tokens)

        var operands = [Int]()
        while let token = stack.popLast() {
            switch token {
                case let .operand(value):
                    operands.append(value)
                case let .operator(op):
                    let rightOperand = operands.popLast()!
                    let leftOperand = operands.popLast()!
                    operands.append(op.operate(leftOperand, rightOperand))
            }
        }

        return operands.last!
    }

    private func tokenize(_ string: String, using operatorSet: Operator.OperatorSet) throws -> [Token] {
        var tokens = [Token]()
        for ch in Array(string) where !ch.isWhitespace {
            if let value = ch.wholeNumberValue {
                tokens.append(.operand(value: value))
            } else {
                tokens.append(.operator(try operatorSet.parse(from: ch)))
            }
        }
        return tokens
    }

    private func convertToPostfix(_ tokens: [Token]) -> [Token] {
        var outputStack = [Token]()
        var operatorStack = [Operator]()

        for token in tokens {
            switch token {
                case .operand:
                    outputStack.append(token)
                case let .operator(o):
                    moveOperatorsWithPrecedenceHigherThan(o, from: &operatorStack, to: &outputStack)
                    if o.precedence != .closeGroup {
                        operatorStack.append(o)
                    }
            }
        }

        while let op = operatorStack.popLast() {
            outputStack.append(.operator(op))
        }

        return outputStack.reversed()
    }

    private func moveOperatorsWithPrecedenceHigherThan(
        _ op: Operator,
        from operatorStack: inout [Operator],
        to outputStack: inout [Token]
    ) {
        func shouldMoveToOutput(current: Operator, topOfStack: Operator?) -> Bool {
            guard let topOfStack = topOfStack else { return false }
            let isLowerPrecedence = current.precedence < topOfStack.precedence ||
                (current.precedence == topOfStack.precedence && current.associativity == .left)

            return current.precedence == .closeGroup ||
                (isLowerPrecedence && topOfStack.precedence < .openGroup)
        }

        while shouldMoveToOutput(current: op, topOfStack: operatorStack.last) {
            let topOfStack = operatorStack.popLast()!
            if topOfStack.precedence < .closeGroup {
                outputStack.append(.operator(topOfStack))
            }
            if op.precedence == .closeGroup && topOfStack.precedence == .openGroup {
                break
            }
        }
    }
}

private enum Token {
    case `operator`(_ operator: Operator)
    case operand(value: Int)
}

private typealias Operation = (Int, Int) -> Int
private let noOp: Operation = { _, _ in fatalError() }

private struct Operator {
    let symbol: Character
    let precedence: Precedence
    let associativity: Associativity
    let operate: Operation

    static func openGroup(symbol: Character) -> Self {
        Operator(symbol: symbol, precedence: .openGroup, associativity: .right, operate: noOp)
    }

    static func closeGroup(symbol: Character) -> Self {
        Operator(symbol: symbol, precedence: .closeGroup, associativity: .left, operate: noOp)
    }

    static func arithmetic(symbol: Character, precedence: Precedence, operation: @escaping Operation) -> Self {
        Operator(symbol: symbol, precedence: precedence, associativity: .left, operate: operation)
    }

    enum Associativity {
        case left, right
    }

    enum Precedence: Int, Equatable, Comparable {
        case multiplication = 1
        case addition = 2
        case openGroup = 100
        case closeGroup = 99

        static func < (lhs: Precedence, rhs: Precedence) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    struct OperatorSet: ExpressibleByArrayLiteral {
        private let operators: [Operator]

        static let part1: OperatorSet = [
            .openGroup(symbol: "("),
            .closeGroup(symbol: ")"),
            .arithmetic(symbol: "+", precedence: .addition, operation: +),
            .arithmetic(symbol: "*", precedence: .addition, operation: *),
        ]

        static let part2: OperatorSet = [
            .openGroup(symbol: "("),
            .closeGroup(symbol: ")"),
            .arithmetic(symbol: "+", precedence: .addition, operation: +),
            .arithmetic(symbol: "*", precedence: .multiplication, operation: *),
        ]

        init(arrayLiteral elements: Operator...) {
            operators = elements
        }

        func parse(from symbol: Character) throws -> Operator {
            guard let o = operators.first(where: { $0.symbol == symbol }) else {
                throw OperationOrderError.invalidSymbol(symbol: symbol)
            }
            return o
        }
    }
}

private enum OperationOrderError: Error {
    case invalidSymbol(symbol: Character)
}
