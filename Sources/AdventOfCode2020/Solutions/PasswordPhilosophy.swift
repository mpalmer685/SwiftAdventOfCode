import AOCKit

struct PasswordPhilosophy: Puzzle {
    static let day = 2

    func part1() throws -> Int {
        count(entries: parseEntries(), using: Entry.characterCountPolicy)
    }

    func part2() throws -> Int {
        count(entries: parseEntries(), using: Entry.characterPositionPolicy)
    }

    private func parseEntries() -> [Entry] {
        input().lines
            .compactMap { Entry.pattern.match($0.raw) }
            .map(Entry.init)
    }

    private func count(entries: [Entry], using policy: Entry.Policy) -> Int {
        entries.filter(policy).count
    }
}

struct Entry {
    typealias Policy = (Entry) -> Bool

    static let characterCountPolicy: Policy = { entry in
        entry.password
            .count { $0 == entry.requiredCharacter }
            .isBetween(entry.minimum, and: entry.maximum)
    }

    static let characterPositionPolicy: Policy = { entry in
        [entry.minimum - 1, entry.maximum - 1]
            .map { entry.password[$0] }
            .count { $0 == entry.requiredCharacter } == 1
    }

    static let pattern =
        NSRegularExpression("(?<min>\\d+)-(?<max>\\d+)\\s+(?<char>[a-z]):\\s+(?<pw>[a-z]+)")

    var requiredCharacter: Character
    var minimum: Int
    var maximum: Int
    var password: String

    fileprivate init(_ match: RegexMatch) {
        guard #available(macOS 10.13, *) else {
            preconditionFailure()
        }

        requiredCharacter = Character(match["char"])
        minimum = Int(match["min"])!
        maximum = Int(match["max"])!
        password = match["pw"]
    }
}
