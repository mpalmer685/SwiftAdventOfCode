import AOCKit

struct ConwayCubes: Puzzle {
    func part1Solution(for input: String) throws -> Int {
        let field: Set<Position3D> = try simulate(using: input)
        return field.count
    }

    func part2Solution(for input: String) throws -> Int {
        let field: Set<Position4D> = try simulate(using: input)
        return field.count
    }

    private func simulate<T: Position>(using input: String) throws -> Set<T> {
        var field: Set<T> = try parse(input)
        for _ in 0 ..< 6 {
            try advance(&field)
        }
        return field
    }

    private func advance<T: Position>(_ field: inout Set<T>) throws {
        var copy = field

        func check(position: [Int], dimensions: [KeyPath<T, Int>]) throws {
            if dimensions.isEmpty {
                let p = try T(position)
                if isCellActive(in: field, at: p) {
                    copy.insert(p)
                } else {
                    copy.remove(p)
                }
            } else {
                let (min, max) = field.extent(of: dimensions.first!)!
                for x in min - 1 ... max + 1 {
                    try check(position: position + [x], dimensions: Array(dimensions[1...]))
                }
            }
        }

        try check(position: [], dimensions: T.dimensions)

        field = copy
    }

    private func isCellActive<T: Position>(in field: Set<T>, at position: T) -> Bool {
        let activeNeighbors = position.neighbors.count(where: field.contains)
        let isActive = field.contains(position)
        if isActive && activeNeighbors != 2 && activeNeighbors != 3 {
            return false
        } else if !isActive && activeNeighbors == 3 {
            return true
        }
        return isActive
    }

    private func parse<T: Position>(_ input: String) throws -> Set<T> {
        var field = Set<T>()
        for (y, line) in getLines(from: input).enumerated() {
            let cells = Array(line).enumerated().filter { $0.element == "#" }.map(\.offset)
            for x in cells {
                field.insert(try T([x, y]))
            }
        }
        return field
    }
}

private protocol Position {
    static var dimensions: [KeyPath<Self, Int>] { get }

    init(_ coords: [Int]) throws

    var neighbors: [Self] { get }
}

extension Position {
    static var dimensionality: Int { dimensions.count }
}

private struct Position3D: Position, Equatable, Hashable {
    static var dimensions: [KeyPath<Position3D, Int>] { [\.x, \.y, \.z] }

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

        self.x = coords[0, default: 0]
        self.y = coords[1, default: 0]
        self.z = coords[2, default: 0]
    }

    init(_ x: Int, _ y: Int, _ z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }
}

private struct Position4D: Position, Equatable, Hashable {
    static var dimensions: [KeyPath<Position4D, Int>] { [\.x, \.y, \.z, \.w] }

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

        self.x = coords[0, default: 0]
        self.y = coords[1, default: 0]
        self.z = coords[2, default: 0]
        self.w = coords[3, default: 0]
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
