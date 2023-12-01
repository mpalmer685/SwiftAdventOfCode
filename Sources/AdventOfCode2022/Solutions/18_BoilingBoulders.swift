import AOCKit

class BoilingBoulders: Puzzle {
    static let day = 18

    func part1(input: Input) throws -> Int {
        let cubes = cubes(from: input)
        let droplet = Set<Point3D>(cubes)
        return cubes.sum { cube in
            cube.orthogonalNeighbors.count { !droplet.contains($0) }
        }
    }

    func part2(input: Input) throws -> Int {
        let cubes = cubes(from: input)
        let droplet = Set<Point3D>(cubes)
        let air = findAir(around: droplet)
        return cubes.sum { cube in
            cube.orthogonalNeighbors.count { air.contains($0) }
        }
    }

    private func cubes(from input: Input) -> [Point3D] {
        input.lines.map { Point3D($0.csvWords.integers) }
    }

    private func findAir(around droplet: Set<Point3D>) -> Set<Point3D> {
        let xRange = droplet.min(of: \.x)! - 1 ... droplet.max(of: \.x)! + 1
        let yRange = droplet.min(of: \.y)! - 1 ... droplet.max(of: \.y)! + 1
        let zRange = droplet.min(of: \.z)! - 1 ... droplet.max(of: \.z)! + 1

        func isWithinBounds(_ point: Point3D) -> Bool {
            xRange.contains(point.x) && yRange.contains(point.y) && zRange.contains(point.z)
        }

        let start = Point3D(xRange.lowerBound, yRange.lowerBound, zRange.lowerBound)
        var toVisit: Queue<Point3D> = [start]
        var visited: Set<Point3D> = []

        while let p = toVisit.pop() {
            guard !visited.contains(p) else { continue }

            visited.insert(p)

            for neighbor in p.orthogonalNeighbors
                where isWithinBounds(neighbor) && !droplet.contains(neighbor)
            {
                toVisit.push(neighbor)
            }
        }

        return visited
    }
}
