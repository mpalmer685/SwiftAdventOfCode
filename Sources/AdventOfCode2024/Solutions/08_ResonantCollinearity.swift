import AOCKit

struct ResonantCollinearity: Puzzle {
    static let day = 8

    func part1(input: Input) throws -> Int {
        let (positions, isInBounds) = parse(input)

        let antinodes = positions.reduce(into: Set<Point2D>()) { result, points in
            for permutation in points.permutations(ofCount: 2) {
                let first = permutation[0]
                let second = permutation[1]
                let offset = first.vector(towards: second)
                let antinode = second + offset
                if isInBounds(antinode) {
                    result.insert(antinode)
                }
            }
        }

        return antinodes.count
    }

    func part2(input: Input) throws -> Int {
        let (positions, isInBounds) = parse(input)

        let antinodes = positions.reduce(into: Set<Point2D>()) { result, points in
            for permutation in points.permutations(ofCount: 2) {
                let first = permutation[0]
                let second = permutation[1]
                let offset = first.vector(towards: second)

                result.insert(first)
                result.insert(second)

                var antinode = second + offset
                while isInBounds(antinode) {
                    result.insert(antinode)
                    antinode += offset
                }
            }
        }

        return antinodes.count
    }

    private func parse(_ input: Input)
        -> (positions: some Collection<Set<Point2D>>, isInBounds: (Point2D) -> Bool)
    {
        let map = Grid(input.lines.characters)
        let antennaePositions = map.points
            .filter { map[$0] != "." }
            .reduce(into: [Character: Set<Point2D>]()) { result, point in
                result[map[point], default: []].insert(point)
            }
            .values
            .filter { $0.count > 1 }

        return (positions: antennaePositions, isInBounds: map.contains)
    }
}

extension ResonantCollinearity: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.example).expects(part1: 14),
            .given(.file("harmonic-example")).expects(part2: 9),
        ]
    }
}
