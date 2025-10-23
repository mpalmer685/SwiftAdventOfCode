import AOCKit

struct BlizzardBasin: Puzzle {
    static let day = 24

    func part1(input: Input) throws -> Int {
        let valley = Valley(input)
        return valley.timeToTravel(from: valley.start, to: valley.end)
    }

    func part2(input: Input) throws -> Int {
        let valley = Valley(input)

        let firstTrip = valley.timeToTravel(from: valley.start, to: valley.end)
        let returnTrip = valley.timeToTravel(
            from: valley.end,
            to: valley.start,
            startTime: firstTrip
        )
        let finalTrip = valley.timeToTravel(
            from: valley.start,
            to: valley.end,
            startTime: firstTrip + returnTrip
        )

        return firstTrip + returnTrip + finalTrip
    }
}

private struct Valley {
    enum Tile {
        case wall, ground
    }

    struct Blizzard: Hashable {
        let location: Point2D
        let direction: Vector2D
    }

    typealias Map = Grid<Tile>

    private let map: Map
    private let blizzards: Set<Blizzard>
    private let blizzardStates: [Set<Point2D>]

    let start: Point2D
    let end: Point2D

    init(_ input: Input) {
        let height = input.lines.count
        let width = input.lines[0].raw.count
        var map = Map(width: width, height: height, filledWith: .ground)
        var blizzards = Set<Blizzard>()
        for (y, line) in input.lines.enumerated() {
            for (x, char) in line.characters.enumerated() {
                let p = Point2D(x, y)
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

    static func findAllStates(for blizzards: Set<Blizzard>, in map: Map) -> [Set<Point2D>] {
        func move(_ blizzards: Set<Blizzard>) -> Set<Blizzard> {
            blizzards.reduce(into: []) { next, blizzard in
                var p = blizzard.location.move(blizzard.direction)
                if p.x == 0 {
                    p = Point2D(map.width - 2, p.y)
                } else if p.x == map.width - 1 {
                    p = Point2D(1, p.y)
                } else if p.y == 0 {
                    p = Point2D(p.x, map.height - 2)
                } else if p.y == map.height - 1 {
                    p = Point2D(p.x, 1)
                }
                next.insert(Blizzard(location: p, direction: blizzard.direction))
            }
        }

        var current = blizzards
        let initial = Set(current.map(\.location))
        var states: [Set<Point2D>] = [initial]
        var seen: Set<Set<Point2D>> = [initial]
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
    let location: Point2D
    let time: Int

    init(location: Point2D, time: Int = 0) {
        self.location = location
        self.time = time
    }
}

extension Valley: Graph {
    func neighbors(of state: SearchState) -> [SearchState] {
        let blizzards = blizzardStates[(state.time + 1) % blizzardStates.count]
        let options = (state.location.orthogonalNeighbors + [state.location])
            .filter { map.contains($0) && map[$0] == .ground && !blizzards.contains($0) }

        return options.map { SearchState(location: $0, time: state.time + 1) }
    }
}

private extension Valley {
    func timeToTravel(from start: Point2D, to destination: Point2D, startTime: Int = 0) -> Int {
        let start = SearchState(location: start, time: startTime)
        let destination = SearchState(location: destination)

        let path = shortestPath(from: start) {
            $0.location == destination.location
        }
        return path.count
    }
}
