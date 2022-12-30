import AOCKit

struct SeaCucumber: Puzzle {
    static let day = 25

    func part1() throws -> Int {
        var grid = parseInput()
        var step = 1

        while grid.canMove() {
            grid.move()
            step += 1
        }

        return step
    }

    private func parseInput() -> Grid<Location> {
        let cells = input().lines.characters.map { $0.map(Location.init) }
        return Grid(cells)
    }
}

private extension Grid where Cell == Location {
    mutating func move() {
        move(.east)
        move(.south)
    }

    mutating func move(_ location: Location) {
        let pointsToMove = points.filter { self[$0] == location && canMove(at: $0) }
        for point in pointsToMove {
            guard let next = nextPosition(for: point) else { fatalError() }
            self[point] = .empty
            self[next] = location
        }
    }

    func canMove() -> Bool {
        points.contains(where: canMove)
    }

    func canMove(at position: Point2D) -> Bool {
        guard let next = nextPosition(for: position) else { return false }
        return self[next] == .empty
    }

    private func nextPosition(for position: Point2D) -> Point2D? {
        switch self[position] {
            case .empty: return nil
            case .east: return wrap(position + .x)
            case .south: return wrap(position + .y)
        }
    }

    private func wrap(_ position: Point2D) -> Point2D {
        Point2D(position.x % width, position.y % height)
    }
}

private enum Location {
    case empty, east, south

    init(_ c: Character) {
        switch c {
            case ".":
                self = .empty
            case ">":
                self = .east
            case "v":
                self = .south
            default:
                fatalError("Invalid character \(c)")
        }
    }

    var nextStep: Self {
        switch self {
            case .empty: return self
            case .east: return .south
            case .south: return .east
        }
    }
}

private let testInput = """
v...>>.vv>
.vv>>.vv..
>>.>v>...v
>>v>>.>.v.
v>v.vv.v..
>.>>..v...
.vv..>.>v.
v.v..>>v.v
....v..v.>
"""
