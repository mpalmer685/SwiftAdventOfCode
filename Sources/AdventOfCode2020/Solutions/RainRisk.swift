import AOCKit
import Foundation

struct RainRisk: Puzzle {
    static let day = 12

    func part1() throws -> Int {
        let instructions = input().lines.raw.map(Instruction.init)
        let state = ShipState()
        instructions.forEach(state.execute)
        return state.manhattanDistance
    }

    func part2() throws -> Int {
        let instructions = input().lines.raw.map(Instruction.init)
        let state = WaypointShipState()
        instructions.forEach(state.execute)
        return state.manhattanDistance
    }
}

private protocol State {
    var x: Int { get }
    var y: Int { get }

    func execute(instruction: Instruction)
}

extension State {
    var manhattanDistance: Int { abs(x) + abs(y) }
}

private class ShipState: State, CustomDebugStringConvertible {
    var x: Int = 0
    var y: Int = 0
    var facing: Facing = .east

    func execute(instruction: Instruction) {
        if case let .turn(direction, degrees) = instruction {
            facing = facing.turned(direction, by: degrees)
        } else {
            let (dx, dy) = instruction.displacement(facing: facing)
            x += dx
            y += dy
        }
    }

    var debugDescription: String { "(\(x), \(y)) facing \(facing)" }
}

private class WaypointShipState: State, CustomDebugStringConvertible {
    var x: Int = 0
    var y: Int = 0
    var waypoint: Displacement = (10, 1)

    func execute(instruction: Instruction) {
        switch instruction {
            case let .forward(distance):
                let (dx, dy) = waypoint * distance
                x += dx
                y += dy
            case let .turn(direction, degrees):
                waypoint = rotate(waypoint, by: degrees * direction.rawValue)
            default:
                let displacement = instruction.displacement(facing: .east)
                waypoint += displacement
        }
    }

    var debugDescription: String { "Ship: (\(x), \(y)) Waypoint: (\(waypoint.dx), \(waypoint.dy))" }
}

private typealias Displacement = (dx: Int, dy: Int)

private enum Direction: Int {
    case left = 1,
         right = -1
}

private enum Facing: Int {
    case east = 0,
         north = 90,
         west = 180,
         south = 270

    var unitDisplacement: Displacement {
        switch self {
            case .east: return (1, 0)
            case .west: return (-1, 0)
            case .north: return (0, 1)
            case .south: return (0, -1)
        }
    }

    func turned(_ direction: Direction, by amount: Int) -> Facing {
        let degrees = 360 + rawValue + (amount * direction.rawValue)
        guard let turned = Facing(rawValue: degrees % 360) else {
            fatalError("Invalid facing \(degrees % 360)")
        }
        return turned
    }
}

extension Facing: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
            case .east: return "east"
            case .west: return "west"
            case .north: return "north"
            case .south: return "south"
        }
    }
}

private enum Instruction {
    case north(distance: Int)
    case south(distance: Int)
    case east(distance: Int)
    case west(distance: Int)
    case turn(direction: Direction, degrees: Int)
    case forward(distance: Int)

    var isTurn: Bool {
        if case .turn = self {
            return true
        }
        return false
    }

    init(_ string: String) {
        let action = string.first!
        let valueString = String(string[string.index(string.startIndex, offsetBy: 1)...])
        let value = Int(valueString)!

        switch action {
            case "N":
                self = .north(distance: value)
            case "S":
                self = .south(distance: value)
            case "E":
                self = .east(distance: value)
            case "W":
                self = .west(distance: value)
            case "F":
                self = .forward(distance: value)
            case "L":
                self = .turn(direction: .left, degrees: value)
            case "R":
                self = .turn(direction: .right, degrees: value)
            default:
                fatalError("Invalid instruction \(string)")
        }
    }

    func displacement(facing: Facing) -> Displacement {
        switch self {
            case let .north(distance): return (0, distance)
            case let .south(distance): return (0, -distance)
            case let .east(distance): return (distance, 0)
            case let .west(distance): return (-distance, 0)
            case let .forward(distance): return facing.unitDisplacement * distance
            case .turn: return (0, 0)
        }
    }
}

extension Instruction: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
            case let .north(value): return "N\(value)"
            case let .south(value): return "S\(value)"
            case let .east(value): return "E\(value)"
            case let .west(value): return "W\(value)"
            case let .forward(distance): return "F\(distance)"
            case let .turn(direction, degrees):
                switch direction {
                    case .left: return "L\(degrees)"
                    case .right: return "R\(degrees)"
                }
        }
    }
}

private func rotate(_ point: Displacement, by degrees: Int) -> Displacement {
    let cosine = cos(degrees: degrees)
    let sine = sin(degrees: degrees)

    return (point.dx * cosine - point.dy * sine, point.dx * sine + point.dy * cosine)
}

private func cos(degrees: Int) -> Int {
    switch (360 + degrees) % 360 {
        case 0: return 1
        case 180: return -1
        case 90, 270: return 0
        default: fatalError()
    }
}

private func sin(degrees: Int) -> Int {
    switch (360 + degrees) % 360 {
        case 90: return 1
        case 270: return -1
        case 0, 180: return 0
        default: fatalError()
    }
}

private func * (lhs: Displacement, rhs: Int) -> Displacement {
    (lhs.dx * rhs, lhs.dy * rhs)
}

private func += (lhs: inout Displacement, rhs: Displacement) {
    lhs.dx += rhs.dx
    lhs.dy += rhs.dy
}
