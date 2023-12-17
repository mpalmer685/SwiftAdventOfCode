import AOCKit

struct ClumsyCrucible: Puzzle {
    static let day = 17

    // static let rawInput: String? = """
    // 2413432311323
    // 3215453535623
    // 3255245654254
    // 3446585845452
    // 4546657867536
    // 1438598798454
    // 4457876987766
    // 3637877979653
    // 4654967986887
    // 4564679986453
    // 1224686865563
    // 2546548887735
    // 4322674655533
    // """

    // static let rawInput: String? = """
    // 111111111111
    // 999999999991
    // 999999999991
    // 999999999991
    // 999999999991
    // """

    func part1(input: Input) throws -> Int {
        let map = Grid(input.lines.digits)
        let path = LavaPath(map)
        return path.heatLoss()
    }

    func part2(input: Input) throws -> Int {
        let map = Grid(input.lines.digits)
        let path = LavaPath(map, minStreak: 4, maxStreak: 10)
        return path.heatLoss()
    }
}

private struct LavaPath {
    private let map: Grid<Int>
    private let minStreak: Int
    private let maxStreak: Int

    private let start = Point2D.zero
    private var end: Point2D {
        Point2D(map.width - 1, map.height - 1)
    }

    init(_ map: Grid<Int>) {
        self.map = map
        minStreak = 1
        maxStreak = 3
    }

    init(_ map: Grid<Int>, minStreak: Int, maxStreak: Int) {
        self.map = map
        self.minStreak = minStreak
        self.maxStreak = maxStreak
    }

    func heatLoss() -> Int {
        let pathfinder = DijkstraPathfinder(self)
        let end = end
        let path = pathfinder.path(from: SearchState(location: start)) { state in
            state.location == end && state.streak >= minStreak
        }
        return path.sum { map[$0.location] }
    }
}

extension LavaPath: DijkstraPathfindingGraph {
    func nextStates(from state: SearchState) -> [(SearchState, Int)] {
        var states = [SearchState]()

        for dir in Vector2D.orthogonalAdjacents {
            if let direction = state.direction {
                if direction == -dir {
                    // don't backtrack
                    continue
                }
                if direction == dir, state.streak >= maxStreak {
                    // can't keep going beyond max streak
                    continue
                }
                if direction != dir, state.streak < minStreak {
                    // gotta keep going until the min streak
                    continue
                }
            }

            let next = state.location + dir
            guard map.contains(next) else { continue }
            let streak = dir == state.direction ? state.streak + 1 : 1
            states.append(SearchState(
                location: next,
                direction: dir,
                streak: streak
            ))
        }

        return states.map { state in
            (state, map[state.location])
        }
    }
}

struct SearchState: Hashable {
    let location: Point2D
    let direction: Vector2D?
    let streak: Int

    init(location: Point2D) {
        self.location = location
        direction = nil
        streak = 0
    }

    init(location: Point2D, direction: Vector2D, streak: Int) {
        self.location = location
        self.direction = direction
        self.streak = streak
    }
}

extension SearchState: CustomStringConvertible {
    var description: String {
        if let direction = direction {
            "\(location), \(direction), streak: \(streak)"
        } else {
            "\(location), streak: \(streak)"
        }
    }
}
