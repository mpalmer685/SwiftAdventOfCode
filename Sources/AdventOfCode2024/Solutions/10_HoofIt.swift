import AOCKit

struct HoofIt: Puzzle {
    static let day = 10

    func part1(input: Input) throws -> Int {
        let map = TopographicScoreMap(input: input)
        return map.trailheads.sum { start in
            map.trailScore(startingAt: start)
        }
    }

    func part2(input: Input) throws -> Int {
        let map = TopographicRatingMap(input: input)
        return map.trailheads.sum { start in
            map.trailRating(startingAt: start)
        }
    }
}

private protocol TopographicMap {
    var map: Grid<Int> { get }
    init(map: Grid<Int>)
}

extension TopographicMap {
    init(input: Input) {
        self.init(map: Grid(input.lines.digits))
    }

    var trailheads: [Point2D] {
        map.points.filter { map[$0] == 0 }
    }
}

private struct TopographicScoreMap: TopographicMap {
    let map: Grid<Int>

    func trailScore(startingAt start: Point2D) -> Int {
        nodesAccessible(from: start).values.count(of: 9)
    }
}

extension TopographicScoreMap: Graph {
    func neighbors(of point: Point2D) -> [Point2D] {
        let currentHeight = map[point]
        return point.orthogonalNeighbors.filter { neighbor in
            map.contains(neighbor) && map[neighbor] == currentHeight + 1
        }
    }
}

private struct TopographicRatingMap: TopographicMap {
    let map: Grid<Int>

    func trailRating(startingAt start: Point2D) -> Int {
        var uniquePaths = Set<[Point2D]>()
        breadthFirstTraverse(from: [start]) { trail in
            if map[trail.last!] == 9 {
                uniquePaths.insert(trail)
            }
        }
        return uniquePaths.count
    }
}

extension TopographicRatingMap: Graph {
    func neighbors(of trail: [Point2D]) -> [[Point2D]] {
        guard let last = trail.last else { fatalError() }
        let currentHeight = map[last]
        return last.orthogonalNeighbors
            .filter { neighbor in
                map.contains(neighbor) && map[neighbor] == currentHeight + 1
            }
            .map { trail + [$0] }
    }
}

extension HoofIt: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.example).expects(part1: 36, part2: 81),
        ]
    }
}
