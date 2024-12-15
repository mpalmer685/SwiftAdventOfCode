import AOCKit

struct WarehouseWoes: Puzzle {
    static let day = 15

    func part1(input: Input) throws -> Int {
        var (simulation, instructions) = StandardWarehouse.parse(input)
        simulation.execute(instructions)
        return simulation.gpsCoordinates
    }

    func part2(input: Input) throws -> Int {
        let expanded = input.raw
            .replacingOccurrences(of: ".", with: "..")
            .replacingOccurrences(of: "#", with: "##")
            .replacingOccurrences(of: "O", with: "[]")
            .replacingOccurrences(of: "@", with: "@.")
        var (simulation, instructions) = WideWarehouse.parse(Input(expanded))
        simulation.execute(instructions)
        return simulation.gpsCoordinates
    }
}

private protocol Warehouse {
    associatedtype Tile: RawRepresentable where Tile.RawValue == Character

    init(map: Grid<Tile>)

    var start: Point2D { get }
    var boxPositions: [Point2D] { get }

    mutating func moveRobot(at position: Point2D, along direction: Vector2D) -> Bool
}

extension Warehouse {
    static func parse(_ input: Input) -> (warehouse: Self, instructions: [Vector2D]) {
        let sections = input.lines.split(whereSeparator: \.isEmpty)
        assert(sections.count == 2)

        let warehouse = Self(map: Grid(data: sections[0].characters) { Tile(rawValue: $0)! })
        let instructions = sections[1].characters.flattened.map { Vector2D.from($0) }

        return (warehouse, instructions)
    }

    mutating func execute(_ instructions: [Vector2D]) {
        _ = instructions.reduce(start) { position, direction in
            moveRobot(at: position, along: direction)
                ? position + direction
                : position
        }
    }

    var gpsCoordinates: Int {
        boxPositions.sum { 100 * $0.y + $0.x }
    }
}

private class WideWarehouse: Warehouse {
    fileprivate enum Tile: Character {
        case wall = "#"
        case floor = "."
        case boxLeft = "["
        case boxRight = "]"
        case robot = "@"
    }

    private var map: Grid<Tile>

    required init(map: Grid<Tile>) {
        self.map = map
    }

    var boxPositions: [Point2D] {
        map.points.filter { map[$0] == .boxLeft }
    }

    var start: Point2D {
        map.points.first(where: { map[$0] == .robot })!
    }

    func moveRobot(at position: Point2D, along direction: Vector2D) -> Bool {
        move(from: position, along: direction, update: true)
    }

    private func move(
        from position: Point2D,
        along direction: Vector2D,
        update: Bool = false
    ) -> Bool {
        let destination = position + direction

        if map[position] == .floor {
            return true
        }
        if map[position] == .wall {
            return false
        }
        if direction.isHorizontal {
            let canMove = move(from: destination, along: direction)
            if canMove {
                swap(position, destination)
            }
            return canMove
        }
        if map[position] == .robot {
            let canMove = move(from: destination, along: direction, update: update)
            if canMove {
                swap(position, destination)
            }
            return canMove
        }
        if map[position] == .boxRight {
            return move(from: position - .x, along: direction, update: update)
        }

        return moveBox(at: position, along: direction, update: update)
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func moveBox(
        at position: Point2D,
        along direction: Vector2D,
        update: Bool = false
    ) -> Bool {
        let destination = position + direction
        switch (map[destination], map[destination + .x]) {
            case (.floor, .floor):
                if update {
                    swap(position, destination)
                    swap(position + .x, destination + .x)
                }
                return true
            case (.boxLeft, .boxRight):
                let canMove = move(from: destination, along: direction)
                if canMove, update {
                    return move(from: destination, along: direction, update: true)
                        && move(from: position, along: direction, update: true)
                }
                return canMove
            case (.boxRight, .floor):
                let canMove = move(from: destination - .x, along: direction)
                if canMove, update {
                    return move(from: destination - .x, along: direction, update: true)
                        && move(from: position, along: direction, update: true)
                }
                return canMove
            case (.floor, .boxLeft):
                let canMove = move(from: destination + .x, along: direction)
                if canMove, update {
                    return move(from: destination + .x, along: direction, update: true)
                        && move(from: position, along: direction, update: true)
                }
                return canMove
            case (.boxRight, .boxLeft):
                let canMove = move(from: destination - .x, along: direction)
                    && move(from: destination + .x, along: direction)
                if canMove, update {
                    return move(from: destination - .x, along: direction, update: true)
                        && move(from: destination + .x, along: direction, update: true)
                        && move(from: position, along: direction, update: true)
                }
                return canMove
            default:
                return false
        }
    }

    private func swap(_ a: Point2D, _ b: Point2D) {
        (map[a], map[b]) = (map[b], map[a])
    }
}

private class StandardWarehouse: Warehouse {
    fileprivate enum Tile: Character {
        case wall = "#"
        case floor = "."
        case box = "O"
        case robot = "@"
    }

    private var map: Grid<Tile>

    required init(map: Grid<Tile>) {
        self.map = map
    }

    var boxPositions: [Point2D] {
        map.points.filter { map[$0] == .box }
    }

    var start: Point2D {
        map.points.first(where: { map[$0] == .robot })!
    }

    func moveRobot(at position: Point2D, along direction: Vector2D) -> Bool {
        var boxes = [Point2D]()
        var p = position + direction
        search: while map.contains(p) {
            switch map[p] {
                case .wall, .floor: break search
                case .box:
                    boxes.append(p)
                    p += direction
                case .robot: fatalError("Robot already at \(p)")
            }
        }
        guard map.contains(p), map[p] != .wall else { return false }

        for box in boxes {
            map[box + direction] = .box
        }

        let nextPosition = position + direction
        map[nextPosition] = .robot
        map[position] = .floor

        return true
    }
}

private extension Vector2D {
    static func from(_ character: Character) -> Self {
        switch character {
            case "^": -.y
            case "v": .y
            case "<": -.x
            case ">": .x
            default: fatalError("Invalid character: \(character)")
        }
    }

    var isHorizontal: Bool { dy == 0 }
}

extension WarehouseWoes: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .init(input: .example("small"), part1: 2028),
            .init(input: .example("large"), part1: 10092, part2: 9021),
        ]
    }
}
