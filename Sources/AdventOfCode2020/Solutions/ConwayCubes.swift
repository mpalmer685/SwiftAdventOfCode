import AOCKit

struct ConwayCubes: Puzzle {
    static let day = 17

    func part1() throws -> Int {
        var field: [Position3D: Bool] = try parseInput()
        for _ in 0 ..< 6 {
            GameOfLife.playRound(on: &field, using: willCellBeActive)
        }

        return field.count { $0.value }
    }

    func part2() throws -> Int {
        var field: [Position4D: Bool] = try parseInput()
        for _ in 0 ..< 6 {
            GameOfLife.playRound(on: &field, using: willCellBeActive)
        }

        return field.count { $0.value }
    }

    private func parseInput<T: Position>() throws -> [T: Bool] {
        var field: [T: Bool] = [:]
        for (y, line) in input().lines.enumerated() {
            for (x, cell) in line.characters.enumerated() {
                field[try T([x, y])] = cell == "#"
            }
        }
        return field
    }

    private func willCellBeActive(isActive: Bool, activeNeighbors: Int) -> Bool {
        if isActive, activeNeighbors != 2, activeNeighbors != 3 {
            return false
        } else if !isActive, activeNeighbors == 3 {
            return true
        }
        return isActive
    }
}

private protocol Position: GameOfLifePosition {
    init(_ coords: [Int]) throws
}

private struct Position3D: Position, Equatable, Hashable {
    let x: Int
    let y: Int
    let z: Int

    var neighbors: [Position3D] {
        var neighbors = [Position3D]()
        for dx in -1 ... 1 {
            for dy in -1 ... 1 {
                for dz in -1 ... 1 where !(dx == 0 && dy == 0 && dz == 0) {
                    neighbors.append(Position3D(x + dx, y + dy, z + dz))
                }
            }
        }
        return neighbors
    }

    init(_ coords: [Int]) throws {
        guard coords.count <= 3 else {
            throw ConwayCubesError.invalidCoordinates
        }

        x = coords[0, default: 0]
        y = coords[1, default: 0]
        z = coords[2, default: 0]
    }

    init(_ x: Int, _ y: Int, _ z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }
}

private struct Position4D: Position, Equatable, Hashable {
    let x: Int
    let y: Int
    let z: Int
    let w: Int

    var neighbors: [Position4D] {
        var neighbors = [Position4D]()
        for dx in -1 ... 1 {
            for dy in -1 ... 1 {
                for dz in -1 ... 1 {
                    for dw in -1 ... 1 where !(dx == 0 && dy == 0 && dz == 0 && dw == 0) {
                        neighbors.append(Position4D(x + dx, y + dy, z + dz, w + dw))
                    }
                }
            }
        }
        return neighbors
    }

    init(_ coords: [Int]) throws {
        guard coords.count <= 4 else {
            throw ConwayCubesError.invalidCoordinates
        }

        x = coords[0, default: 0]
        y = coords[1, default: 0]
        z = coords[2, default: 0]
        w = coords[3, default: 0]
    }

    init(_ x: Int, _ y: Int, _ z: Int, _ w: Int) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }
}

private enum ConwayCubesError: Error {
    case invalidCoordinates
}

private extension Array {
    subscript(index: Index, default defaultValue: @autoclosure () -> Element) -> Element {
        guard index < count else { return defaultValue() }
        return self[index]
    }
}
