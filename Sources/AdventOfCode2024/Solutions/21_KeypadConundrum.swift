import AOCKit

struct KeypadConundrum: Puzzle {
    static let day = 21

    func part1(input: Input) throws -> Int {
        let codes = input.lines.map(\.raw)
        return codes.sum { code in
            let keypresses = keypresses(for: code, robots: 2)
            let numericCode = Int(code.replacingOccurrences(of: "A", with: ""))!
            return keypresses * numericCode
        }
    }

    func part2(input: Input) throws -> Int {
        let codes = input.lines.map(\.raw)
        return codes.sum { code in
            let keypresses = keypresses(for: code, robots: 25)
            let numericCode = Int(code.replacingOccurrences(of: "A", with: ""))!
            return keypresses * numericCode
        }
    }
}

private struct State: Hashable {
    let start: Character
    let end: Character
    let level: Int
}

private func keypresses(for code: String, robots: Int) -> Int {
    let keys = ["A"] + Array(code)
    return keys.adjacentPairs().sum { start, end in
        countKeypresses(.numeric, start, end, robots + 1)
    }
}

private nonisolated(unsafe) let countKeypresses =
    recursiveMemoize(
        getKey: { (_: Keypad, start: Character, end: Character, level: Int) in
            State(start: start, end: end, level: level)
        },
        { countKeypresses, keypad, start, end, level -> Int in
            if level == 0 { return 1 }

            return keypad.steps(from: start, to: end).min { steps in
                let sequence = Array("A" + steps)
                return sequence.adjacentPairs().sum { start, end in
                    countKeypresses(.directional, start, end, level - 1)
                }
            }!
        }
    )

private struct Keypad {
    private typealias StepMap = [Character: [Character: [String]]]

    private let steps: StepMap

    static let numeric = Keypad(keys: [
        ["7", "8", "9"],
        ["4", "5", "6"],
        ["1", "2", "3"],
        [nil, "0", "A"],
    ])

    static let directional = Keypad(keys: [
        [nil, "^", "A"],
        ["<", "v", ">"],
    ])

    init(keys: [[Character?]]) {
        var map = [Point2D: Character]()
        for (y, row) in keys.enumerated() {
            for (x, ch) in row.enumerated() {
                guard let ch else { continue }
                map[Point2D(x, y)] = ch
            }
        }

        steps = Self.generateSteps(map)
    }

    private static func generateSteps(_ map: [Point2D: Character]) -> StepMap {
        var steps = StepMap()
        for (start, end) in product(map.values, map.values) {
            steps[start, default: [:]][end] = generateSteps(map: map, start: start, end: end)
        }

        return steps
    }

    private static func generateSteps(
        map: [Point2D: Character],
        start: Character,
        end: Character,
        visited: Set<Character> = []
    ) -> [String] {
        if start == end { return ["A"] }

        let startPoint = map.first { $0.value == start }!.key
        var results = [String]()
        for dir in Vector2D.orthogonalAdjacents {
            guard let nextChar = map[startPoint + dir] else { continue }
            guard nextChar != "X", !visited.contains(nextChar) else { continue }
            let nextSteps = generateSteps(
                map: map,
                start: nextChar,
                end: end,
                visited: visited.union([start])
            )
            results.append(contentsOf: nextSteps.map { dir.key + $0 })
        }

        return results
    }

    @inlinable func steps(from start: Character, to end: Character) -> [String] {
        steps[start]![end]!
    }
}

private extension Vector2D {
    var key: String {
        switch (dx, dy) {
            case (0, -1): "^"
            case (0, 1): "v"
            case (-1, 0): "<"
            case (1, 0): ">"
            default: fatalError("Invalid vector: \(self)")
        }
    }
}

extension KeypadConundrum: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .init(input: .example, part1: 126_384),
        ]
    }
}
