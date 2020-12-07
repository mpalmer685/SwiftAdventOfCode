import AOCKit
import Foundation

struct HandyHaversacks: Puzzle {
    func part1Solution(for input: String) throws -> Int {
        let rules = try parseBagRules(from: input)
        let startingColor = "shiny gold"

        var visited = Set<String>()
        var colors = [startingColor]
        while let nextColor = colors.popLast() {
            visited.insert(nextColor)
            let containers = rules
                .filter { $0.value.contains { $0.0 == nextColor } }
                .map { $0.key }
                .filter { !visited.contains($0) }
            colors += containers
        }
        visited.remove(startingColor)
        return visited.count
    }

    func part2Solution(for input: String) throws -> Int {
        let rules = try parseBagRules(from: input)
        let startingColor = "shiny gold"

        var cache = [String: Int]()
        func countChildren(of color: String) -> Int {
            if let cached = cache[color] {
                return cached
            }

            let childCount = rules[color]!.reduce(0) { $0 + $1.1 + $1.1 * countChildren(of: $1.0) }
            cache[color] = childCount
            return childCount
        }

        return countChildren(of: startingColor)
    }

    private func parseBagRules(from input: String) throws -> [String: [(String, Int)]] {
        try getLines(from: input)
            .map { $0.components(separatedBy: " contain ") }
            .reduce(into: [:], addBagRule)
    }

    private func addBagRule(rules: inout [String: [(String, Int)]], rule: [String]) throws {
        guard rule.count == 2 else { throw HandyHaversacksError.parseError }

        let containerBag = Self.containerBagPattern.match(rule[0])![1]
        let containedBags = try parseContainedBags(from: rule[1])

        rules[containerBag] = containedBags
    }

    private func parseContainedBags(from string: String) throws -> [(String, Int)] {
        guard !string.contains("no other bags") else { return [] }

        return string
            .components(separatedBy: ", ")
            .map { segment in
                let match = Self.containedBagPattern.match(segment)!
                return (match[2], Int(match[1])!)
            }
    }

    private static let containerBagPattern = NSRegularExpression("^([\\w\\s]+) bags$")
    private static let containedBagPattern = NSRegularExpression("^(\\d+) ([\\w\\s]+) bags?\\.?$")
}

enum HandyHaversacksError: Error {
    case parseError
    case platformNotSupported
}
