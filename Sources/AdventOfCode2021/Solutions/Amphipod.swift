import AOCKit
import Foundation

struct Amphipod: Puzzle {
    static let day = 23

    func part1() throws -> Int {
        solve(parse(lines: input().lines))
    }

    func part2() throws -> Int {
        let extraLines = ["  #D#C#B#A#  ", "  #D#B#A#C#  "].map(Line.init)
        var lines = input().lines
        lines.insert(contentsOf: extraLines, at: 3)
        return solve(parse(lines: lines))
    }

    func parse(lines: [Line]) -> Grid<Character> {
        let cols = lines[0].raw.count
        let cells = lines.map(\.characters).map { $0.padded(toLength: cols, with: " ") }
        return Grid(cells)
    }
}

private typealias Point = GridPoint

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

private func reachablePoints(from point: Point, in grid: Grid<Character>) -> [Point: Int] {
    var costs: [Point: Int] = [:]
    func canMove(to point: Point) -> Bool {
        grid.contains(point) && grid[point] == "." && costs[point] == nil
    }
    func fillDistances(from point: Point, _ distance: Int = 0) {
        if canMove(to: point) { costs[point] = distance }
        let offsets = [(-1, 0), (1, 0), (0, -1), (0, 1)].map(point.offsetBy)
        for dest in offsets where canMove(to: dest) {
            fillDistances(from: dest, distance + 1)
        }
    }

    fillDistances(from: point)
    return costs
}

private func moveIsPermitted(from: Point, to: Point, in grid: Grid<Character>) -> Bool {
    func isDestinationInHall() -> Bool { to.y == 1 }
    func isCorrectRoom() -> Bool {
        to.y > 1 && to.x == grid[from].roomColumn
    }
    func noStrangersInRoom() -> Bool {
        let type = grid[from]
        return (2 ..< grid.height - 1)
            .map { y in grid[y][type.roomColumn] }
            .allSatisfy { [".", type].contains($0) }
    }
    func isLowestAvailableSpot() -> Bool {
        ["#", grid[from]].contains(grid[to.y + 1][to.x])
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

private func isOccupied(at point: Point, in grid: Grid<Character>) -> Bool {
    "ABCD".contains(grid[point])
}

private func isTypeCompleted(at point: Point, in grid: Grid<Character>) -> Bool {
    let type = grid[point]
    return
        point.x == type.roomColumn &&
        (point.y + 1 ..< grid.height - 1).allSatisfy { grid[$0][point.x] == type }
}

private typealias Move = (destination: Point, distance: Int)

private func nextMoves(from origin: Point, in grid: Grid<Character>) -> [Move] {
    reachablePoints(from: origin, in: grid)
        .filter { moveIsPermitted(from: origin, to: $0.key, in: grid) }
        .map { ($0.key, $0.value) }
}

func solve(_ initState: Grid<Character>) -> Int {
    var paths: [(state: Grid<Character>, cost: Int)] = [(initState, 0)],
        final: [(state: Grid<Character>, cost: Int)] = [],
        best: [Grid<Character>: Int] = [:]

    while !paths.isEmpty {
        let (state, cost) = paths.removeLast()
        for p in state.points
            where isOccupied(at: p, in: state) && !isTypeCompleted(at: p, in: state)
        {
            for (destination, distance) in nextMoves(from: p, in: state) {
                var tempState = state
                tempState[p] = "."
                tempState[destination] = state[p]
                let cost = cost + state[p].costPerStep * distance

                if best[tempState] == nil || best[tempState]! > cost {
                    best[tempState] = cost
                    if isSolved(tempState) {
                        final.append((tempState, cost))
                    } else {
                        paths.append((tempState, cost))
                    }
                }
            }
        }
    }

    guard let minCost = final.min(by: \.cost)?.cost else { fatalError() }
    return minCost
}

private let types = Array("ABCD")
private let rooms = [3, 5, 7, 9]

private func isSolved(_ state: Grid<Character>) -> Bool {
    zip(types, rooms).allSatisfy { x in
        let (type, col) = x
        return (2 ..< state.height - 1).allSatisfy { row in state[row][col] == type }
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
