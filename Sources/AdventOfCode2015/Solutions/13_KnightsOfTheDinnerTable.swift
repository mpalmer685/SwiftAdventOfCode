import AOCKit

struct KnightsOfTheDinnerTable: Puzzle {
    static let day = 13

    func part1(input: Input) async throws -> Int {
        let preferences = parsePreferences(from: input)
        let people = Array(preferences.keys)

        return bestArrangement(for: people, preferences: preferences)
    }

    func part2(input: Input) async throws -> Int {
        var preferences = parsePreferences(from: input)
        let people = Array(preferences.keys)

        // Add "Me" with zero happiness change with everyone
        preferences["Me"] = [:]
        for person in people {
            preferences[person]?["Me"] = 0
            preferences["Me"]?[person] = 0
        }

        let allPeople = people + ["Me"]
        return bestArrangement(for: allPeople, preferences: preferences)
    }

    private typealias Preferences = [String: [String: Int]]

    private func bestArrangement(for people: [String], preferences: Preferences) -> Int {
        people.permutations().max { seating in
            seating.enumerated().reduce(0) { total, pair in
                let (index, person) = pair
                let leftNeighbor = seating[(index - 1 + seating.count) % seating.count]
                let rightNeighbor = seating[(index + 1) % seating.count]
                let happinessChange = (preferences[person]?[leftNeighbor] ?? 0) +
                    (preferences[person]?[rightNeighbor] ?? 0)
                return total + happinessChange
            }
        }!
    }

    private func parsePreferences(from input: Input) -> Preferences {
        let parser = Parse(input: Substring.self) {
            Prefix { !$0.isWhitespace }.map(String.init)
            " would "
            OneOf {
                "gain ".map { 1 }
                "lose ".map { -1 }
            }
            Int.parser()
            " happiness units by sitting next to "
            Prefix { $0 != "." }.map(String.init)
            "."
        }

        return input.lines
            .compactMap { try? parser.parse($0.raw) }
            .reduce(into: [:]) { preferences, row in
                let (personA, sign, units, personB) = row
                preferences[personA, default: [:]][personB] = sign * units
            }
    }
}

extension KnightsOfTheDinnerTable: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.example).expects(part1: 330),
        ]
    }
}
