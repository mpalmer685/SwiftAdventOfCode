import AOCKit

struct RopeBridge: Puzzle {
    static let day = 9

    func part1(input: Input) throws -> Int {
        moveRope(ofLength: 2, using: input)
    }

    func part2(input: Input) throws -> Int {
        moveRope(ofLength: 10, using: input)
    }

    private func moveRope(ofLength length: Int, using input: Input) -> Int {
        var rope = Array(repeating: Point2D.zero, count: length)
        var tailVisited = Set([rope.last!])

        for words in input.lines.words {
            let direction = Vector2D.from(words[0].raw)
            let count = words[1].integer!

            for _ in 0 ..< count {
                rope[0] = rope[0] + direction

                for (lead, follow) in rope.indices.adjacentPairs() {
                    if rope[lead].touches(rope[follow]) { continue }
                    rope[follow] += rope[follow].vector(towards: rope[lead]).unit
                }

                tailVisited.insert(rope.last!)
            }
        }

        return tailVisited.count
    }
}

private extension Point2D {
    func touches(_ other: Self) -> Bool {
        abs(other.x - x) <= 1 && abs(other.y - y) <= 1
    }
}

private extension Vector2D {
    static let down: Self = .y
    static let up: Self = -.y
    static let left: Self = -.x
    static let right: Self = .x

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
