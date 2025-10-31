import AOCKit

private typealias Floor = [Position: Bool]

struct LobbyLayout: Puzzle {
    static let day = 24

    func part1(input: Input) throws -> Int {
        var floor = Floor()
        flipTiles(in: &floor, at: parse(input))
        return floor.values.count(where: \.isTrue)
    }

    func part2(input: Input) throws -> Int {
        var floor = Floor()
        flipTiles(in: &floor, at: parse(input))

        for _ in 0 ..< 100 {
            GameOfLife.playRound(on: &floor, using: willCellBeActive)
        }

        return floor.values.count(where: \.isTrue)
    }

    private func willCellBeActive(isActive: Bool, activeNeighbors: Int) -> Bool {
        if isActive, activeNeighbors == 0 || activeNeighbors > 2 {
            return false
        } else if !isActive, activeNeighbors == 2 {
            return true
        }
        return isActive
    }

    private func flipTiles(in tiles: inout Floor, at positions: [Position]) {
        for position in positions {
            tiles[position] = !tiles[position, default: false]
        }
    }

    private func parse(_ input: Input) -> [Position] {
        func parsePosition(from line: Line) -> Position {
            let characters = line.characters

            var position = Position.start
            var i = 0
            while i < characters.count {
                var d = String(characters[i])
                if d == "n" || d == "s" {
                    i += 1
                    d += String(characters[i])
                }
                i += 1

                let direction = Direction(rawValue: d)!
                position += direction
            }

            return position
        }

        return input.lines.map(parsePosition)
    }
}

/*
 Hex grid coordinates:
    ________
   / +y  +x \
  /          \
  \          /
   \___+z___/
  */
private enum Direction: String, CaseIterable {
    case east = "e"
    case west = "w"
    case northEast = "ne"
    case northWest = "nw"
    case southEast = "se"
    case southWest = "sw"

    var displacement: (dx: Int, dy: Int, dz: Int) {
        switch self {
            case .east: (1, -1, 0)
            case .west: (-1, 1, 0)
            case .northEast: (1, 0, -1)
            case .northWest: (0, 1, -1)
            case .southEast: (0, -1, 1)
            case .southWest: (-1, 0, 1)
        }
    }
}

private struct Position: Equatable, Hashable {
    var x: Int
    var y: Int
    var z: Int

    static let start = Position(x: 0, y: 0, z: 0)

    static func + (lhs: Position, rhs: Direction) -> Position {
        let (dx, dy, dz) = rhs.displacement
        return Position(x: lhs.x + dx, y: lhs.y + dy, z: lhs.z + dz)
    }

    static func += (lhs: inout Position, rhs: Direction) {
        let (dx, dy, dz) = rhs.displacement
        lhs.x += dx
        lhs.y += dy
        lhs.z += dz
    }
}

extension Position: GameOfLifePosition {
    var neighbors: [Position] {
        Direction.allCases.map { self + $0 }
    }
}

private extension Bool {
    var isTrue: Bool { self }
}
