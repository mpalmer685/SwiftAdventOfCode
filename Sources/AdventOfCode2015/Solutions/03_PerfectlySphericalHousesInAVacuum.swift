import AOCKit

struct PerfectlySphericalHousesInAVacuum: Puzzle {
    static let day = 3

    private typealias DeliveryState = (visited: Set<Point2D>, position: Point2D)

    func part1(input: Input) async throws -> Int {
        let directions = input.characters.map(Vector2D.from(direction:))

        let (visited, _): DeliveryState = directions.reduce(into: (
            [.zero],
            .zero,
        )) { state, direction in
            state.position += direction
            state.visited.insert(state.position)
        }
        return visited.count
    }

    func part2(input: Input) async throws -> Int {
        let directions = input.characters.map(Vector2D.from(direction:))

        typealias SharedDeliveryState = (santa: DeliveryState, roboSanta: DeliveryState)

        let (santa, roboSanta): SharedDeliveryState = directions.enumerated().reduce(into: (
            (visited: [.zero], position: .zero),
            (visited: [.zero], position: .zero),
        )) { state, indexedDirection in
            let (index, direction) = indexedDirection
            if index.isMultiple(of: 2) {
                // Santa's turn
                state.santa.position += direction
                state.santa.visited.insert(state.santa.position)
            } else {
                // Robo-Santa's turn
                state.roboSanta.position += direction
                state.roboSanta.visited.insert(state.roboSanta.position)
            }
        }

        return santa.visited.union(roboSanta.visited).count
    }
}

private extension Vector2D {
    static func from(direction: Character) -> Self {
        switch direction {
            case "^": .init(dx: 0, dy: 1)
            case "v": .init(dx: 0, dy: -1)
            case ">": .init(dx: 1, dy: 0)
            case "<": .init(dx: -1, dy: 0)
            default:
                fatalError("Invalid direction character: \(direction)")
        }
    }
}

extension PerfectlySphericalHousesInAVacuum: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.raw(">")).expects(part1: 2),
            .given(.raw("^v")).expects(part2: 3),
            .given(.raw("^>v<")).expects(part1: 4, part2: 3),
            .given(.raw("^v^v^v^v^v")).expects(part1: 2, part2: 11),
        ]
    }
}
