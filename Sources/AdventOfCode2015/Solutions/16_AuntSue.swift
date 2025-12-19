import AOCKit

struct AuntSue: Puzzle {
    static let day = 16

    func part1(input: Input) async throws -> Int {
        let data = [
            "children": 3,
            "cats": 7,
            "samoyeds": 2,
            "pomeranians": 3,
            "akitas": 0,
            "vizslas": 0,
            "goldfish": 5,
            "trees": 3,
            "cars": 2,
            "perfumes": 1,
        ]

        let notes = parseNotes(from: input)
        let matchingSue = notes.first { _, properties in
            properties.allSatisfy { key, value in
                data[key] == value
            }
        }
        guard let sueNumber = matchingSue?.0 else {
            fatalError("No matching Sue found")
        }
        return sueNumber
    }

    func part2(input: Input) async throws -> Int {
        let data: [String: any RangeExpression<Int>] = [
            "children": 3 ... 3,
            "cats": 8...,
            "samoyeds": 2 ... 2,
            "pomeranians": ..<3,
            "akitas": 0 ... 0,
            "vizslas": 0 ... 0,
            "goldfish": ..<5,
            "trees": 4...,
            "cars": 2 ... 2,
            "perfumes": 1 ... 1,
        ]

        let notes = parseNotes(from: input)
        let matchingSue = notes.first { _, properties in
            properties.allSatisfy { key, value in
                guard let range = data[key] else {
                    fatalError("Unknown property \(key)")
                }
                return range.contains(value)
            }
        }
        guard let sueNumber = matchingSue?.0 else {
            fatalError("No matching Sue found")
        }
        return sueNumber
    }

    private func parseNotes(from input: Input) -> [(Int, [String: Int])] {
        let parser = Parse(input: Substring.self) {
            "Sue "
            Int.parser()
            ": "
            Many {
                Prefix(while: \.isLetter).map(String.init)
                ": "
                Int.parser()
            } separator: { ", " }.map { Dictionary(uniqueKeysWithValues: $0) }
        }

        return input.lines.raw.compactMap { try? parser.parse($0) }
    }
}
