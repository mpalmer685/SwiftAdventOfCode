import AOCKit

private let testInput = """
NNCB

CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C
"""

struct ExtendedPolymerization: Puzzle {
    func part1Solution(for input: String) throws -> Int {
        var (polymer, rules) = parse(input)
        run(reactions: 10, on: &polymer, using: rules)
        let (_, mostCommon) = polymer.mostCommonElement
        let (_, leastCommon) = polymer.leastCommonElement
        return mostCommon - leastCommon
    }

    func part2Solution(for input: String) throws -> Int {
        var (polymer, rules) = parse(input)
        run(reactions: 40, on: &polymer, using: rules)
        let (_, mostCommon) = polymer.mostCommonElement
        let (_, leastCommon) = polymer.leastCommonElement
        return mostCommon - leastCommon
    }

    private func parse(_ input: String) -> (Polymer, RuleCollection) {
        let parts = getLines(from: input, omittingEmptyLines: false)
            .split(whereSeparator: \.isEmpty)
        let rules = parseRules(from: Array(parts[1]))
        return (Polymer(parts[0][0]), rules)
    }
}

private func parseRules(from lines: [String]) -> RuleCollection {
    lines.reduce(into: [:]) { rules, line in
        let parts = line.components(separatedBy: " -> ")
        rules[parts[0]] = Character(parts[1])
    }
}

private func run(
    reactions: Int,
    on polymer: inout Polymer,
    using rules: RuleCollection
) {
    for _ in 0 ..< reactions {
        polymer.react(using: rules)
    }
}

private typealias PairCollection = [String: Int]
private typealias RuleCollection = [String: Character]

private struct Polymer {
    private var pairs: [String: Int]
    private var elements: [Character: Int]

    var mostCommonElement: (Character, Int) { elements.max(by: \.value)! }
    var leastCommonElement: (Character, Int) { elements.min(by: \.value)! }

    init(_ input: String) {
        pairs = input.indices[input.index(after: input.startIndex)...]
            .reduce(into: [:]) { pairs, i in
                let pair = String(input[input.index(before: i) ... i])
                pairs[pair, default: 0] += 1
            }
        elements = input.reduce(into: [:]) { counts, element in counts[element, default: 0] += 1 }
    }

    mutating func react(using rules: RuleCollection) {
        for (pair, count) in pairs {
            guard let nextElement = rules[pair] else { fatalError() }

            elements[nextElement, default: 0] += count
            pairs[pair[0] + nextElement, default: 0] += count
            pairs[nextElement + pair[1], default: 0] += count
            pairs[pair, default: count] -= count
        }
    }
}

private func + (lhs: String, rhs: Character) -> String { lhs + String(rhs) }
private func + (lhs: Character, rhs: String) -> String { String(lhs) + rhs }

private func + (lhs: Character, rhs: Character) -> String { String(lhs) + String(rhs) }
