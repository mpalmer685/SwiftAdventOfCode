import AOCKit

struct LavaductLagoon: Puzzle {
    static let day = 18

    // static let rawInput: String? = """
    // R 6 (#70c710)
    // D 5 (#0dc571)
    // L 2 (#5713f0)
    // D 2 (#d2c081)
    // R 2 (#59c680)
    // D 2 (#411b91)
    // L 5 (#8ceee2)
    // U 2 (#caa173)
    // L 1 (#1b58a2)
    // U 2 (#caa171)
    // R 2 (#7807d2)
    // U 3 (#a77fa3)
    // L 2 (#015232)
    // U 2 (#7a21e3)
    // """

    func part1(input: Input) throws -> Int {
        let plan = input.lines.map { line in
            var scanner = Scanner(line.raw)

            let direction = scanner.next()
            let unitVector: Vector2D = switch direction {
                case "U": -.y
                case "D": .y
                case "L": -.x
                case "R": .x
                default: fatalError()
            }

            scanner.skip(while: \.isWhitespace)

            let count = scanner.tryScanInt()!

            return unitVector * count
        }

        return area(from: plan)
    }

    func part2(input: Input) throws -> Int {
        let plan = input.lines.map { line in
            var scanner = Scanner(line.raw)
            scanner.skip(while: { $0 != "#" })
            scanner.expect("#")
            let hexCode = scanner.scan(while: { $0 != ")" })
            let distanceHex = hexCode.prefix(hexCode.count - 1)
            let distance = Int(distanceHex, radix: 16)!
            let directionCode = hexCode.suffix(1)
            let unitVector: Vector2D = switch directionCode {
                case "0": .x
                case "1": .y
                case "2": -.x
                case "3": -.y
                default: fatalError()
            }

            return unitVector * distance
        }

        return area(from: plan)
    }

    private func area(from plan: [Vector2D]) -> Int {
        let vertices: [Point2D] = plan.reduce(into: [.zero]) { vertices, step in
            let next = vertices.last! + step
            vertices.append(next)
        }

        let area = vertices.adjacentPairs().sum { first, second in
            first.x * second.y - second.x * first.y
        }
        let perimeter = vertices.adjacentPairs().sum { first, second in
            first.manhattanDistance(to: second)
        }

        return 1 + (abs(area) + perimeter) / 2
    }
}

private extension Vector2D {
    static func * (lhs: Self, rhs: Int) -> Self {
        Self(lhs.dx * rhs, lhs.dy * rhs)
    }
}
