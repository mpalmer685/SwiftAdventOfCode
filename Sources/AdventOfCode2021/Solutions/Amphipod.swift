import AOCKit

struct Amphipod: Puzzle {
    static let day = 23

    func part1() throws -> Int {
        Burrow().cost(toOrganize: parse(lines: input().lines))
    }

    func part2() throws -> Int {
        let extraLines = ["  #D#C#B#A#  ", "  #D#B#A#C#  "].map(Line.init)
        var lines = input().lines
        lines.insert(contentsOf: extraLines, at: 3)
        return Burrow().cost(toOrganize: parse(lines: lines))
    }

    func parse(lines: [Line]) -> Grid<Character> {
        let cols = lines[0].raw.count
        let cells = lines.map(\.characters).map { $0.padded(toLength: cols, with: " ") }
        return Grid(cells)
    }
}

private extension Character {
    var value: Int {
        guard let value = asciiValue else { fatalError() }
        return Int(value) - 65
    }

    var roomColumn: Int {
        value * 2 + 3
    }

    var costPerStep: Int {
        Int(pow(10, Float(value)))
    }
}

private extension Grid where Cell == Character {
    func isOccupied(_ point: Point2D) -> Bool {
        Burrow.types.contains(self[point])
    }

    func isTypeCompleted(at point: Point2D) -> Bool {
        let type = self[point]
        return point.x == type.roomColumn &&
            (point.y + 1 ..< height - 1).allSatisfy { self[point.x, $0] == type }
    }
}

private struct Burrow: DijkstraPathfindingGraph {
    fileprivate static let types = Array("ABCD")
    fileprivate static let rooms = [3, 5, 7, 9]

    func cost(toOrganize grid: Grid<Character>) -> Int {
        DijkstraPathfinder(self).costOfPath(from: grid) { grid -> Bool in
            zip(Self.types, Self.rooms).allSatisfy { type, col in
                (2 ..< grid.height - 1)
                    .allSatisfy { row in grid[col, row] == type }
            }
        }
    }

    func nextStates(from state: Grid<Character>) -> [(Grid<Character>, Int)] {
        state.points
            .filter { state.isOccupied($0) && !state.isTypeCompleted(at: $0) }
            .flatMap { p in
                nextMoves(from: p, in: state).map { destination, distance in
                    var tempGrid = state
                    tempGrid[p] = "."
                    tempGrid[destination] = state[p]

                    return (tempGrid, state[p].costPerStep * distance)
                }
            }
    }

    private typealias Move = (destination: Point2D, distance: Int)

    private func nextMoves(from origin: Point2D, in grid: Grid<Character>) -> [Move] {
        reachablePoints(from: origin, in: grid)
            .filter { moveIsPermitted(from: origin, to: $0.key, in: grid) }
            .map { ($0.key, $0.value) }
    }

    private func reachablePoints(from point: Point2D, in grid: Grid<Character>) -> [Point2D: Int] {
        var costs: [Point2D: Int] = [:]
        func canMove(to point: Point2D) -> Bool {
            grid.contains(point) && grid[point] == "." && costs[point] == nil
        }
        func fillDistances(from point: Point2D, _ distance: Int = 0) {
            if canMove(to: point) { costs[point] = distance }
            for dest in point.orthogonalNeighbors where canMove(to: dest) {
                fillDistances(from: dest, distance + 1)
            }
        }

        fillDistances(from: point)
        return costs
    }

    private func moveIsPermitted(from: Point2D, to: Point2D, in grid: Grid<Character>) -> Bool {
        func isDestinationInHall() -> Bool { to.y == 1 }
        func isCorrectRoom() -> Bool {
            to.y > 1 && to.x == grid[from].roomColumn
        }
        func noStrangersInRoom() -> Bool {
            let type = grid[from]
            return (2 ..< grid.height - 1)
                .map { y in grid[type.roomColumn, y] }
                .allSatisfy { [".", type].contains($0) }
        }
        func isLowestAvailableSpot() -> Bool {
            ["#", grid[from]].contains(grid[to.x, to.y + 1])
        }
        func isDestinationAdjacentToRoom() -> Bool {
            to.y == 1 && [3, 5, 7, 9].contains(to.x)
        }

        if from.y == 1 {
            return
                !isDestinationInHall() &&
                isCorrectRoom() &&
                noStrangersInRoom() &&
                isLowestAvailableSpot()
        } else {
            return isDestinationInHall() && !isDestinationAdjacentToRoom()
        }
    }
}

private extension Array {
    func padded(toLength length: Int, with filler: @autoclosure () -> Element) -> Self {
        let padding: Self = {
            let paddingLength = length - count
            guard paddingLength > 0 else { return [] }
            return Array(repeating: filler(), count: paddingLength)
        }()

        return self + padding
    }

    func slice(_ start: Int, _ end: Int) -> SubSequence {
        let startIndex = index(startIndex, offsetBy: start)
        let endIndex = end >= 0
            ? index(self.startIndex, offsetBy: end)
            : index(endIndex, offsetBy: end)
        return self[startIndex ..< endIndex]
    }
}
