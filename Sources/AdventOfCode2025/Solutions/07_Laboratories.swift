import AOCKit

struct Laboratories: Puzzle {
    static let day = 7

    func part1(input: Input) async throws -> Int {
        let (start, splitters, maxY) = parseDiagram(from: input)

        return (start.y ... maxY).reduce(into: (splits: 0, beams: Set([start.x]))) { state, y in
            var newBeams = Set<Int>()

            for beam in state.beams {
                if splitters.contains(Point2D(x: beam, y: y)) {
                    state.splits += 1
                    newBeams.formUnion([beam - 1, beam + 1])
                } else {
                    newBeams.insert(beam)
                }
            }

            state.beams = newBeams
        }.splits
    }

    func part2(input: Input) async throws -> Int {
        let (start, splitters, maxY) = parseDiagram(from: input)

        let countSplits: (Point2D) -> Int = recursiveMemoize { getNext, point in
            guard point.y <= maxY else {
                return 0
            }

            if splitters.contains(point) {
                let left = getNext(Point2D(x: point.x - 1, y: point.y + 1))
                let right = getNext(Point2D(x: point.x + 1, y: point.y + 1))
                return 1 + left + right
            } else {
                return getNext(Point2D(x: point.x, y: point.y + 1))
            }
        }

        return 1 + countSplits(start)
    }

    private func parseDiagram(from input: Input) -> (Point2D, Set<Point2D>, Int) {
        var start: Point2D?
        var splitters = Set<Point2D>()

        for (y, line) in input.lines.enumerated() {
            for (x, char) in line.characters.enumerated() {
                let point = Point2D(x: x, y: y)
                switch char {
                    case "S":
                        start = point
                    case "^":
                        splitters.insert(point)
                    default:
                        continue
                }
            }
        }

        guard let start else {
            fatalError("No starting point found in diagram.")
        }
        guard let maxY = splitters.max(of: \.y) else {
            fatalError("No splitters found in diagram.")
        }

        return (start, splitters, maxY)
    }
}

extension Laboratories: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.example).expects(part1: 21, part2: 40),
        ]
    }
}
