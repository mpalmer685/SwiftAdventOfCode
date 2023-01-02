import AOCKit

class MonkeyMap: Puzzle {
    static let day = 22

    private lazy var monkeyNotes: (Map, [Instruction]) = {
        let parts = input().lines.split(whereSeparator: \.isEmpty)
        assert(parts.count == 2)

        var map = Map()
        for (row, line) in parts[0].enumerated() {
            for (col, char) in line.characters.enumerated() {
                let point = Point2D(col, row)
                if char == "#" {
                    map[point] = .wall
                } else if char == "." {
                    map[point] = .open
                }
            }
        }

        var scanner = Scanner(Array(parts[1])[0].raw)
        var path = [Instruction]()
        var scanningSteps = true
        while scanner.hasMore {
            let instruction: Instruction = scanningSteps
                ? .steps(scanner.scanInt()!)
                : .turn(scanner.scanDirection())
            path.append(instruction)
            scanningSteps.toggle()
        }

        return (map, path)
    }()

    func part1() throws -> Int {
        let (map, instructions) = monkeyNotes
        let walker = Walker(map)
        walker.follow(instructions)
        return walker.password
    }

    func part2() throws -> Int {
        let (map, instructions) = monkeyNotes
        let faces = createFaces(sideLength: 50)
        let walker = Walker(map)
        walker.follow(instructions) { _, position, heading in
            guard let face = faces.first(where: { $0.contains(position) }) else {
                fatalError()
            }

            let side: Face.Side
            if position.y == face.rows.lowerBound, heading.dy == -1 {
                side = .top
            } else if position.y == face.rows.upperBound, heading.dy == 1 {
                side = .bottom
            } else if position.x == face.cols.lowerBound, heading.dx == -1 {
                side = .left
            } else if position.x == face.cols.upperBound, heading.dx == 1 {
                side = .right
            } else {
                fatalError()
            }

            guard let (neighbor, adjacentSide, rotations) = face.neighbors[side] else {
                return (position.offset(by: heading), heading)
            }

            let currentEdge = face.edge(on: side)
            var adjacentEdge = neighbor.edge(on: adjacentSide)
            if rotations.count == 2 {
                adjacentEdge.reverse()
            }

            let adjoiningEdges = zip(currentEdge, adjacentEdge)
            let nextPosition = adjoiningEdges.first { $0.0 == position }!.1
            let nextHeading = rotations.reduce(heading) { $0.turn($1) }

            return (nextPosition, nextHeading)
        }
        return walker.password
    }
}

private typealias Map = [Point2D: Tile]

private enum Tile {
    case open, wall
}

private enum Instruction {
    case steps(Int)
    case turn(Direction)

    func type(matches other: Self) -> Bool {
        switch (self, other) {
            case (.steps, .steps): return true
            case (.turn, .turn): return true
            default: return false
        }
    }
}

extension Instruction: CustomStringConvertible {
    public var description: String {
        switch self {
            case let .steps(count): return count.description
            case let .turn(dir): return String(dir.rawValue)
        }
    }
}

private enum Direction: Character {
    case left = "L"
    case right = "R"
}

private class Walker {
    typealias EdgeMapper = (Map, Point2D, Vector2D) -> (Point2D, Vector2D)

    private(set) var position: Point2D
    private(set) var heading = Vector2D.right

    private var map: Map

    var password: Int {
        1000 * (position.y + 1) + 4 * (position.x + 1) + heading.facingValue
    }

    init(_ map: Map) {
        self.map = map
        position = map.keys.filter { $0.y == 0 }.min(by: \.x)!
    }

    func follow(_ instructions: [Instruction], wrap getNextEdge: EdgeMapper = Walker.wrap) {
        for instruction in instructions {
            switch instruction {
                case let .steps(count):
                    stepForward(count, with: getNextEdge)
                case let .turn(direction):
                    heading = heading.turn(direction)
            }
        }
    }

    private func stepForward(_ count: Int, with getNextEdge: EdgeMapper) {
        for _ in 0 ..< count {
            var nextPosition = position.offset(by: heading)
            var nextHeading: Vector2D?
            if map[nextPosition] == nil {
                (nextPosition, nextHeading) = getNextEdge(map, position, heading)
            }
            if case .wall = map[nextPosition] {
                break
            }
            position = nextPosition
            if let nextHeading = nextHeading, nextHeading != heading {
                heading = nextHeading
            }
        }
    }

    private static func wrap(
        _ map: Map,
        _ position: Point2D,
        _ heading: Vector2D
    ) -> (Point2D, Vector2D) {
        switch (heading.dx, heading.dy) {
            case (1, 0): return (map.leftmost(inRow: position.y), heading)
            case (0, -1): return (map.lowest(inColumn: position.x), heading)
            case (-1, 0): return (map.rightmost(inRow: position.y), heading)
            case (0, 1): return (map.highest(inColumn: position.x), heading)
            default: fatalError()
        }
    }
}

private extension Dictionary where Key == Point2D {
    func leftmost(inRow y: Int) -> Key {
        keys.filter { $0.y == y }.min(by: \.x)!
    }

