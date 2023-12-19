import AOCKit

struct Aplenty: Puzzle {
    static let day = 19

    // static let rawInput: String? = """
    // px{a<2006:qkq,m>2090:A,rfg}
    // pv{a>1716:R,A}
    // lnx{m>1548:A,A}
    // rfg{s<537:gd,x>2440:R,A}
    // qs{s>3448:A,lnx}
    // qkq{x<1416:A,crn}
    // crn{x>2662:A,R}
    // in{s<1351:px,qqz}
    // qqz{s>2770:qs,m<1801:hdj,R}
    // gd{a>3333:R,R}
    // hdj{m>838:A,pv}

    // {x=787,m=2655,a=1222,s=2876}
    // {x=1679,m=44,a=2067,s=496}
    // {x=2036,m=264,a=79,s=2244}
    // {x=2461,m=1339,a=466,s=291}
    // {x=2127,m=1623,a=2188,s=1013}
    // """

    func part1(input: Input) throws -> Int {
        let (workflows, parts) = parse(input)

        func isAccepted(_ part: Part) -> Bool {
            var workflowId = "in"
            workflow: while let rules = workflows[workflowId] {
                for rule in rules {
                    if let destination = rule.destination(for: part) {
                        if case let .workflow(id) = destination {
                            workflowId = id
                            continue workflow
                        } else if case .accepted = destination {
                            return true
                        } else if case .rejected = destination {
                            return false
                        }
                    }
                }
            }

            fatalError("Exhausted all rules and didn't find an end")
        }

        return parts.filter(isAccepted).sum(of: \.totalRating)
    }

    func part2(input: Input) throws -> Int {
        let (workflows, _) = parse(input)

        var queue: [(Destination, PartRange)] = [(.workflow("in"), .initial)]
        var accepted: [PartRange] = []

        while let (destination, range) = queue.popLast() {
            guard case let .workflow(id) = destination, let rules = workflows[id] else {
                fatalError()
            }

            let ranges = range.split(using: rules)
            accepted.append(contentsOf: ranges.filter { $0.0 == .accepted }.map(\.1))
            queue.append(contentsOf: ranges.filter(\.0.isWorkflow))
        }

        return accepted.sum(of: \.totalMatches)
    }

    private func parse(_ input: Input) -> ([String: [Rule]], [Part]) {
        let sections = input.lines.split(whereSeparator: \.isEmpty)
        let workflows: [String: [Rule]] = sections.first!.reduce(into: [:]) { workflows, line in
            var scanner = Scanner(line.raw)
            let id = String(scanner.scan(while: \.isLetter))
            scanner.expect("{")
            let rulesString = String(scanner.scan(while: { $0 != "}" }))
            let rules: [Rule] = Line(rulesString).csvWords.map { word in
                if let (category, value, nextLabel) = word.tryParseComparisonRule(operator: "<") {
                    .lessThan(RatingCategory(rawValue: category)!, value, Destination(nextLabel))
                } else if let (category, value, nextLabel) = word
                    .tryParseComparisonRule(operator: ">")
                {
                    .greaterThan(RatingCategory(rawValue: category)!, value, Destination(nextLabel))
                } else {
                    .goTo(Destination(word.raw))
                }
            }

            workflows[id] = rules
        }

        let parts = sections.last!.map(Part.init)

        return (workflows, parts)
    }
}

private enum RatingCategory: Character {
    case x = "x"
    case m = "m"
    case a = "a"
    case s = "s"
}

private struct PartRange {
    static let initial = PartRange([
        .x: 1 ... 4000,
        .m: 1 ... 4000,
        .a: 1 ... 4000,
        .s: 1 ... 4000,
    ])

    private let ranges: [RatingCategory: ClosedRange<Int>]

    private init(_ ranges: [RatingCategory: ClosedRange<Int>]) {
        self.ranges = ranges
    }

    var totalMatches: Int {
        ranges.values.product(of: { $0.upperBound - $0.lowerBound + 1 })
    }

    func split(using rules: [Rule]) -> [(Destination, Self)] {
        var remaining = ranges
        var result: [(Destination, Self)] = []

        for rule in rules {
            if case let .goTo(destination) = rule {
                result.append((destination, Self(remaining)))
            } else if case let .lessThan(category, value, destination) = rule {
                var newRanges = remaining
                let range = remaining[category]!
                remaining[category] = value ... range.upperBound
                newRanges[category] = range.lowerBound ... value - 1
                result.append((destination, Self(newRanges)))
            } else if case let .greaterThan(category, value, destination) = rule {
                var newRanges = remaining
                let range = remaining[category]!
                remaining[category] = range.lowerBound ... value
                newRanges[category] = value + 1 ... range.upperBound
                result.append((destination, Self(newRanges)))
            }
        }

        return result
    }
}

private struct Part {
    private let ratings: [RatingCategory: Int]

    var totalRating: Int {
        ratings.sum(of: \.value)
    }

    init(_ line: Line) {
        let start = line.raw.index(after: line.raw.startIndex)
        let end = line.raw.index(before: line.raw.endIndex)
        let parts = Line(String(line.raw[start ..< end])).words(separatedBy: ",")

        func getValue(forProperty property: String) -> Int {
            guard let part = parts.first(where: { $0.raw.hasPrefix(property) }) else {
                fatalError("Could not find property \(property) in \(line.raw)")
            }
            return part.words(separatedBy: "=")[1].integer!
        }

        ratings = [
            .x: getValue(forProperty: "x"),
            .m: getValue(forProperty: "m"),
            .a: getValue(forProperty: "a"),
            .s: getValue(forProperty: "s"),
        ]
    }

    subscript(category: RatingCategory) -> Int {
        ratings[category, default: 0]
    }
}

private enum Rule {
    case lessThan(RatingCategory, Int, Destination)
    case greaterThan(RatingCategory, Int, Destination)
    case goTo(Destination)

    func destination(for part: Part) -> Destination? {
        switch self {
            case let .goTo(destination):
                destination
            case let .lessThan(category, value, destination) where part[category] < value:
                destination
            case let .greaterThan(category, value, destination) where part[category] > value:
                destination
            default:
                nil
        }
    }
}

private enum Destination: Equatable {
    case workflow(String)
    case accepted
    case rejected

    init(_ label: String) {
        switch label {
            case "A":
                self = .accepted
            case "R":
                self = .rejected
            default:
                self = .workflow(label)
        }
    }

    var isWorkflow: Bool {
        if case .workflow = self {
            true
        } else {
            false
        }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
            case (.accepted, .accepted): true
            case (.rejected, .rejected): true
            case let (.workflow(a), .workflow(b)): a == b
            default: false
        }
    }
}

private extension Word {
    func tryParseComparisonRule(operator op: Character) -> (Character, Int, String)? {
        guard raw.contains(op), raw.contains(":") else {
            return nil
        }

        var parts = words(separatedBy: String(op))
        let category = parts[0].raw.first!
        parts = parts[1].words(separatedBy: ":")
        let value = parts[0].integer!
        let destination = parts[1].raw

        return (category, value, destination)
    }
}
