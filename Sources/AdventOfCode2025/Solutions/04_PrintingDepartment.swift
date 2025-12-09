import AOCKit

struct PrintingDepartment: Puzzle {
    static let day = 4

    func part1(input: Input) async throws -> Int {
        parseDiagram(from: input).accessiblePoints.count
    }

    func part2(input: Input) async throws -> Int {
        var diagram = parseDiagram(from: input)
        let initialCount = diagram.count
        var toRemove = diagram.accessiblePoints

        while toRemove.isNotEmpty {
            diagram.removeRolls(at: toRemove)
            toRemove = diagram.accessiblePoints
        }

        return initialCount - diagram.count
    }

    private func parseDiagram(from input: Input) -> [Point2D: Int] {
        var occupied = Set<Point2D>()
        for (y, line) in input.lines.enumerated() {
            for (x, char) in line.characters.enumerated() where char == "@" {
                occupied.insert(Point2D(x: x, y: y))
            }
        }

        return occupied.reduce(into: [:]) { counts, point in
            counts[point] = Vector2D.adjacents.count { offset in
                occupied.contains(point + offset)
            }
        }
    }
}

private extension [Point2D: Int] {
    var accessiblePoints: Set<Point2D> {
        Set(filter { $0.value < 4 }.map(\.key))
    }

    mutating func removeRolls(at points: Set<Point2D>) {
        for point in points {
            removeValue(forKey: point)
            for offset in Vector2D.adjacents {
                let neighbor = point + offset
                if let count = self[neighbor] {
                    self[neighbor] = count - 1
                }
            }
        }
    }
}

extension PrintingDepartment: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.example).expects(part1: 13, part2: 43),
        ]
    }
}
