import AOCKit

private let rangeMin = 200_000_000_000_000
private let rangeMax = 400_000_000_000_000

struct NeverTellMeTheOdds: TestablePuzzleWithConfig {
    static let day = 24

    let testCases = [
        TestCaseWithConfig(
            input: .example,
            config: (7, 27),
            part1: 2,
            part2: 44,
        ),
    ]

    func part1(input: Input) throws -> Int {
        try part1(input: input, (rangeMin, rangeMax))
    }

    func part1(input: Input, _ range: (Int, Int)) throws -> Int {
        let (min, max) = range
        let particles = parse(input).map { Particle2D(position: $0, velocity: $1) }

        let targetRange = Double(min) ... Double(max)

        return particles.combinations(ofCount: 2).count { pair in
            let first = pair[0], second = pair[1]
            guard let intersection = first.intersection(with: second) else {
                return false
            }

            return targetRange.contains(intersection.x) && targetRange.contains(intersection.y)
        }
    }

    func part2(input: Input) throws -> Int {
        try part2(input: input, (rangeMin, rangeMax))
    }

    // https://www.reddit.com/r/adventofcode/comments/18q40he/2023_day_24_part_2_a_straightforward_nonsolver/
    func part2(input: Input, _: (Int, Int)) throws -> Int {
        let particles = parse(input)

        let m1 = asSystemMatrix(from: particles, using: \.x, \.y, \.dx, \.dy)
        guard let s1 = gaussEliminate(m1) else {
            fatalError()
        }
        let m2 = asSystemMatrix(from: particles, using: \.z, \.y, \.dz, \.dy)
        guard let s2 = gaussEliminate(m2) else {
            fatalError()
        }

        let x = s1[0],
            y = s1[1],
            z = s2[0]

        return Int(x + y + z)
    }

    func asSystemMatrix(
        from particles: [(Point3D, Vector3D)],
        using p1: (Point3D) -> Int,
        _ p2: (Point3D) -> Int,
        _ v1: (Vector3D) -> Int,
        _ v2: (Vector3D) -> Int,
    ) -> [[Double]] {
        let m = particles.map { particle in
            let (p, v) = particle
            let x = p1(p),
                y = p2(p),
                dx = v1(v),
                dy = v2(v)

            return [-dy, dx, y, -x, y * dx - x * dy]
        }

        return m.prefix(4).map { row in
            zip(row, m.last!).map { a, b in Double(a - b) }
        }
    }

    private func gaussEliminate(_ system: [[Double]]) -> [Double]? {
        var system = system
        let size = system.count

        for i in 0 ..< size - 1 where system[i][i] != 0 {
            for j in i ..< size - 1 {
                let factor = system[j + 1][i] / system[i][i]

                for k in i ..< size + 1 {
                    system[j + 1][k] -= factor * system[i][k]
                }
            }
        }

        for i in (1 ..< size).reversed() where system[i][i] != 0 {
            for j in (1 ..< i + 1).reversed() {
                let factor = system[j - 1][i] / system[i][i]

                for k in (0 ..< size + 1).reversed() {
                    system[j - 1][k] -= factor * system[i][k]
                }
            }
        }

        var solutions = [Double]()

        for i in 0 ..< size {
            guard system[i][i] != 0 else {
                return nil
            }

            system[i][size] /= system[i][i]
            system[i][i] = 1
            solutions.append(system[i][size])
        }

        return solutions
    }

    private func parse(_ input: Input) -> [(Point3D, Vector3D)] {
        input.lines.map { line in
            let words = line.words(separatedBy: " @ ")

            let positionDimensions = words[0].words(separatedBy: ",").map(\.trimmed).integers
            let vectorDimensions = words[1].words(separatedBy: ",").map(\.trimmed).integers

            return (.init(positionDimensions), .init(vectorDimensions))
        }
    }
}

private struct Particle2D: Particle {
    let position: FPoint2D
    let velocity: FVector2D

    let slope: Double
    let intercept: Double

    init(position: Point3D, velocity: Vector3D) {
        self.init(
            position: FPoint2D(position.x, position.y),
            velocity: FVector2D(velocity.dx, velocity.dy),
        )
    }

    init(position: FPoint2D, velocity: FVector2D) {
        self.position = position
        self.velocity = velocity

        slope = self.velocity.dy / self.velocity.dx
        intercept = self.position.y - slope * self.position.x
    }

    func intersection(with other: Particle2D) -> FPoint2D? {
        guard slope != other.slope else {
            return nil
        }

        let x = (other.intercept - intercept) / (slope - other.slope)
        let y = slope * x + intercept
        let intersection = FPoint2D(x, y)

        guard isMoving(towards: intersection), other.isMoving(towards: intersection) else {
            return nil
        }

        return intersection
    }
}

private protocol Particle: CustomStringConvertible {
    associatedtype Point: PointProtocol

    var position: Point { get }
    var velocity: Point.Vector { get }

    init(position: Point3D, velocity: Vector3D)

    func intersection(with: Self) -> Point?
}

extension Particle {
    var description: String {
        "\(position) @ \(velocity)"
    }
}

extension Particle where Point.Precision: FloatingPoint {
    func isMoving(towards point: Point) -> Bool {
        position.vector(towards: point).isParallel(to: velocity)
    }
}

private struct FPoint2D: PointProtocol {
    typealias Vector = FVector2D

    static let numberOfDimensions = 2

    var x: Double
    var y: Double

    var components: [Double] {
        get { [x, y] }
        set {
            Self.assertComponents(newValue)
            x = newValue[0]
            y = newValue[1]
        }
    }

    init(_ x: Double, _ y: Double) {
        self.x = x
        self.y = y
    }

    init(_ x: Int, _ y: Int) {
        self.init(Double(x), Double(y))
    }

    init(_ components: [Double]) {
        Self.assertComponents(components)
        self.init(components[0], components[1])
    }
}

private struct FVector2D: VectorProtocol {
    static let numberOfDimensions = 2

    var dx: Double
    var dy: Double

    var components: [Double] {
        get { [dx, dy] }
        set {
            Self.assertComponents(newValue)
            dx = newValue[0]
            dy = newValue[1]
        }
    }

    init(_ dx: Double, _ dy: Double) {
        self.dx = dx
        self.dy = dy
    }

    init(_ dx: Int, _ dy: Int) {
        self.init(Double(dx), Double(dy))
    }

    init(_ components: [Double]) {
        Self.assertComponents(components)
        self.init(components[0], components[1])
    }

    static let adjacents: [FVector2D] = adjacents()
    static let orthogonalAdjacents: [FVector2D] = adjacents.filter(\.isOrthogonal)
}

private extension VectorProtocol where Precision: FloatingPoint {
    var unit: Self {
        Self(components.map {
            $0 == 0 ? $0 : ($0 / $0.magnitude)
        })
    }

    func isParallel(to other: Self) -> Bool {
        unit == other.unit
    }
}
