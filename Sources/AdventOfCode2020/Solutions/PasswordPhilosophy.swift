import AOCKit
import Foundation

struct PasswordPhilosophy: Puzzle {
    func part1Solution(for input: String) throws -> Int {
        count(entries: parseEntries(from: input), using: Entry.characterCountPolicy)
    }

    func part2Solution(for input: String) throws -> Int {
        count(entries: parseEntries(from: input), using: Entry.characterPositionPolicy)
    }

    private func parseEntries(from input: String) -> [Entry] {
        getLines(from: input)
            .compactMap(Entry.pattern.match)
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
            .filter { $0 == entry.requiredCharacter }
            .count
            .isBetween(entry.minimum, and: entry.maximum)
    }

    static let characterPositionPolicy: Policy = { entry in
        [entry.minimum - 1, entry.maximum - 1]
            .map { entry.password[$0] }
            .filter { $0 == entry.requiredCharacter }
            .count == 1
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
