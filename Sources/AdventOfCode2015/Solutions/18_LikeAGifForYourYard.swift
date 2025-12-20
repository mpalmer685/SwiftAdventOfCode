import AOCKit

struct LikeAGifForYourYard: Puzzle {
    static let day = 18

    func part1(input: Input) async throws -> Int {
        var litPoints = parseGrid(from: input)
        for _ in 1 ... 100 {
            litPoints = litPoints.nextFrame()
        }
        return litPoints.count
    }

    func part2(input: Input) async throws -> Int {
        var litPoints = parseGrid(from: input)
        let cornerPoints: Set<Point2D> = [
            Point2D(x: 0, y: 0),
            Point2D(x: 0, y: 99),
            Point2D(x: 99, y: 0),
            Point2D(x: 99, y: 99),
        ]
        litPoints.formUnion(cornerPoints)

        for _ in 1 ... 100 {
            litPoints = litPoints.nextFrame()
            litPoints.formUnion(cornerPoints)
        }
        return litPoints.count
    }

    private func parseGrid(from input: Input) -> Set<Point2D> {
        let characters = input.lines.characters
        var litPoints = Set<Point2D>()
        for (y, line) in characters.enumerated() {
            for (x, char) in line.enumerated() where char == "#" {
                litPoints.insert(Point2D(x: x, y: y))
            }
        }

        return litPoints
    }
}

private extension Set<Point2D> {
    func nextFrame() -> Self {
        var nextFrame = Self()
        for y in 0 ..< 100 {
            for x in 0 ..< 100 {
                let point = Point2D(x, y)
                let litNeighbors = point.neighbors.count(where: { contains($0) })
                if (contains(point) && (2 ... 3).contains(litNeighbors)) ||
                    (!contains(point) && litNeighbors == 3)
                {
                    nextFrame.insert(point)
                }
            }
        }
        return nextFrame
    }
}
