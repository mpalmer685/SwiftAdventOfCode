import AOCKit

struct ElvesLookElvesSay: Puzzle {
    static let day = 10

    func part1(input: Input) async throws -> Int {
        (1 ... 40).reduce(input.raw) { sequence, _ in
            lookAndSay(sequence)
        }.count
    }

    func part2(input: Input) async throws -> Int {
        (1 ... 50).reduce(input.raw) { sequence, _ in
            lookAndSay(sequence)
        }.count
    }

    private func lookAndSay(_ sequence: String) -> String {
        var scanner = Scanner(sequence)
        var result = ""

        while scanner.hasMore {
            let currentChar = scanner.peek()
            let group = scanner.scan(repeating: currentChar)
            result += "\(group.count)\(currentChar)"
        }

        return result
    }
}

private extension Scanner where C.Element: Equatable {
    mutating func scan(repeating element: C.Element) -> C.SubSequence {
        scan(while: { $0 == element })
    }
}
