import AOCKit

private typealias Floor = [Position: Bool]

struct LobbyLayout: Puzzle {
    func part1Solution(for input: String) throws -> Int {
        var floor = Floor()
        flipTiles(in: &floor, at: parse(input))
        return floor.values.count(where: \.isTrue)
    }

    func part2Solution(for input: String) throws -> Int {
        var floor = Floor()
        flipTiles(in: &floor, at: parse(input))

        for _ in 0 ..< 100 {
            for p in floor.keys {
                for neighbor in Direction.allCases.map({ p + $0 }) where floor[neighbor] == nil {
                    floor[neighbor] = false
                }
            }

            var tilesToFlip: [Position] = []
            for (position, isActive) in floor {
                let neighborCount = Direction.allCases.count { floor[position + $0] == true }
                if isActive, neighborCount == 0 || neighborCount > 2 {
                    tilesToFlip.append(position)
                } else if !isActive, neighborCount == 2 {
                    tilesToFlip.append(position)
                }
            }

            flipTiles(in: &floor, at: tilesToFlip)
        }

        return floor.values.count(where: \.isTrue)
    }

    private func flipTiles(in tiles: inout Floor, at positions: [Position]) {
        for position in positions {
            tiles[position] = !tiles[position, default: false]
        }
    }

    private func parse(_ input: String) -> [Position] {
        func parsePosition(from line: String) -> Position {
            let characters = Array(line)

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

        return getLines(from: input).map(parsePosition)
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
            case .east: return (1, -1, 0)
            case .west: return (-1, 1, 0)
            case .northEast: return (1, 0, -1)
            case .northWest: return (0, 1, -1)
            case .southEast: return (0, -1, 1)
            case .southWest: return (-1, 0, 1)
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

private extension Bool {
    var isTrue: Bool { self }
}