    func rightmost(inRow y: Int) -> Key {
        keys.filter { $0.y == y }.max(by: \.x)!
    }

    func highest(inColumn x: Int) -> Key {
        keys.filter { $0.x == x }.min(by: \.y)!
    }

    func lowest(inColumn x: Int) -> Key {
        keys.filter { $0.x == x }.max(by: \.y)!
    }
}

private extension Vector2D {
    static var right: Self { Self(dx: 1, dy: 0) }

    var facingValue: Int {
        switch (dx, dy) {
            case (1, 0): return 0
            case (0, 1): return 1
            case (-1, 0): return 2
            case (0, -1): return 3
            default: fatalError()
        }
    }

    func turn(_ dir: Direction) -> Self {
        switch dir {
            case .left:
                return Self(dx: dy, dy: -dx)
            case .right:
                return Self(dx: -dy, dy: dx)
        }
    }
}

private extension Scanner where C.Element == Character {
    mutating func scanDirection() -> Direction {
        assert(hasMore, "Reached the end")
        return Direction(rawValue: next())!
    }
}

private func createFaces(sideLength: Int) -> [Face] {
    /* Side 1 */ var top = Face(size: sideLength, startX: sideLength, startY: 0)
    /* Side 2 */ var right = Face(size: sideLength, startX: 2 * sideLength, startY: 0)
    /* Side 3 */ var front = Face(size: sideLength, startX: sideLength, startY: sideLength)
    /* Side 4 */ var bottom = Face(size: sideLength, startX: sideLength, startY: 2 * sideLength)
    /* Side 5 */ var left = Face(size: sideLength, startX: 0, startY: 2 * sideLength)
    /* Side 6 */ var back = Face(size: sideLength, startX: 0, startY: 3 * sideLength)

    top.neighbors = [
        .top: (back, .left, [.right]),
        .left: (left, .left, [.left, .left]),
    ]
    right.neighbors = [
        .top: (back, .bottom, []),
        .right: (bottom, .right, [.right, .right]),
        .bottom: (front, .right, [.right]),
    ]
    front.neighbors = [
        .right: (right, .bottom, [.left]),
        .left: (left, .top, [.left]),
    ]
    bottom.neighbors = [
        .right: (right, .right, [.right, .right]),
        .bottom: (back, .right, [.right]),
    ]
    left.neighbors = [
        .top: (front, .left, [.right]),
        .left: (top, .left, [.right, .right]),
    ]
    back.neighbors = [
        .right: (bottom, .bottom, [.left]),
        .bottom: (right, .top, []),
        .left: (top, .top, [.left]),
    ]

    return [top, right, front, bottom, left, back]
}

private struct Face {
    enum Side {
        case top, right, bottom, left
    }

    typealias Neighbor = (Face, Side, [Direction])

    let rows: ClosedRange<Int>
    let cols: ClosedRange<Int>

    var neighbors: [Side: Neighbor] = [:]

    var lowerBounds: Point2D {
        Point2D(x: cols.lowerBound, y: rows.lowerBound)
    }

    private let origin: (Double, Double)

    init(size: Int, startX: Int, startY: Int) {
        rows = startY ... startY + size - 1
        cols = startX ... startX + size - 1

        let midX = (Double(cols.upperBound) - Double(cols.lowerBound)) / 2
        let midY = (Double(rows.upperBound) - Double(rows.lowerBound)) / 2
        origin = (midX, midY)
    }

    func edge(on side: Side) -> [Point2D] {
        switch side {
            case .top: return cols.map { .init($0, rows.lowerBound) }
            case .bottom: return cols.map { .init($0, rows.upperBound) }
            case .left: return rows.map { .init(cols.lowerBound, $0) }
            case .right: return rows.map { .init(cols.upperBound, $0) }
        }
    }

    func contains(_ point: Point2D) -> Bool {
        rows.contains(point.y) && cols.contains(point.x)
    }
}

/*
 Side 1:
    Top (^) -> Side 6 Left (>); col -> row
    Right (>): continuous
    Bottom (v): continuous
    Left (<) -> Side 5 Left (>); row -> -row
 Side 2:
    Top (^) -> Side 6 Bottom (^); col -> col
    Right (>) -> Side 4 Right (<); row -> -row
    Bottom (v) -> Side 3 Right (<); col -> row
    Left (<): continuous
 Side 3:
    Top (^): continuous
    Right (>) -> Side 2 Bottom (^); row -> col
    Bottom (v): continuous
    Left (<) -> Side 5 Top (v); row -> col
 Side 4:
    Top (^): continuous
    Right (>) -> Side 2 Right (<); row -> -row
    Bottom (v) -> Side 6 Right (<); col -> row
    Left (<): continuous
 Side 5:
    Top (^) -> Side 3 Left (>); col -> row
    Right (>): continuous
    Bottom (v): continuous
    Left (<) -> Side 1 Left (>); row -> -row
 Side 6:
    Top (^): continuous
    Right (>) -> Side 4 Bottom (^); row -> col
    Bottom (v) -> Side 2 Top (v); col -> col
    Left (<) -> Side 1 Top (v); row -> col
 */
