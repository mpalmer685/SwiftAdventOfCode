import AOCKit

struct BoilingBoulders: Puzzle {
    static let day = 18

    func part1(input: Input) throws -> Int {
        Droplet(input).exposedFaces
    }

    func part2(input: Input) throws -> Int {
        Droplet(input).exteriorSurfaceArea
    }
}

private struct Droplet {
    private let cubes: Set<Point3D>

    private let xRange: ClosedRange<Int>
    private let yRange: ClosedRange<Int>
    private let zRange: ClosedRange<Int>

    init(_ input: Input) {
        cubes = Set(input.lines.map { Point3D($0.csvWords.integers) })

        let (xMin, xMax) = cubes.map(\.x).minAndMax()!
        let (yMin, yMax) = cubes.map(\.y).minAndMax()!
        let (zMin, zMax) = cubes.map(\.z).minAndMax()!

        xRange = xMin - 1 ... xMax + 1
        yRange = yMin - 1 ... yMax + 1
        zRange = zMin - 1 ... zMax + 1
    }

    var exposedFaces: Int {
        cubes.sum { cube in
            cube.orthogonalNeighbors.count { !cubes.contains($0) }
        }
    }
}

extension Droplet: Graph {
    var exteriorSurfaceArea: Int {
        let start = Point3D(xRange.lowerBound, yRange.lowerBound, zRange.lowerBound)
        let air = nodesAccessible(from: start).keys
        return cubes.sum { cube in
            cube.orthogonalNeighbors.count { air.contains($0) }
        }
    }

    func neighbors(of point: Point3D) -> [Point3D] {
        point.orthogonalNeighbors.filter { isWithinBounds($0) && !cubes.contains($0) }
    }

    private func isWithinBounds(_ point: Point3D) -> Bool {
        xRange.contains(point.x) && yRange.contains(point.y) && zRange.contains(point.z)
    }
}
