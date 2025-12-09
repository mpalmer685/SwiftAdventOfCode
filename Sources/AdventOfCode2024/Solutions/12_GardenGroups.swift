import AOCKit

struct GardenGroups: Puzzle {
    static let day = 12

    func part1(input: Input) throws -> Int {
        GardenMap(input).totalPrice
    }

    func part2(input: Input) throws -> Int {
        GardenMap(input).totalPriceWithBulkDiscount
    }
}

private struct GardenMap {
    private let map: Grid<Character>
    private let regions: [Region]

    init(_ input: Input) {
        map = Grid(input.lines.characters)
        regions = RegionMapper(map).findRegions()
    }

    var totalPrice: Int {
        regions.sum(of: \.price)
    }

    var totalPriceWithBulkDiscount: Int {
        regions.sum(of: \.priceWithDiscount)
    }
}

private struct Region {
    let points: Set<Point2D>

    var price: Int { area * perimeter }

    var priceWithDiscount: Int { area * points.sum { countCorners(at: $0) } }

    var area: Int { points.count }

    var perimeter: Int {
        points.sum { point in
            point.orthogonalNeighbors.count { !points.contains($0) }
        }
    }

    private func countCorners(at point: Point2D) -> Int {
        let cornerOffsets: [(Vector2D, Vector2D)] = [
            (.north, .west),
            (.north, .east),
            (.south, .west),
            (.south, .east),
        ]
        return cornerOffsets.count { offsetA, offsetB in
            let sideA = point + offsetA
            let sideB = point + offsetB
            let diagonal = point + offsetA + offsetB

            let isConvexCorner = !points.contains(sideA) && !points.contains(sideB)
            let isConcaveCorner = points.contains(sideA)
                && points.contains(sideB)
                && !points.contains(diagonal)

            return isConvexCorner || isConcaveCorner
        }
    }
}

private struct RegionMapper: Graph {
    private let map: Grid<Character>

    init(_ map: Grid<Character>) {
        self.map = map
    }

    func findRegions() -> [Region] {
        var regions: [Region] = []
        var visited: Set<Point2D> = []

        for point in map.points where !visited.contains(point) {
            var region: Set<Point2D> = []
            breadthFirstTraverse(from: point) { node in
                region.insert(node)
                visited.insert(node)
            }
            regions.append(Region(points: region))
        }

        return regions
    }

    func neighbors(of node: Point2D) -> [Point2D] {
        node.orthogonalNeighbors.filter { neighbor in
            map.contains(neighbor) && map[neighbor] == map[node]
        }
    }
}

private extension Vector2D {
    static let north = Vector2D(dx: 0, dy: -1)
    static let south = Vector2D(dx: 0, dy: 1)
    static let east = Vector2D(dx: 1, dy: 0)
    static let west = Vector2D(dx: -1, dy: 0)
}

extension GardenGroups: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.file("example1")).expects(part1: 140, part2: 80),
            .given(.file("example2")).expects(part1: 772, part2: 436),
            .given(.file("example3")).expects(part1: 1930, part2: 1206),
            .given(.file("example4")).expects(part2: 236),
            .given(.file("example5")).expects(part2: 368),
        ]
    }
}
