import AOCKit

class RegolithReservoir: Puzzle {
    static let day = 14

    private lazy var cave: Cave = {
        var cave = Cave()

        for line in input().lines {
            let positions = line.words(separatedBy: " -> ")
            for (start, end) in positions.adjacentPairs() {
                let start = Position(start)
                let end = Position(end)

                for p in start ... end {
                    cave[p] = .wall
                }
            }
        }

        return cave
    }()

    func part1() throws -> Int {
        let start = Position(500, 0)

        func dropSand(into cave: inout Cave, floor: Int) -> Bool {
            var s = start

            while true {
                // straight down
                while cave[s] == nil, s.y <= floor {
                    s = s.move(.down)
                }
                // move back up 1 to the empty spot
                s = s.move(.up)

                if s.y >= floor {
                    return false
                }

                let downLeft = s.move(.down).move(.left)
                let downRight = s.move(.down).move(.right)

                if cave[downLeft] == nil {
                    s = downLeft
                } else if cave[downRight] == nil {
                    s = downRight
                } else {
                    cave[s] = .sand
                    return true
                }
            }
        }

        var cave = cave
        let floor = cave.maxY

        var count = 0
        while dropSand(into: &cave, floor: floor) {
            count += 1
        }

        return count
    }

    func part2() throws -> Int {
        let start = Position(500, 0)

        func dropSand(into cave: inout Cave, floor: Int) {
            var s = start

            while true {
                // straight down
                while cave[s] == nil, s.y < floor {
                    s = s.move(.down)
                }
                // move back up 1 to the empty spot
                s = s.move(.up)

                let downLeft = s.move(.down).move(.left)
                let downRight = s.move(.down).move(.right)

                if cave[downLeft] == nil, downLeft.y < floor {
                    s = downLeft
                } else if cave[downRight] == nil, downRight.y < floor {
                    s = downRight
                } else {
                    cave[s] = .sand
                    break
                }
            }
        }

        var cave = cave
        let floor = cave.maxY + 2

        let source = Position(500, 0)

        var count = 0
        while cave[source] == nil {
            dropSand(into: &cave, floor: floor)
            count += 1
        }

        return count
    }
}

private typealias Cave = [Position: CaveElement]
private typealias Position = Grid<Any>.Point

private enum CaveElement {
    case wall, sand
}

private extension Position {
    init(_ word: Word) {
        let parts = word.words(separatedBy: .comma)
        let x = parts[0].integer!
        let y = parts[1].integer!
        self.init(x, y)
    }

    func move(_ dir: Direction) -> Self {
        Self(x + dir.dx, y + dir.dy)
    }

    static func ... (lhs: Self, rhs: Self) -> [Self] {
        var points = [Self]()

        // This only works for this specific puzzle, where either dx or dy is guaranteed to be zero
        for x in min(lhs.x, rhs.x) ... max(lhs.x, rhs.x) {
            for y in min(lhs.y, rhs.y) ... max(lhs.y, rhs.y) {
                points.append(Self(x, y))
            }
        }

        return points
    }
}

private struct Direction {
    let dx: Int
    let dy: Int

    static let up = Direction(dx: 0, dy: -1)
    static let down = Direction(dx: 0, dy: 1)
    static let left = Direction(dx: -1, dy: 0)
    static let right = Direction(dx: 1, dy: 0)
}

private extension Dictionary where Key == Position {
    var minX: Int { keys.map(\.x).min()! }
    var maxX: Int { keys.map(\.x).max()! }

    var minY: Int { keys.map(\.y).min()! }
    var maxY: Int { keys.map(\.y).max()! }
}