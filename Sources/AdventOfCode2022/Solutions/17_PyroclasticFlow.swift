import AOCKit

class PyroclasticFlow: Puzzle {
    static let day = 17

    private lazy var winds: [Direction] = {
        input().characters.map(Direction.init(character:))
    }()

    func part1() throws -> Int {
        let shaft = Shaft(width: 7)
        var winds = winds.cycled().makeIterator()

        for rock in Rock.order.cycled().prefix(2022) {
            drop(rock, in: shaft) { winds.next()! }
        }

        return shaft.maxY
    }

    func part2() throws -> Int {
        struct Key: Hashable {
            let skyline: [Int]
            let windIndex: Int
            let rockIndex: Int
        }

        let rocksToDrop = 1_000_000_000_000
        let shaft = Shaft(width: 7)

        var rocks = Rock.order.cycled().makeIterator()
        var winds = winds.cycled().makeIterator()

        var windIndex = 0
        var seen = [Key: (Int, Int)]()

        for r in 1 ... rocksToDrop {
            drop(rocks.next()!, in: shaft) {
                windIndex += 1
                return winds.next()!
            }

            let key = Key(
                skyline: shaft.skyline,
                windIndex: windIndex % self.winds.count,
                rockIndex: (r - 1) % Rock.order.count
            )
            guard let (start, height) = seen[key] else {
                if r % 10000 == 0 { print("No cycles found after \(r) rocks dropped") }
                seen[key] = (r, shaft.maxY)
                continue
            }

            let heightGain = shaft.maxY - height
            let cycleLength = r - start
            let cycles = (rocksToDrop - start) / cycleLength
            let remainder = (rocksToDrop - start) - (cycles * cycleLength)

            for _ in 0 ..< remainder {
                drop(rocks.next()!, in: shaft) { winds.next()! }
            }

            return shaft.maxY + ((cycles - 1) * heightGain)
        }

        fatalError("No solution found")
    }

    private func drop(_ rock: Rock, in shaft: Shaft, using nextWind: () -> Direction) {
        let start = Direction(2, shaft.maxY + 4)

        var rock = rock.move(start)

        var falling = true
        while falling {
            let movedByWind = rock.move(nextWind())
            if shaft.canPlace(movedByWind) {
                rock = movedByWind
            }

            let movedDown = rock.move(.down)
            if shaft.canPlace(movedDown) {
                rock = movedDown
            } else {
                falling = false
            }
        }
        shaft.place(rock)
    }
}

private class Shaft {
    var space: Set<Point>

    let width: Int

    private var columnHeights: [Int]

    var maxY: Int {
        columnHeights.max()!
    }

    var skyline: [Int] {
        columnHeights.normalized
    }

    init(width: Int) {
        self.width = width
        columnHeights = Array(repeating: 0, count: width)

        space = []
        for x in 0 ..< width {
            space.insert(Point(x, 0))
        }
    }

    func canPlace(_ rock: Rock) -> Bool {
        !rock.points.contains { space.contains($0) || $0.x < 0 || $0.x >= width }
    }

    func place(_ rock: Rock) {
        space.formUnion(rock.points)
        for p in rock.points {
            columnHeights[p.x] = max(columnHeights[p.x], p.y)
        }
    }
}

private typealias Point = Grid<Any>.Point

private struct Rock {
    let points: [Point]

    func move(_ dir: Direction) -> Self {
        Self(points: points.map { $0.offsetBy(dir.dx, dir.dy) })
    }

    static let order = [hLine, plus, l, vLine, square]

    static let hLine = Rock(points: [.init(0, 0), .init(1, 0), .init(2, 0), .init(3, 0)])
    static let vLine = Rock(points: [.init(0, 0), .init(0, 1), .init(0, 2), .init(0, 3)])
    static let plus = Rock(points: [
        .init(1, 0),
        .init(0, 1), .init(1, 1), .init(2, 1),
        .init(1, 2),
    ])
    static let l = Rock(points: [
        .init(0, 0), .init(1, 0), .init(2, 0),
        .init(2, 1),
        .init(2, 2),
    ])
    static let square = Rock(points: [
        .init(0, 0), .init(1, 0),
        .init(0, 1), .init(1, 1),
    ])
}

private struct Direction {
    let dx: Int
    let dy: Int

    init(_ dx: Int, _ dy: Int) {
        self.dx = dx
        self.dy = dy
    }

    init(character: Character) {
        switch character {
            case "<":
                self = .left
            case ">":
                self = .right
            default:
                fatalError("Unknown character \(character)")
        }
    }

    static let up = Self(0, 1)
    static let down = Self(0, -1)
    static let left = Self(-1, 0)
    static let right = Self(1, 0)
}

extension Direction: CustomStringConvertible {
    public var description: String {
        "<\(dx), \(dy)>"
    }
}

private extension Collection where Element: Numeric, Element: Comparable {
    var normalized: [Element] {
        let min = self.min()!
        return map { $0 - min }
    }
}
