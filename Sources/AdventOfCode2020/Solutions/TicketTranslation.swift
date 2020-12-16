import AOCKit

struct TicketTranslation: Puzzle {
    func part1Solution(for input: String) throws -> Int {
        let (rules, _, otherTickets) = parse(input)
        return otherTickets
            .flatMap { invalidFields(in: $0, using: rules) }
            .reduce(0, +)
    }

    func part2Solution(for input: String) throws -> Int {
        let (rules, myTicket, otherTickets) = parse(input)
        let validTickets = otherTickets.filter { invalidFields(in: $0, using: rules).isEmpty }
        let fieldIndices = getFieldMapping(for: rules, using: validTickets)

        guard fieldIndices.count == myTicket.count else {
            fatalError()
        }

        return fieldIndices.keys
            .filter { $0.starts(with: "departure") }
            .map { fieldIndices[$0]! }
            .map { myTicket[$0] }
            .reduce(1, *)
    }

    private func invalidFields(in ticket: Ticket, using rules: [Rule]) -> [Int] {
        ticket.filter { value in !rules.contains { $0.isValid(for: value) } }
    }

    private func getFieldMapping(for rules: [Rule], using tickets: [Ticket]) -> [String: Int] {
        var rulesByField = [Int: [String]]()
        for i in 0 ..< tickets.first!.count {
            let values = tickets.map { $0[i] }
            let validRules = rules
                .filter { rule in values.allSatisfy { rule.isValid(for: $0) } }
                .map(\.name)
            rulesByField[i] = validRules
        }

        var fieldIndices = [String: Int]()
        while !rulesByField.isEmpty {
            let (index, rules) = rulesByField.first { $0.value.count == 1 }!
            let rule = rules.first!

            fieldIndices[rule] = index
            remove(rule, in: &rulesByField)
        }

        return fieldIndices
    }

    private func remove<Key, Value: Equatable>(_ item: Value, in dict: inout [Key: [Value]]) {
        for (key, value) in dict {
            if value.count == 1 && value.first! == item {
                dict[key] = nil
            } else {
                dict[key] = value.removing(item)
            }
        }
    }

    private func parse(_ input: String) -> ([Rule], Ticket, [Ticket]) {
        let lines = getLines(from: input)
        let yourTicketLabelIndex = lines.firstIndex(of: "your ticket:")!
        let nearbyTicketsLabelIndex = lines.firstIndex(of: "nearby tickets:")!

        let rules = lines[0 ..< yourTicketLabelIndex].map(Rule.init)
        let myTicket = split(lines[yourTicketLabelIndex + 1], on: ",").compactMap(Int.init)
        let otherTickets = lines[(nearbyTicketsLabelIndex + 1)...]
            .map { split($0, on: ",").compactMap(Int.init) }

        return (rules, myTicket, otherTickets)
    }
}

private typealias Ticket = [Int]

private struct Rule {
    var name: String
    var ranges: [ClosedRange<Int>]

    init(_ line: String) {
        let parts = line.components(separatedBy: ": ")
        name = parts.first!
        ranges = parts.last!
            .components(separatedBy: " or ")
            .map { range in
                let pair = range.components(separatedBy: "-").compactMap(Int.init)
                return pair.first! ... pair.last!
            }
    }

    func isValid(for value: Int) -> Bool {
        ranges.contains { $0.contains(value) }
    }
}

extension Rule: Equatable {}

extension Rule: CustomDebugStringConvertible {
    var debugDescription: String {
        let ranges = self.ranges.map { "\($0.lowerBound)-\($0.upperBound)" }.joined(separator: " or ")
        return "\(name): \(ranges)"
    }
}
