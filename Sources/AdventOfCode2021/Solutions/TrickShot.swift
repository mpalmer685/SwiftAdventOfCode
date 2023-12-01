import AOCKit

private let testInput = "target area: x=20..30, y=-10..-5"

struct TrickShot: Puzzle {
    static let day = 17
    static let rawInput: String? = "target area: x=185..221, y=-122..-74"

    func part1(input: Input) throws -> Int {
        let bounds = parse(input)
        let heights = findMaxHeights(landingIn: bounds)
        guard let maxHeight = heights.values.max() else { fatalError() }

        return maxHeight
    }

    func part2(input: Input) throws -> Int {
        let bounds = parse(input)
        let heights = findMaxHeights(landingIn: bounds)
        return heights.count
    }

    private func parse(_ input: Input) -> Bounds {
        let pattern =
            NSRegularExpression("target area: x=(-?\\d+)\\.{2}(-?\\d+), y=(-?\\d+)\\.{2}(-?\\d+)")
        guard let match = pattern.match(input.raw) else { fatalError() }
        guard let xMin = Int(match[1]) else { fatalError() }
        guard let xMax = Int(match[2]) else { fatalError() }
        guard let yMin = Int(match[3]) else { fatalError() }
        guard let yMax = Int(match[4]) else { fatalError() }
        return Bounds(xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax)
    }
}

private func findMaxHeights(landingIn bounds: Bounds) -> [Velocity: Int] {
    /*
     Determining bounds of horizontal and vertical velocities:

     vxMax: after the first step, probe should be at xMax
     vxMin: while slowing down, the x-distance covered by the probe is a
            triangle number (e.g., if starting vx = 3, the probe will move
            3 units in the first step, 2 in the second, and 1 in the third
            for a total of 6 units). So eliminate any speeds where
                n * (n + 1) / 2
            is less than xMin
     vyMin: similar to vxMax: after the first step, probe should be at yMin
     vyMax: assuming vy0 is positive, then when the probe returns to y = 0
            vy will be -vy0 - 1 (i.e., same speed but moving down, minus 1
            because of the tick at y = 0). To maximize vy0, the very next
            tick should place the probe at yMin, so vy0 = -yMin - 1
     */
    let vxMax = bounds.xMax
    guard let vxMin = (1 ..< vxMax).first(where: { ($0 * ($0 + 1) / 2) >= bounds.xMin }) else {
        fatalError("Couldn't find a minimum vx")
    }
    let vyMin = bounds.yMin
    let vyMax = -bounds.yMin - 1

    var heights: [Velocity: Int] = [:]
    for vx in vxMin ... vxMax {
        for vy in vyMin ... vyMax {
            let vStart = Velocity(vx: vx, vy: vy)
            var v = vStart
            var pos = Position.origin
            while !bounds.contains(pos), pos.x <= bounds.xMax, pos.y >= bounds.yMin {
                pos.update(with: v)
                v.update()
                heights[vStart] = max(pos.y, heights[vStart, default: .min])
            }
            if !bounds.contains(pos) {
                heights[vStart] = nil
            }
        }
    }

    return heights
}

private struct Velocity: Hashable {
    private(set) var vx: Int
    private(set) var vy: Int

    mutating func update() {
        vy -= 1
        vx = decreaseMagnitude(of: vx)
    }
}

private func decreaseMagnitude(of value: Int) -> Int {
    guard value != 0 else { return 0 }

    let sign = abs(value) / value
    return sign * (abs(value) - 1)
}

private struct Position {
    static let origin = Position(x: 0, y: 0)

    private(set) var x: Int
    private(set) var y: Int

    mutating func update(with velocity: Velocity) {
        x += velocity.vx
        y += velocity.vy
    }

    func offsetBy(_ dx: Int, _ dy: Int) -> Self {
        Position(x: x + dx, y: y + dy)
    }
}

private struct Bounds {
    let xMin: Int
    let xMax: Int
    let yMin: Int
    let yMax: Int

    func contains(_ pos: Position) -> Bool {
        pos.x.isBetween(xMin, and: xMax) && pos.y.isBetween(yMin, and: yMax)
    }
}
