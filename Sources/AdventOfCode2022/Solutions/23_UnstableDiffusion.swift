import AOCKit

private typealias Point = Point2D
private typealias Direction = Vector2D

class UnstableDiffusion: Puzzle {
    static let day = 23

    private lazy var elves: Set<Point2D> = {
        var elves = Set<Point2D>()
        for (y, line) in input().lines.characters.enumerated() {
            for (x, c) in line.enumerated() where c == "#" {
                elves.insert(.init(x, y))
            }
        }
        return elves
    }()

    private let decisions: [Decision] = [
        (.north, [.north, .northeast, .northwest]),
        (.south, [.south, .southeast, .southwest]),
        (.west, [.west, .northwest, .southwest]),
        (.east, [.east, .northeast, .southeast]),
    ]

    func part1() throws -> Int {
        var elves = elves
        var decisions = decisions

        for _ in 0 ..< 10 {
            elves = move(elves, using: decisions)
            decisions.rotate(toStartAt: 1)
        }

        return elves.bounds.area - elves.count
    }

    func part2() throws -> Int {
        var elves = elves
        var decisions = decisions

        for round in 1 ... Int.max {
            let next = move(elves, using: decisions)
            if next == elves {
                return round
            }

            elves = next
            decisions.rotate(toStartAt: 1)
        }

        fatalError("No solution found")
    }

    private func move(_ elves: Set<Point2D>, using decisions: [Decision]) -> Set<Point2D> {
        var plannedMoves = [Point2D: Point2D]()
        let orderedElves = elves.sorted { l, r -> Bool in
            if l.x == r.x {
                return l.y < r.y
            }
            return l.x < r.x
        }
        for elf in orderedElves {
            if !elf.hasNeighbors(in: elves) {
                plannedMoves[elf] = elf
            } else if let (v, _) = decisions
                .first(where: { !elf.hasNeighbor(in: elves, checking: $1) })
            {
                let dest = elf + v
                if let collision = plannedMoves[dest] {
                    // At most, two different elves could plan to move into the same position
                    // (from opposite directions). So if this elf's destination has already been
                    // picked by another elf, we don't need to worry about any remaining elves
                    // wanting to move there and we can safely delete the entry from the Dictionary.
                    plannedMoves.removeValue(forKey: dest)
                    plannedMoves[collision] = collision
                    plannedMoves[elf] = elf
                } else {
                    plannedMoves[dest] = elf
                }
            } else {
                plannedMoves[elf] = elf
            }
        }

        return Set(plannedMoves.keys)
    }
}

typealias Decision = (Vector2D, [Vector2D])

private extension Vector2D {
    static var north: Self { .init(dx: 0, dy: -1) }
    static var south: Self { .init(dx: 0, dy: 1) }
    static var east: Self { .init(dx: 1, dy: 0) }
    static var west: Self { .init(dx: -1, dy: 0) }

    static var northeast: Self { .north + .east }
    static var northwest: Self { .north + .west }
    static var southeast: Self { .south + .east }
    static var southwest: Self { .south + .west }
}

private extension Point2D {
    var allNeighbors: [Self] {
        let vectors = (-1 ... 1).flatMap { dx in (-1 ... 1).map { dy in Vector(dx, dy) } }
            .reject { $0.dx == 0 && $0.dy == 0 }
        return vectors.map { apply($0) }
    }

    func hasNeighbors<C: Collection>(in collection: C) -> Bool where C.Element == Self {
        allNeighbors.contains(where: { collection.contains($0) })
    }

    func hasNeighbor<C: Collection>(in collection: C, checking vectors: [Vector]) -> Bool
        where C.Element == Self
    {
        vectors.contains(where: { collection.contains(self + $0) })
    }
}

private struct Rect {
    let xMin: Int
    let xMax: Int
    let yMin: Int
    let yMax: Int

    var area: Int { (xMax - xMin + 1) * (yMax - yMin + 1) }
}

private extension Set where Element == Point2D {
    var bounds: Rect {
        Rect(xMin: min(of: \.x)!, xMax: max(of: \.x)!, yMin: min(of: \.y)!, yMax: max(of: \.y)!)
    }
}
