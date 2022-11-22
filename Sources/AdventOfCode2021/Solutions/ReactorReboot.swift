import Algorithms
import AOCKit
import Foundation

struct ReactorReboot: Puzzle {
    static let day = 22

    func part1() throws -> Int {
        let activeRange = (-50 ... 50)

        let instructions = parseInput().filter { i in
            let (x, y, z, _) = i
            return activeRange.overlaps(x) && activeRange.overlaps(y) && activeRange.overlaps(z)
        }

        var onCubes = Set<Point3D>()
        for (xRange, yRange, zRange, isOn) in instructions {
            let points = xRange.filter(activeRange.contains).flatMap { x in
                yRange.filter(activeRange.contains).flatMap { y in
                    zRange.filter(activeRange.contains).map { z in Point3D(x: x, y: y, z: z) }
                }
            }

            if isOn {
                onCubes.formUnion(points)
            } else {
                onCubes.subtract(points)
            }
        }

        return onCubes.count
    }

    func part2() throws -> Int {
        let cuboids = parseInput().map(Cuboid.init)
        return cuboids.indexed()
            .filter(\.element.isOn)
            .reduce(0) { v, pair in
                let (i, cuboid) = pair
                let intersections: [Cuboid] = cuboids[(i + 1)...]
                    .filter { $0.intersects(cuboid) }
                    .reduce(into: []) { $0.append(cuboid.intersection(with: $1)!) }
                return v + cuboid.volume - volume(of: intersections)
            }
    }

    private func parseInput() -> [Instruction] {
        let pattern =
            NSRegularExpression(
                "(on|off) x=(-?\\d+\\.\\.-?\\d+),y=(-?\\d+\\.\\.-?\\d+),z=(-?\\d+\\.\\.-?\\d+)"
            )
        return input().lines.raw.map { line in
            guard let match = pattern.match(line) else { fatalError() }
            let xs = match[2].components(separatedBy: "..").compactMap(Int.init)
            let ys = match[3].components(separatedBy: "..").compactMap(Int.init)
            let zs = match[4].components(separatedBy: "..").compactMap(Int.init)

            return (xs[0] ... xs[1], ys[0] ... ys[1], zs[0] ... zs[1], match[1] == "on")
        }
    }
}

private func volume<C: Collection>(of cuboids: C) -> Int where C.Element == Cuboid {
    guard let (start, rest) = cuboids.firstAndRest() else { return 0 }

    let intersections: Set<Cuboid> = rest
        .compactMap(start.intersection)
        .reduce(into: []) { $0.insert($1) }
    return start.volume + volume(of: rest) - volume(of: intersections)
}

private typealias Instruction = (ClosedRange<Int>, ClosedRange<Int>, ClosedRange<Int>, Bool)

private struct Point3D: Hashable {
    let x: Int
    let y: Int
    let z: Int
}

private struct Cuboid: Hashable {
    var xRange: ClosedRange<Int>
    var yRange: ClosedRange<Int>
    var zRange: ClosedRange<Int>
    var isOn: Bool

    init(
        xRange: ClosedRange<Int>,
        yRange: ClosedRange<Int>,
        zRange: ClosedRange<Int>,
        isOn: Bool = false
    ) {
        self.xRange = xRange
        self.yRange = yRange
        self.zRange = zRange
        self.isOn = isOn
    }

    var volume: Int {
        xRange.count * yRange.count * zRange.count
    }

    func intersects(_ other: Cuboid) -> Bool {
        xRange.overlaps(other.xRange) && yRange.overlaps(other.yRange) && zRange
            .overlaps(other.zRange)
    }

    func intersection(with c2: Cuboid) -> Cuboid? {
        guard let xr = xRange.intersection(with: c2.xRange),
              let yr = yRange.intersection(with: c2.yRange),
              let zr = zRange.intersection(with: c2.zRange)
        else {
            return nil
        }
        return Cuboid(xRange: xr, yRange: yr, zRange: zr)
    }
}

private extension ClosedRange {
    func intersection(with other: Self) -> Self? {
        guard overlaps(other) else { return nil }
        let lowerBound = Swift.max(lowerBound, other.lowerBound)
        let upperBound = Swift.min(upperBound, other.upperBound)
        return lowerBound ... upperBound
    }
}

private extension Collection {
    func firstAndRest() -> (Element, SubSequence)? {
        guard let first = first else { return nil }
        let startOfRest = index(after: startIndex)
        return (first, self[startOfRest...])
    }
}
