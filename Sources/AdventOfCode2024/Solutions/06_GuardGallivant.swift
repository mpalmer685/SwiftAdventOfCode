import AOCKit

struct GuardGallivant: Puzzle {
    static let day = 6

    func part1(input: Input) throws -> Int {
        let simulation = Simulation(input: input)
        guard case let .exit(visited) = simulation.run() else {
            fatalError()
        }
        return visited.count
    }

    func part2(input: Input) throws -> Int {
        let simulation = Simulation(input: input)
        guard case let .exit(visited) = simulation.run() else {
            fatalError()
        }

        return sync {
            await visited.concurrentCount { point in
                simulation.addingObstacle(at: point).run().isLoop
            }
        }
    }
}

private final class Simulation: Sendable {
    private let grid: Grid<Character>
    private let start: State

    enum Result {
        case loop
        case exit(Set<Point2D>)

        var isLoop: Bool {
            if case .loop = self { return true }
            return false
        }
    }

    private struct State: Hashable {
        let position: Point2D
        let direction: Vector2D

        func turnedRight() -> State {
            .init(position: position, direction: direction.turnedRight())
        }

        func movedForward() -> State {
            .init(position: position + direction, direction: direction)
        }

        func nextPosition() -> Point2D {
            position + direction
        }
    }

    private init(grid: Grid<Character>, start: State) {
        self.grid = grid
        self.start = start
    }

    convenience init(input: Input) {
        var grid = Grid(input.lines.characters)
        guard let start = grid.points.first(where: { Vector2D.symbols.contains(grid[$0]) })
        else {
            fatalError()
        }
        let direction = Vector2D.direction(from: grid[start])
        grid[start] = "."

        self.init(grid: grid, start: .init(position: start, direction: direction))
    }

    func run() -> Result {
        var visited = Set<State>([start])
        var current = start

        while grid.contains(current.position) {
            let next = current.nextPosition()
            guard grid.contains(next) else {
                return .exit(Set(visited.map(\.position)))
            }
            if grid[next] == "." {
                current = current.movedForward()
            } else {
                current = current.turnedRight()
            }

            guard visited.insert(current).inserted else {
                return .loop
            }
        }

        return .exit(Set(visited.map(\.position)))
    }

    func addingObstacle(at point: Point2D) -> Simulation {
        var copy = grid
        copy[point] = "#"
        return Simulation(grid: copy, start: start)
    }
}

private extension Vector2D {
    static var symbols: Set<Character> { ["^", "v", "<", ">"] }

    static func direction(from symbol: Character) -> Vector2D {
        switch symbol {
            case "^": -.y
            case "v": .y
            case "<": -.x
            case ">": .x
            default: fatalError("Invalid symbol: \(symbol)")
        }
    }

    func turnedRight() -> Vector2D {
        switch self {
            case .x: .y
            case .y: -.x
            case -.x: -.y
            case -.y: .x
            default: fatalError()
        }
    }
}

extension GuardGallivant: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .init(input: .example, part1: 41, part2: 6),
        ]
    }
}
