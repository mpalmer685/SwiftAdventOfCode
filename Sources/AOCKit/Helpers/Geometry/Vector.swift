public protocol VectorProtocol: Dimensioned {
    static var adjacents: [Self] { get }
    static var orthogonalAdjacents: [Self] { get }
}

public extension VectorProtocol {
    static var descriptionWrappers: (String, String) {
        ("<", ">")
    }
}

public extension VectorProtocol {
    var isZero: Bool { components.allSatisfy { $0 == 0 } }
    var isNotZero: Bool { !isZero }

    var isOrthogonal: Bool {
        components.count { $0 != 0 } <= 1
    }

    static func + (lhs: Self, rhs: Self) -> Self {
        let new = zip(lhs.components, rhs.components).map(+)
        return Self(new)
    }
}

public extension VectorProtocol {
    static func adjacents(
        includingSelf: Bool = false,
        length: Int = 3
    ) -> [Self] {
        let combos = combos(count: Self.numberOfDimensions, length: length)
        var all = combos.map(Self.init)
        if !includingSelf {
            all = all.filter(\.isNotZero)
        }
        return all
    }

    private static func combos(count: Int, length: Int) -> [[Precision]] {
        guard count > 0 else { return [] }
        let remainders = combos(count: count - 1, length: length)

        let lengthRange = (-length / 2) ... (-length / 2 + length - 1)
        if remainders.isEmpty {
            return Array(lengthRange).map { [Precision(exactly: $0)!] }
        }

        return lengthRange.flatMap { l -> [[Precision]] in
            remainders.map { [Precision(exactly: l)!] + $0 }
        }
    }
}

public struct Vector2D: VectorProtocol {
    public static let numberOfDimensions = 2

    public static let x = Self(1, 0)
    public static let y = Self(0, 1)

    public var dx: Int
    public var dy: Int

    public var components: [Int] {
        get { [dx, dy] }
        set {
            Self.assertComponents(newValue)
            dx = newValue[0]
            dy = newValue[1]
        }
    }

    public init(dx: Int, dy: Int) {
        self.dx = dx
        self.dy = dy
    }

    public init(_ dx: Int, _ dy: Int) {
        self.init(dx: dx, dy: dy)
    }

    public init(_ components: [Int]) {
        Self.assertComponents(components)
        self.init(components[0], components[1])
    }

    public static let adjacents: [Self] = adjacents()
    public static let orthogonalAdjacents = adjacents.filter(\.isOrthogonal)
}

public struct Vector3D: VectorProtocol {
    public static let numberOfDimensions = 3

    public static let x = Self(1, 0, 0)
    public static let y = Self(0, 1, 0)
    public static let z = Self(0, 0, 1)

    public var dx: Int
    public var dy: Int
    public var dz: Int

    public var components: [Int] {
        get { [dx, dy, dz] }
        set {
            Self.assertComponents(newValue)
            dx = newValue[0]
            dy = newValue[1]
            dz = newValue[2]
        }
    }

    public init(dx: Int, dy: Int, dz: Int) {
        self.dx = dx
        self.dy = dy
        self.dz = dz
    }

    public init(_ dx: Int, _ dy: Int, _ dz: Int) {
        self.init(dx: dx, dy: dy, dz: dz)
    }

    public init(_ components: [Int]) {
        Self.assertComponents(components)
        self.init(components[0], components[1], components[2])
    }

    public static let adjacents: [Self] = adjacents()
    public static let orthogonalAdjacents: [Self] = adjacents.filter(\.isOrthogonal)
}

public struct Vector4D: VectorProtocol {
    public static let numberOfDimensions = 4

    public var dw: Int
    public var dx: Int
    public var dy: Int
    public var dz: Int

    public var components: [Int] {
        get { [dw, dx, dy, dz] }
        set {
            Self.assertComponents(newValue)
            dw = newValue[0]
            dx = newValue[1]
            dy = newValue[2]
            dz = newValue[3]
        }
    }

    public init(dw: Int, dx: Int, dy: Int, dz: Int) {
        self.dw = dw
        self.dx = dx
        self.dy = dy
        self.dz = dz
    }

    public init(_ dw: Int, _ dx: Int, _ dy: Int, _ dz: Int) {
        self.init(dw: dw, dx: dx, dy: dy, dz: dz)
    }

    public init(_ components: [Int]) {
        Self.assertComponents(components)
        self.init(components[0], components[1], components[2], components[3])
    }

    public static let adjacents: [Self] = adjacents()
    public static let orthogonalAdjacents: [Self] = adjacents.filter(\.isOrthogonal)
}
