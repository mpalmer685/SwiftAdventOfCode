import AOCKit

struct LongWalk: Puzzle {
    static let day = 23

    func part1(input: Input) throws -> Int {
        let map = Grid(data: input.lines.characters, withTransform: Tile.init)
        guard let start = map.firstLocation(inRow: 0, of: .path),
              let end = map.firstLocation(inRow: map.height - 1, of: .path)
        else {
            fatalError()
        }

        struct Graph: MapGraph {
            // swiftlint:disable:next nesting
            typealias State = GraphState

            let map: Grid<Tile>

            var accessiblePoints: any Collection<Point2D> {
                map.points.filter { map[$0] != .forest }
            }

            func hasJunction(at location: Point2D) -> Bool {
                location.orthogonalNeighbors.count { p in
                    map.contains(p) && map[p] != .forest
                } > 2
            }

            func neighbors(of location: Point2D) -> [Point2D] {
                Vector2D.orthogonalAdjacents.compactMap { (v: Vector2D) -> Point2D? in
                    let next = location + v
                    guard map.contains(next) else { return nil }

                    let cell = map[next]
                    guard cell == .path || cell == .slope(v) else {
                        return nil
                    }
                    return next
                }
            }
        }

        return Graph(map: map).maximumPathLength(from: start, to: end)
    }

    func part2(input: Input) throws -> Int {
        let map = Grid(data: input.lines.characters, withTransform: Tile.init)
        guard let start = map.firstLocation(inRow: 0, of: .path),
              let end = map.firstLocation(inRow: map.height - 1, of: .path)
        else {
            fatalError()
        }

        struct Graph: MapGraph {
            // swiftlint:disable:next nesting
            typealias State = GraphState

            let map: Grid<Tile>

            var accessiblePoints: any Collection<Point2D> {
                map.points.filter { map[$0] != .forest }
            }

            func hasJunction(at location: Point2D) -> Bool {
                neighbors(of: location).count > 2
            }

            func neighbors(of location: Point2D) -> [Point2D] {
                location.orthogonalNeighbors.filter { map.contains($0) && map[$0] != .forest }
            }
        }

        return Graph(map: map).maximumPathLength(from: start, to: end)
    }
}

private enum Tile: Equatable, CustomStringConvertible {
    case path
    case forest
    case slope(Vector2D)

    init(_ char: Character) {
        self = switch char {
            case ".": .path
            case "^": .slope(-.y)
            case "v": .slope(.y)
            case ">": .slope(.x)
            case "<": .slope(-.x)
            case "#": .forest
            default: fatalError()
        }
    }

    var description: String {
        switch self {
            case .path: "."
            case .forest: "#"
            case let .slope(v):
                switch (v.dx, v.dy) {
                    case (0, 1): "v"
                    case (0, -1): "^"
                    case (1, 0): ">"
                    case (-1, 0): "<"
                    default: "?"
                }
        }
    }
}

private struct GraphState: PathLengthGraphState, Hashable {
    let points: Set<Point2D>
    let last: Point2D
}

private protocol PathLengthGraphState: Hashable {
    var points: Set<Point2D> { get }
    var last: Point2D { get }

    init(points: Set<Point2D>, last: Point2D)
}

private extension PathLengthGraphState {
    init(start: Point2D) {
        self.init(points: [start], last: start)
    }

    func next(movingTo nextPos: Point2D) -> Self {
        Self(points: points.union([nextPos]), last: nextPos)
    }

    func contains(_ point: Point2D) -> Bool {
        points.contains(point)
    }
}

private protocol MapGraph {
    var accessiblePoints: any Collection<Point2D> { get }

    func hasJunction(at: Point2D) -> Bool
    func neighbors(of: Point2D) -> [Point2D]
}

private extension MapGraph {
    func maximumPathLength(from start: Point2D, to end: Point2D) -> Int {
        let junctions = junctions(between: start, and: end)
        let paths = paths(between: junctions)

        func maximumPathLength(from start: Point2D, seen: Set<Point2D>) -> Int? {
            guard start != end else { return 0 }
            guard let pathsFromStart = paths[start] else {
                fatalError()
            }

            var maxLength: Int?
            for (dest, length) in pathsFromStart where !seen.contains(dest) {
                guard let best = maximumPathLength(from: dest, seen: seen.inserting(dest)) else {
                    continue
                }
                maxLength = max(maxLength ?? -1, best + length)
            }

            return maxLength
        }

        return maximumPathLength(from: start, seen: [start])!
    }

    private func junctions(between start: Point2D, and end: Point2D) -> Set<Point2D> {
        var junctions: Set<Point2D> = [start, end]

        for point in accessiblePoints where hasJunction(at: point) {
            junctions.insert(point)
        }

        return junctions
    }

    private func paths(between junctions: Set<Point2D>) -> [Point2D: [(Point2D, Int)]] {
        var paths: [Point2D: [(Point2D, Int)]] = [:]

        for junction in junctions {
            for neighbor in neighbors(of: junction) {
                var current = neighbor
                var path: Set<Point2D> = [junction]

                repeat {
                    path.insert(current)
                    let neighbors = neighbors(of: current).filter { !path.contains($0) }
                    guard neighbors.count <= 1 else {
                        fatalError()
                    }
                    guard let next = neighbors.first else {
                        break
                    }
                    current = next
                } while !junctions.contains(current)

                paths[junction, default: []].append((current, path.count))
            }
        }

        return paths
    }
}

private extension Grid where Cell: Equatable {
    func firstLocation(inRow rowIndex: Int, of element: Cell) -> Point2D? {
        let row = self[row: rowIndex]
        guard let col = row.firstIndex(of: element) else {
            return nil
        }
        return Point2D(col, rowIndex)
    }
}

private extension Set {
    func inserting(_ newMember: Element) -> Self {
        var next = self
        next.insert(newMember)
        return next
    }
}
