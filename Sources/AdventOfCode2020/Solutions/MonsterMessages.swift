import AOCKit

struct MonsterMessages: Puzzle {
    static let day = 19

    func part1(input: Input) throws -> Int {
        let (rules, messages) = parse(input)
        return messages.count { isMessageValid($0, for: [0], given: rules) }
    }

    func part2(input: Input) throws -> Int {
        let (rules, messages) = parse(input, overrides: ["8: 42 | 42 8", "11: 42 31 | 42 11 31"])
        return messages.count { isMessageValid($0, for: [0], given: rules) }
    }

    private func parse(_ input: Input, overrides: [String] = []) -> ([Int: Rule], [String]) {
        let lines = input.lines.raw
        let splitIndex = lines.firstIndex(where: \.isEmpty)!

        let ruleLines = lines[...(splitIndex - 1)] + overrides
        let rules: [Int: Rule] = ruleLines.reduce(into: [:]) { result, line in
            let pair = line.components(separatedBy: ": ")
            let id = Int(pair[0])!
            let rule = Rule(pair[1])
            result[id] = rule
        }

        let messages = Array(lines[(splitIndex + 1)...])
        return (rules, messages)
    }

    private func isMessageValid(
        _ message: some StringProtocol,
        for ruleIds: some Collection<Int>,
        given rules: [Int: Rule]
    ) -> Bool {
        guard let ruleId = ruleIds.first, !message.isEmpty else {
            return message.isEmpty.exclusiveOr(!ruleIds.isEmpty)
        }
        guard let rule = rules[ruleId] else { fatalError() }

        switch rule {
            case let .literal(c):
                return message.first == c && isMessageValid(
                    message.tail,
                    for: ruleIds.tail,
                    given: rules
                )
            case let .sequence(r):
                return isMessageValid(message, for: r + ruleIds.tail, given: rules)
            case let .fork(r):
                return r.contains { isMessageValid(message, for: $0 + ruleIds.tail, given: rules) }
        }
    }
}

private indirect enum Rule: CustomDebugStringConvertible {
    case literal(Character)
    case sequence([Int])
    case fork([[Int]])

    init(_ s: String) {
        if s.contains("\"") {
            self = .literal(s[1])
        } else if s.contains("|") {
            let rules = s
                .components(separatedBy: " | ")
                .map { $0.components(separatedBy: .whitespaces).compactMap(Int.init) }
            self = .fork(rules)
        } else {
            let rules = s
                .components(separatedBy: .whitespaces)
                .compactMap(Int.init)
            self = .sequence(rules)
        }
    }

    var debugDescription: String {
        switch self {
            case let .literal(c): "\"\(c)\""
            case let .sequence(rules): rules.map(String.init).joined(separator: " ")
            case let .fork(rules):
                rules
                    .map {
                        $0.map(String.init).joined(separator: " ")
                    }.joined(separator: " | ")
        }
    }
}
