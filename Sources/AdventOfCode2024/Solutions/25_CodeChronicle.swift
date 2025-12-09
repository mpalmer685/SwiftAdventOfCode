import AOCKit

struct CodeChronicle: Puzzle {
    static let day = 25

    func part1(input: Input) throws -> Int {
        let schematics = input.lines
            .split(whereSeparator: \.isEmpty)
            .map { Schematic(cells: $0.characters) }

        let (locks, keys) = schematics.partitioned(where: \.isLock)

        return product(locks, keys).count { lock, key in
            lock.points.isDisjoint(with: key.points)
        }
    }
}

struct Schematic: Hashable {
    let points: Set<Point2D>

    init(cells: [[Character]]) {
        var points = Set<Point2D>()
        for (y, row) in cells.enumerated() {
            for (x, cell) in row.enumerated() where cell == "#" {
                points.insert(Point2D(x: x, y: y))
            }
        }
        self.points = points
    }

    var isLock: Bool {
        points.contains { $0.y == 0 }
    }
}

private extension Collection where Element: Hashable {
    func partitioned(where condition: (Element) -> Bool)
        -> (matching: Set<Element>, nonMatching: Set<Element>)
    {
        reduce(into: (matching: [], nonMatching: [])) { result, element in
            if condition(element) {
                result.matching.insert(element)
            } else {
                result.nonMatching.insert(element)
            }
        }
    }
}

extension CodeChronicle: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.example).expects(part1: 3),
        ]
    }
}
