import AOCKit

struct TreetopTreeHouse: Puzzle {
    static let day = 8

    func part1() throws -> Int {
        let trees = Grid(input().lines.digits)

        func isVisible(at position: Grid<Int>.Point, moving direction: Heading) -> Bool {
            let height = trees[position]
            var current = position

            while trees.contains(current) {
                let next = current.offsetBy(direction.dx, direction.dy)
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
            directions.contains { isVisible(at: point, moving: $0) }
        }
    }

    func part2() throws -> Int {
        let trees = Grid(input().lines.digits)

        func countVisibleTrees(from position: Grid<Int>.Point, moving direction: Heading) -> Int {
            let height = trees[position]
            var count = 0
            var current = position.offsetBy(direction.dx, direction.dy)

            while trees.contains(current) {
                count += 1
                if trees[current] >= height { break }
                current = current.offsetBy(direction.dx, direction.dy)
            }

            return count
        }

        return trees.points.map { point in
            directions.map { countVisibleTrees(from: point, moving: $0) }.product
        }.max()!
    }
}

private typealias Heading = (dx: Int, dy: Int)

private let up: Heading = (0, -1)
private let down: Heading = (0, 1)
private let left: Heading = (-1, 0)
private let right: Heading = (1, 0)
private let directions = [up, down, left, right]
