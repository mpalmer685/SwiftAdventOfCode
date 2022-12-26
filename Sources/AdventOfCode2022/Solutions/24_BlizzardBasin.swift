import AOCKit

class BlizzardBasin: Puzzle {
    static let day = 24

    func part1() throws -> Int {
        let valley = Valley(input())
        let pathfinder = AStarPathfinder(valley)

        let start = SearchState(location: valley.start)
        let destination = SearchState(location: valley.end)

        return pathfinder.path(from: start, to: destination).count
    }

    func part2() throws -> Int {
        let valley = Valley(input())
        let pathfinder = AStarPathfinder(valley)

        let firstTrip = pathfinder.path(
            from: SearchState(location: valley.start),
            to: SearchState(location: valley.end)
        )
        let returnTrip = pathfinder.path(
            from: SearchState(location: valley.end, time: firstTrip.count),
            to: SearchState(location: valley.start)
        )
        let finalTrip = pathfinder.path(
            from: SearchState(location: valley.start, time: firstTrip.count + returnTrip.count),
            to: SearchState(location: valley.end)
        )

        return firstTrip.count + returnTrip.count + finalTrip.count
    }
}

private struct Valley {
    enum Tile {
        case wall, ground
    }

    struct Blizzard: Hashable {
        let location: Map.Point
        let direction: Vector2D
    }

    typealias Map = Grid<Tile>

    private let map: Map
    private let blizzards: Set<Blizzard>
    private let blizzardStates: [Set<Map.Point>]

    let start: Map.Point
    let end: Map.Point

    init(_ input: Input) {
        let height = input.lines.count
        let width = input.lines[0].raw.count
        var map = Map(width: width, height: height, filledWith: .ground)
        var blizzards = Set<Blizzard>()
        for (y, line) in input.lines.enumerated() {
            for (x, char) in line.characters.enumerated() {
                let p = Map.Point(x, y)
                switch char {
                    case "#":
                        map[p] = .wall
                    case "^":
                        blizzards.insert(Blizzard(location: p, direction: .init(0, -1)))
                    case ">":
                        blizzards.insert(Blizzard(location: p, direction: .init(1, 0)))
                    case "v":
                        blizzards.insert(Blizzard(location: p, direction: .init(0, 1)))
                    case "<":
                        blizzards.insert(Blizzard(location: p, direction: .init(-1, 0)))
                    default:
                        break
                }
            }
        }

        self.map = map
        self.blizzards = blizzards
        blizzardStates = Self.findAllStates(for: blizzards, in: map)

        start = map.points.first { $0.y == 0 && map[$0] == .ground }!
        end = map.points.first { $0.y == map.height - 1 && map[$0] == .ground }!
    }

    static func findAllStates(for blizzards: Set<Blizzard>, in map: Map) -> [Set<Map.Point>] {
        func move(_ blizzards: Set<Blizzard>) -> Set<Blizzard> {
            blizzards.reduce(into: []) { next, blizzard in
                var p = blizzard.location.move(blizzard.direction)
                if p.x == 0 {
                    p = Map.Point(map.width - 2, p.y)
                } else if p.x == map.width - 1 {
                    p = Map.Point(1, p.y)
                } else if p.y == 0 {
                    p = Map.Point(p.x, map.height - 2)
                } else if p.y == map.height - 1 {
                    p = Map.Point(p.x, 1)
                }
                next.insert(Blizzard(location: p, direction: blizzard.direction))
            }
        }

        var current = blizzards
        let initial = Set(current.map(\.location))
        var states: [Set<Map.Point>] = [initial]
        var seen: Set<Set<Map.Point>> = [initial]
        for _ in 0 ..< lcm(map.width - 2, map.height - 2) {
            let moved = move(current)
            let state = Set(moved.map(\.location))

            if seen.contains(state) { break }

            states.append(state)
            seen.insert(state)
            current = moved
        }
        return states
    }
}

private struct SearchState: Hashable {
    let location: Valley.Map.Point
    let time: Int

    init(location: Valley.Map.Point, time: Int = 0) {
        self.location = location
        self.time = time
    }
}

extension Valley: AStarPathfindingGraph {
    func nextStates(from state: SearchState) -> [SearchState] {
        let blizzards = blizzardStates[(state.time + 1) % blizzardStates.count]
        let options = (state.location.orthogonalNeighbors + [state.location])
            .filter { map.contains($0) && map[$0] == .ground && !blizzards.contains($0) }

        return options.map { SearchState(location: $0, time: state.time + 1) }
    }

    func costToMove(from: SearchState, to: SearchState) -> Int {
        distance(from: from, to: to) + to.time
    }

    public func estimatedCost(from: SearchState, to: SearchState) -> Int {
        distance(from: from, to: to)
    }

    private func distance(from: SearchState, to: SearchState) -> Int {
        from.location.manhattanDistance(to: to.location)
    }

    func state(_ state: SearchState, matchesGoal goal: SearchState) -> Bool {
        state.location == goal.location
    }
}

private extension Valley.Map.Point {
    func move(_ direction: Vector2D) -> Self {
        offsetBy(direction.dx, direction.dy)
    }

    func manhattanDistance(to other: Self) -> Int {
        abs(x - other.x) + abs(y - other.y)
    }

    var orthogonalNeighbors: [Self] {
        let vectors: [Vector2D] = [
            .init(0, 1),
            .init(0, -1),
            .init(-1, 0),
            .init(1, 0),
        ]
        return vectors.map { move($0) }
    }
}

private func lcm<I: FixedWidthInteger>(_ values: I...) -> I {
    lcm(of: values)
}

private func lcm<C: Collection>(of values: C) -> C.Element where C.Element: FixedWidthInteger {
    let v = values.first!
    let r = values.dropFirst()
    guard r.isNotEmpty else { return v }

    let lcmR = lcm(of: r)
    return v / gcd(v, lcmR) * lcmR
}

private func gcd<I: FixedWidthInteger>(_ m: I, _ n: I) -> I {
    var a: I = 0
    var b: I = max(m, n)
    var r: I = min(m, n)

    while r != 0 {
        a = b
        b = r
        r = a % b
    }
    return b
}
