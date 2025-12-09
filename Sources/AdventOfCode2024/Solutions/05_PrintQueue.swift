import AOCKit

struct PrintQueue: Puzzle {
    static let day = 5

    func part1(input: Input) throws -> Int {
        let (rules, updates) = parse(input)

        return updates.filter { $0.isSorted(using: rules) }.map(\.middleElement).sum
    }

    func part2(input: Input) throws -> Int {
        let (rules, updates) = parse(input)

        return updates
            .lazy
            .filter { !$0.isSorted(using: rules) }
            .map { $0.sorted(using: rules) }
            .map(\.middleElement)
            .sum
    }

    private func parse(_ input: Input) -> ([Int: Set<Int>], [[Int]]) {
        let sections = input.lines.split(whereSeparator: \.isEmpty)
        assert(sections.count == 2)

        let rules = sections[0].reduce(into: [Int: Set<Int>]()) { rules, line in
            let pages = line.integers
            assert(pages.count == 2, "Invalid rule: \(line.raw)")
            rules[pages[0], default: []].insert(pages[1])
        }

        let updates = sections[1].map(\.integers)

        return (rules, updates)
    }
}

private extension BidirectionalCollection {
    var middleElement: Element {
        self[index(startIndex, offsetBy: count / 2)]
    }
}

private extension [Int] {
    func isSorted(using rules: [Int: Set<Int>]) -> Bool {
        !adjacentPairs().contains { first, second in
            rules[second]?.contains(first) == true
        }
    }

    func sorted(using rules: [Int: Set<Int>]) -> Self {
        sorted { first, second in
            guard let successors = rules[first] else {
                return originalOrder(first, second)
            }
            return successors.contains(second)
        }
    }

    private func originalOrder(_ left: Element, _ right: Element) -> Bool {
        guard let first = firstIndex(of: left), let second = firstIndex(of: right) else {
            fatalError()
        }
        return first < second
    }
}

extension PrintQueue: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.example).expects(part1: 143, part2: 123),
        ]
    }
}
