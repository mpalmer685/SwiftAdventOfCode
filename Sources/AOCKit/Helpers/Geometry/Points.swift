public protocol PointProtocol: Dimensioned {
    associatedtype Vector: VectorProtocol

    func apply(_ vector: Vector) -> Self
}

public extension PointProtocol {
    func apply(_ vector: Vector) -> Self {
        assert(Self.numberOfDimensions == Vector.numberOfDimensions)
        return Self(zip(components, vector.components).map(+))
    }
}

public extension PointProtocol {
    static func + (lhs: Self, rhs: Vector) -> Self {
        guard numberOfDimensions == Vector.numberOfDimensions else {
            fatalError(
                "Cannot add a \(Vector.numberOfDimensions)-dimensional Vector to a \(numberOfDimensions)-dimensional Point."
            )
        }
        let new = zip(lhs.components, rhs.components).map(+)
        return Self(new)
    }

    static func += (lhs: inout Self, rhs: Vector) {
        // swiftlint:disable:next shorthand_operator
        lhs = lhs + rhs
    }

    static func - (lhs: Self, rhs: Vector) -> Self {
        lhs + -rhs
    }

    static func - (lhs: Self, rhs: Self) -> Vector {
        let new = zip(lhs.components, rhs.components).map(-)
        return Vector(new)
    }
}

public extension PointProtocol {
    func manhattanDistance(to other: Self) -> Int {
        zip(components, other.components).reduce(0) { $0 + abs($1.0 - $1.1) }
    }

    func vector(towards other: Self) -> Vector {
        if other == self {
            return .zero
        }
        assert(Self.numberOfDimensions == Vector.numberOfDimensions)

        let deltas = zip(other.components, components).map(-)
        return Vector(deltas)
    }

    func move(_ vector: Vector) -> Self { apply(vector) }
    func offset(by vector: Vector) -> Self { apply(vector) }

    var orthogonalNeighbors: [Self] {
        Vector.orthogonalAdjacents.map { apply($0) }
    }

    var neighbors: [Self] {
        Vector.adjacents.map { apply($0) }
    }
}

public struct Point2D: PointProtocol {
    public typealias Vector = Vector2D

    public static let numberOfDimensions = 2

    public var x: Int
    public var y: Int

    public var components: [Int] {
        get { [x, y] }
        set {
            Self.assertComponents(newValue)
            x = newValue[0]
            y = newValue[1]
        }
    }

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    public init(_ x: Int, _ y: Int) {
        self.init(x: x, y: y)
    }

    public init(_ components: [Int]) {
        Self.assertComponents(components)
        self.init(components[0], components[1])
    }
}

public struct Point3D: PointProtocol {
    public typealias Vector = Vector3D

    public static let numberOfDimensions = 3

    public var x: Int
    public var y: Int
    public var z: Int

    public var components: [Int] {
        get { [x, y, z] }
        set {
            Self.assertComponents(newValue)
            x = newValue[0]
            y = newValue[1]
            z = newValue[2]
        }
    }

    public init(x: Int, y: Int, z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }

    public init(_ x: Int, _ y: Int, _ z: Int) {
        self.init(x: x, y: y, z: z)
    }

    public init(_ components: [Int]) {
        Self.assertComponents(components)
        self.init(components[0], components[1], components[2])
    }
}

public struct Point4D: PointProtocol {
    public typealias Vector = Vector4D

    public static let numberOfDimensions = 4

    public var w: Int
    public var x: Int
    public var y: Int
    public var z: Int

    public var components: [Int] {
        get { [w, x, y, z] }
        set {
            Self.assertComponents(newValue)
            w = newValue[0]
            x = newValue[1]
            y = newValue[2]
            z = newValue[3]
        }
    }

    public init(w: Int, x: Int, y: Int, z: Int) {
        self.w = w
        self.x = x
        self.y = y
        self.z = z
    }

    public init(_ w: Int, _ x: Int, _ y: Int, _ z: Int) {
        self.init(w: w, x: x, y: y, z: z)
    }

    public init(_ components: [Int]) {
        Self.assertComponents(components)
        self.init(components[0], components[1], components[2], components[3])
    }
}
