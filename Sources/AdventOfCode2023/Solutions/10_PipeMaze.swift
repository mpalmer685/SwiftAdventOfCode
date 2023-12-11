import AOCKit

struct PipeMaze: Puzzle {
    static let day = 10

    func part1(input: Input) throws -> Int {
        parse(input).loop.count / 2
    }

    func part2(input: Input) throws -> Int {
        let (map, loop) = parse(input)
        return map.points.count { point in
            guard !loop.contains(point) else { return false }

            return loop.count { pipe in
                pipe.y == point.y && pipe.x < point.x && map[pipe].connections.contains(.north)
            }.isOdd
        }
    }

    private func parse(_ input: Input) -> (map: Grid<Tile>, loop: Set<Point2D>) {
        let tiles = input.lines.map { line in
            line.characters.compactMap(Tile.init)
        }
        var map = Grid(tiles)

        guard let start = map.firstLocation(of: .start) else {
            fatalError("Couldn't find start location")
        }
        let startConnections = Set(Vector2D.orthogonalAdjacents).filter { v in
            map[start + v].connections.contains(-v)
        }
        guard startConnections.count == 2 else {
            fatalError("Expected to find 2 connections from start, but found \(startConnections)")
        }
        guard let startReplacement = Tile.allCases.filter(\.isPipe)
            .first(where: { $0.connections == startConnections })
        else {
            fatalError("Couldn't find replacement tile for start")
        }
        map[start] = startReplacement

        var loop = [start]
        var next = start + startConnections.first!
        while next != start {
            let prev = loop.last!
            loop.append(next)
            next = map[next].connections
                .map { next + $0 }
                .first { $0 != prev }!
        }

        return (map, Set(loop))
    }
}

private enum Tile: Character, CaseIterable {
    case vertical = "|"
    case horizontal = "-"
    case northEastBend = "L"
    case northWestBend = "J"
    case southWestBend = "7"
    case southEastBend = "F"
    case start = "S"
    case ground = "."

    var isPipe: Bool { self != .start && self != .ground }

    var connections: Set<Vector2D> {
        switch self {
            case .vertical: [.north, .south]
            case .horizontal: [.west, .east]
            case .northEastBend: [.north, .east]
            case .northWestBend: [.north, .west]
            case .southEastBend: [.south, .east]
            case .southWestBend: [.south, .west]
            case .ground: []
            case .start: fatalError("start connections not known")
        }
    }
}

private extension Vector2D {
    static var north: Self { -.y }
    static var south: Self { .y }
    static var east: Self { .x }
    static var west: Self { -.x }
}

private extension Grid where Cell: Equatable {
    func firstLocation(of value: Cell) -> Point2D? {
        points.first(where: { self[$0] == value })
    }
}

private extension Int {
    var isOdd: Bool {
        !isMultiple(of: 2)
    }
}
