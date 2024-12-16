import AOCKit

struct ReindeerMaze: Puzzle {
    static let day = 16

    func part1(input: Input) throws -> Int {
        Maze.parse(from: input).bestScore()
    }

    func part2(input: Input) throws -> Int {
        Maze.parse(from: input).bestSeats().count
    }
}

private struct Maze {
    private let map: Grid<Character>

    struct Reindeer: Hashable {
        var position: Point2D
        var direction: Vector2D

        var nextPosition: Point2D { position + direction }

        func turned(_ turn: Vector2D.Turn) -> Self {
            .init(position: position, direction: direction.rotated(turn))
        }

        func movedForward() -> Self {
            .init(position: nextPosition, direction: direction)
        }
    }

    static func parse(from input: Input) -> Self {
        .init(map: Grid(input.lines.characters))
    }

    func bestScore() -> Int {
        guard let start = map.points.first(where: { map[$0] == "S" }) else {
            fatalError("No starting point found")
        }
        guard let end = map.points.first(where: { map[$0] == "E" }) else {
            fatalError("No ending point found")
        }

        return bestScore(from: start, to: end)
    }

    func bestSeats() -> Set<Point2D> {
        guard let start = map.points.first(where: { map[$0] == "S" }) else {
            fatalError("No starting point found")
        }
        guard let end = map.points.first(where: { map[$0] == "E" }) else {
            fatalError("No ending point found")
        }

        let bestScore = bestScore(from: start, to: end)
        let costsFromStart = nodesAccessible(from: Reindeer(position: start, direction: .x))

        var seats = Set<Point2D>()

        for dir in Vector2D.orthogonalAdjacents {
            let reindeer = Reindeer(position: end, direction: dir)
            let costsFromEnd = nodesAccessible(from: reindeer)

            for (state, costFromStart) in costsFromStart {
                let reversed = Reindeer(position: state.position, direction: -state.direction)
                guard let costFromEnd = costsFromEnd[reversed] else {
                    fatalError()
                }

                if costFromStart + costFromEnd == bestScore {
                    seats.insert(state.position)
                }
            }
        }

        return seats
    }

    private func bestScore(from start: Point2D, to end: Point2D) -> Int {
        let reindeerStart = Reindeer(position: start, direction: .x)
        return costOfPath(from: reindeerStart, until: { $0.position == end })
    }
}

extension Maze: WeightedGraph {
    func neighbors(of current: Reindeer) -> [(Reindeer, Int)] {
        let turns = [
            (current.turned(.left), 1000),
            (current.turned(.right), 1000),
        ]

        let forward = current.nextPosition
        guard map[forward] != "#" else {
            return turns
        }

        return turns + [(current.movedForward(), 1)]
    }
}

private extension Vector2D {
    func rotated(_ turn: Turn) -> Self {
        switch turn {
            case .left: Vector2D(dy, -dx)
            case .right: Vector2D(-dy, dx)
        }
    }

    enum Turn {
        case left
        case right
    }
}

extension ReindeerMaze: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .init(input: .example(1), part1: 7036, part2: 45),
            .init(input: .example(2), part1: 11048, part2: 64),
        ]
    }
}
