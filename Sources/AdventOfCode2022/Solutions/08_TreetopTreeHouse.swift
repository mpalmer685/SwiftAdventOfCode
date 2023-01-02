import AOCKit

struct TreetopTreeHouse: Puzzle {
    static let day = 8

    func part1() throws -> Int {
        let trees = Grid(input().lines.digits)

        func isVisible(at position: Point2D, moving direction: Vector2D) -> Bool {
            let height = trees[position]
            var current = position

            while trees.contains(current) {
                let next = current.offset(by: direction)
                if !trees.contains(next) {
                    return true
                }

                let nextHeight = trees[next]
                if nextHeight >= height {
                    return false
                }

                current = next
            }

            return true
        }

        return trees.points.count { point in
            Vector2D.directions.contains { isVisible(at: point, moving: $0) }
        }
    }

    func part2() throws -> Int {
        let trees = Grid(input().lines.digits)

        func countVisibleTrees(from position: Point2D, moving direction: Vector2D) -> Int {
            let height = trees[position]
            var count = 0
            var current = position.offset(by: direction)

            while trees.contains(current) {
                count += 1
                if trees[current] >= height { break }
                current = current.offset(by: direction)
            }

            return count
        }

        return trees.points.max { point in
            Vector2D.directions.map { countVisibleTrees(from: point, moving: $0) }.product
        }!
    }
}

private extension Vector2D {
    static var up: Self { -.y }
    static var down: Self { .y }
    static var left: Self { -.x }
    static var right: Self { .x }

    static var directions: [Self] { [.up, .down, .left, .right] }
}
