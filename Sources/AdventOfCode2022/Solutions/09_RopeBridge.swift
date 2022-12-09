import AOCKit

struct RopeBridge: Puzzle {
    static let day = 9

    func part1() throws -> Int {
        moveRope(ofLength: 2)
    }

    func part2() throws -> Int {
        moveRope(ofLength: 10)
    }

    private func moveRope(ofLength length: Int) -> Int {
        var rope = Array(repeating: Point2D.zero, count: length)
        var tailVisited = Set([rope.last!])

        for words in input().lines.words {
            let direction = Vector2D.from(words[0].raw)
            let count = words[1].integer!

            for _ in 0 ..< count {
                rope[0] = rope[0] + direction

                for (lead, follow) in rope.indices.adjacentPairs() {
                    if rope[lead].touches(rope[follow]) { continue }
                    let delta = rope[lead] - rope[follow]
                    rope[follow] += delta.unit
                }

                tailVisited.insert(rope.last!)
            }
        }

        return tailVisited.count
    }
}

private struct Point2D: Hashable {
    static let zero = Self(x: 0, y: 0)

    var x: Int
    var y: Int

    func touches(_ other: Self) -> Bool {
        abs(other.x - x) <= 1 && abs(other.y - y) <= 1
    }

    static func + (lhs: Self, rhs: Vector2D) -> Self {
        Self(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy)
    }

    static func += (lhs: inout Self, rhs: Vector2D) {
        lhs.x += rhs.dx
        lhs.y += rhs.dy
    }

    static func - (lhs: Self, rhs: Self) -> Vector2D {
        Vector2D(dx: lhs.x - rhs.x, dy: lhs.y - rhs.y)
    }
}

extension Point2D: CustomStringConvertible {
    var description: String { "(\(x), \(y))" }
}

private struct Vector2D: Hashable {
    static let zero = Self(dx: 0, dy: 0)

    static let down = Self(dx: 0, dy: 1)
    static let up = Self(dx: 0, dy: -1)
    static let left = Self(dx: -1, dy: 0)
    static let right = Self(dx: 1, dy: 0)

    let dx: Int
    let dy: Int

    var unit: Self {
        Self(dx: dx == 0 ? 0 : dx / abs(dx), dy: dy == 0 ? 0 : dy / abs(dy))
    }

    static func from(_ input: String) -> Self {
        switch input {
            case "D": return .down
            case "U": return .up
            case "L": return .left
            case "R": return .right
            default: fatalError("Unknown direction input \(input)")
        }
    }
}
