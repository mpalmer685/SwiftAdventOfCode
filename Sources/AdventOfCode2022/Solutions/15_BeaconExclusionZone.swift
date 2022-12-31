import AOCKit

private typealias ScanData = (scanner: Point2D, beacon: Point2D, distance: Int)

class BeaconExclusionZone: Puzzle {
    static let day = 15

//    static let rawInput: String? = """
//    Sensor at x=2, y=18: closest beacon is at x=-2, y=15
//    Sensor at x=9, y=16: closest beacon is at x=10, y=16
//    Sensor at x=13, y=2: closest beacon is at x=15, y=3
//    Sensor at x=12, y=14: closest beacon is at x=10, y=16
//    Sensor at x=10, y=20: closest beacon is at x=10, y=16
//    Sensor at x=14, y=17: closest beacon is at x=10, y=16
//    Sensor at x=8, y=7: closest beacon is at x=2, y=10
//    Sensor at x=2, y=0: closest beacon is at x=2, y=10
//    Sensor at x=0, y=11: closest beacon is at x=2, y=10
//    Sensor at x=20, y=14: closest beacon is at x=25, y=17
//    Sensor at x=17, y=20: closest beacon is at x=21, y=22
//    Sensor at x=16, y=7: closest beacon is at x=15, y=3
//    Sensor at x=14, y=3: closest beacon is at x=15, y=3
//    Sensor at x=20, y=1: closest beacon is at x=15, y=3
//    """

    private lazy var scanData: [ScanData] = {
        input().lines.map(\.integers).map { values -> ScanData in
            let scanner = Point2D(values[0], values[1])
            let beacon = Point2D(values[2], values[3])
            let distance = scanner.manhattanDistance(to: beacon)
            return (scanner, beacon, distance)
        }
    }()

    func part1() throws -> Int {
        let y = 2_000_000

        var scanned = Set<Int>()
        for (scanner, _, distance) in scanData where distance >= abs(y - scanner.y) {
            let distanceToRow = abs(y - scanner.y)
            let xRange = distance - distanceToRow
            scanned.formUnion(scanner.x - xRange ... scanner.x + xRange)
        }

        for (_, beacon, _) in scanData where beacon.y == y {
            scanned.remove(beacon.x)
        }

        return scanned.count
    }

    func part2() throws -> Int {
        let range = 0 ... 4_000_000

        for (scanner, _, distance) in scanData {
            let corners = [
                scanner - Vector2D(dx: 0, dy: distance + 1),
                scanner + Vector2D(dx: distance + 1, dy: 0),
                scanner + Vector2D(dx: 0, dy: distance + 1),
                scanner - Vector2D(dx: distance + 1, dy: 0),
                scanner - Vector2D(dx: 0, dy: distance + 1),
            ]

            var borders = Set<Point2D>()
            for (start, end) in corners.adjacentPairs() {
                let border = Point2D.all(from: start, to: end).filter { p -> Bool in
                    range.contains(p.x) && range.contains(p.y)
                }
                borders.formUnion(border)
            }

            if let p = borders.first(where: { !$0.isScanned(by: scanData) }) {
                return p.x * 4_000_000 + p.y
            }
        }

        fatalError("No solution found ")
    }
}

private extension Point2D {
    static func all(from start: Self, to end: Self) -> [Self] {
        let unitDx = (end.x - start.x).signum()
        let unitDy = (end.y - start.y).signum()
        let distance = abs(end.x - start.x)

        return (0 ..< distance).map { step -> Self in
            Self(start.x + unitDx * step, start.y + unitDy * step)
        }
    }

    func isScanned(by scanData: [ScanData]) -> Bool {
        scanData.contains { scanner, _, distance in
            manhattanDistance(to: scanner) <= distance
        }
    }
}
