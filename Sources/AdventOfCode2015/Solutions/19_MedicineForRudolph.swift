import AOCKit

struct MedicineForRudolph: Puzzle {
    static let day = 19

    func part1(input: Input) async throws -> Int {
        let (replacements, molecule) = parseDetails(from: input)

        var distinctMolecules = Set<String>()
        for (from, tos) in replacements {
            let ranges = molecule.ranges(of: from)
            for range in ranges {
                for to in tos {
                    var newMolecule = molecule
                    newMolecule.replaceSubrange(range, with: to)
                    distinctMolecules.insert(newMolecule)
                }
            }
        }

        return distinctMolecules.count
    }

    func part2(input: Input) async throws -> Int {
        let (replacements, target) = parseDetails(from: input)
        let reversedReplacements: [String: String] = replacements.reduce(into: [:]) { dict, pair in
            for to in pair.value {
                dict[String(to.reversed())] = String(pair.key.reversed())
            }
        }

        var steps = 0
        var currentMolecule = String(target.reversed())
        while currentMolecule != "e" {
            var didReplace = false
            for (to, from) in reversedReplacements {
                if let range = currentMolecule.range(of: to) {
                    currentMolecule.replaceSubrange(range, with: from)
                    steps += 1
                    didReplace = true
                    break
                }
            }
            if !didReplace {
                fatalError("No replacement found; stuck at molecule: \(currentMolecule)")
            }
        }

        return steps
    }

    private func parseDetails(from input: Input)
        -> (replacements: [String: Set<String>], molecule: String)
    {
        let pattern = /^(?<from>[A-Za-z]+) => (?<to>[A-Za-z]+)$/
        let sections = input.lines.split(whereSeparator: \.isEmpty)

        let replacements: [String: Set<String>] = sections[0]
            .reduce(into: [:]) { replacements, line in
                guard let match = line.raw.wholeMatch(of: pattern) else {
                    fatalError("Invalid replacement line: \(line.raw)")
                }
                replacements[String(match.from), default: []].insert(String(match.to))
            }
        let molecule = sections[1].first!.raw

        return (replacements, molecule)
    }
}

extension MedicineForRudolph: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.raw(testInput(molecule: "HOH"))).expects(part1: 4, part2: 3),
            .given(.raw(testInput(molecule: "HOHOHO"))).expects(part1: 7, part2: 6),
        ]
    }
}

private let testReplacements = """
e => H
e => O
H => HO
H => OH
O => HH
"""

private func testInput(molecule: String) -> String {
    testReplacements + "\n\n" + molecule
}
