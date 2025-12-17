import AOCKit

struct ProbablyAFireHazard: Puzzle {
    static let day = 6

    func part1(input: Input) async throws -> Int {
        let instructions = input.lines.raw.map(Instruction.init)
        var grid = [Point2D: Bool]()
        for instruction in instructions {
            switch instruction {
                case let .turnOn(start, end):
                    for point in Point2D.allPoints(from: start, to: end) {
                        grid[point] = true
                    }
                case let .turnOff(start, end):
                    for point in Point2D.allPoints(from: start, to: end) {
                        grid[point] = false
                    }
                case let .toggle(start, end):
                    for point in Point2D.allPoints(from: start, to: end) {
                        grid[point, default: false].toggle()
                    }
            }
        }
        return grid.values.count(where: \.isTrue)
    }

    func part2(input: Input) async throws -> Int {
        let instructions = input.lines.raw.map(Instruction.init)
        var grid = [Point2D: Int]()
        for instruction in instructions {
            switch instruction {
                case let .turnOn(start, end):
                    for point in Point2D.allPoints(from: start, to: end) {
                        grid[point, default: 0] += 1
                    }
                case let .turnOff(start, end):
                    for point in Point2D.allPoints(from: start, to: end) {
                        grid[point] = max(0, grid[point, default: 0] - 1)
                    }
                case let .toggle(start, end):
                    for point in Point2D.allPoints(from: start, to: end) {
                        grid[point, default: 0] += 2
                    }
            }
        }
        return grid.sum(of: \.value)
    }
}

private enum Instruction {
    case turnOn(start: Point2D, end: Point2D)
    case turnOff(start: Point2D, end: Point2D)
    case toggle(start: Point2D, end: Point2D)

    init(from line: String) {
        var scanner = Scanner(line)
        if scanner.starts(with: "turn on") {
            scanner.skip("turn on ")
            guard let start = scanner.scanPoint2D() else {
                fatalError("Invalid instruction: \(line)")
            }
            scanner.expect(" through ")
            guard let end = scanner.scanPoint2D() else {
                fatalError("Invalid instruction: \(line)")
            }
            self = .turnOn(start: start, end: end)
        } else if scanner.starts(with: "turn off") {
            scanner.skip("turn off ")
            guard let start = scanner.scanPoint2D() else {
                fatalError("Invalid instruction: \(line)")
            }
            scanner.expect(" through ")
            guard let end = scanner.scanPoint2D() else {
                fatalError("Invalid instruction: \(line)")
            }
            self = .turnOff(start: start, end: end)
        } else if scanner.starts(with: "toggle") {
            scanner.skip("toggle ")
            guard let start = scanner.scanPoint2D() else {
                fatalError("Invalid instruction: \(line)")
            }
            scanner.expect(" through ")
            guard let end = scanner.scanPoint2D() else {
                fatalError("Invalid instruction: \(line)")
            }
            self = .toggle(start: start, end: end)
        } else {
            fatalError("Invalid instruction: \(line)")
        }
    }
}

private extension Scanner where C.Element == Character {
    mutating func scanPoint2D() -> Point2D? {
        guard let x = scanInt() else { return nil }
        expect(",")
        guard let y = scanInt() else { return nil }
        return Point2D(x: x, y: y)
    }
}

private extension Bool {
    var isTrue: Bool { self == true }
}

private extension Point2D {
    static func allPoints(from start: Self, to end: Self) -> [Self] {
        (start.x ... end.x).flatMap { x in
            (start.y ... end.y).map { y in
                Point2D(x: x, y: y)
            }
        }
    }
}
