import AOCKit

struct TheFloorWillBeLava: Puzzle {
    static let day = 16

    // static let rawInput: String? = """
    // .|...\\....
    // |.-.\\.....
    // .....|-...
    // ........|.
    // ..........
    // .........\\
    // ..../.\\\\..
    // .-.-/..|..
    // .|....-|.\\
    // ..//.|....
    // """

    func part1(input: Input) throws -> Int {
        let map = parseMap(from: input)
        let energized = followPath(in: map, startingAt: .zero, moving: .east)

        return energized.count
    }

    func part2(input: Input) throws -> Int {
        let map = parseMap(from: input)
        var max: Int = .min

        for x in 0 ..< map.width {
            let fromTop = followPath(in: map, startingAt: Point2D(x, 0), moving: .south)
            let fromBottom = followPath(
                in: map,
                startingAt: Point2D(x, map.height - 1),
                moving: .north,
            )
            max = Swift.max(max, fromTop.count, fromBottom.count)
        }

        for y in 0 ..< map.height {
            let fromLeft = followPath(in: map, startingAt: Point2D(0, y), moving: .east)
            let fromRight = followPath(
                in: map,
                startingAt: Point2D(map.width - 1, y),
                moving: .west,
            )
            max = Swift.max(max, fromLeft.count, fromRight.count)
        }

        return max
    }

    private func parseMap(from input: Input) -> Grid<Tile> {
        let tiles = input.lines.map { line in
            line.characters.compactMap(Tile.init)
        }
        return Grid(tiles)
    }

    private func followPath(
        in map: Grid<Tile>,
        startingAt start: Point2D,
        moving direction: Vector2D,
    ) -> Set<Point2D> {
        var visited = Set<Tuple<Point2D, Vector2D>>()
        var beams: [(Point2D, Vector2D)] = [(start, direction)]

        while let beam = beams.popLast() {
            guard visited.insert(Tuple(beam)).inserted else {
                continue
            }

            let (location, direction) = beam
            for dir in map[location].nextDirections(moving: direction) {
                let nextLocation = location + dir
                if map.contains(nextLocation) {
                    beams.append((nextLocation, dir))
                }
            }
        }

        return Set(visited.map(\.0))
    }
}

private enum Tile: Character {
    case empty = "."
    case rightMirror = "/"
    case leftMirror = "\\"
    case verticalSplitter = "|"
    case horizontalSplitter = "-"

    func nextDirections(moving dir: Vector2D) -> [Vector2D] {
        switch (self, dir) {
            case (.rightMirror, .north), (.leftMirror, .south):
                [.east]
            case (.rightMirror, .south), (.leftMirror, .north):
                [.west]
            case (.rightMirror, .east), (.leftMirror, .west):
                [.north]
            case (.rightMirror, .west), (.leftMirror, .east):
                [.south]
            case (.verticalSplitter, dir) where dir.dx != 0:
                [.north, .south]
            case (.horizontalSplitter, dir) where dir.dy != 0:
                [.east, .west]
            default:
                [dir]
        }
    }
}

private extension Vector2D {
    static var north: Self { -.y }
    static var south: Self { .y }
    static var west: Self { -.x }
    static var east: Self { .x }
}

@dynamicMemberLookup
private struct Tuple<A: Hashable, B: Hashable>: Hashable {
    private let a: A
    private let b: B

    init(_ tuple: (A, B)) {
        a = tuple.0
        b = tuple.1
    }

    init(_ a: A, _ b: B) {
        self.a = a
        self.b = b
    }

    subscript<T>(dynamicMember keyPath: KeyPath<(A, B), T>) -> T {
        (a, b)[keyPath: keyPath]
    }
}
