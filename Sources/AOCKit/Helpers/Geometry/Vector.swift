public protocol VectorProtocol: Dimensioned {}

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

internal extension VectorProtocol {
    static func adjacents(
        orthogonalOnly: Bool,
        includingSelf: Bool = false,
        length: Int = 3
    ) -> [Self] {
        let combos = combos(count: Self.numberOfDimensions, length: length)
        var all = combos.map(Self.init)
        if orthogonalOnly {
            all = all.filter(\.isOrthogonal)
        }
        if !includingSelf {
            all = all.filter(\.isNotZero)
        }
        return all
    }

    private static func combos(count: Int, length: Int) -> [[Int]] {
        guard count > 0 else { return [] }
        let remainders = combos(count: count - 1, length: length)

        let lengthRange = (-length / 2) ... (-length / 2 + length - 1)
        if remainders.isEmpty {
            return Array(lengthRange).map { [$0] }
        }

        return lengthRange.flatMap { l -> [[Int]] in
            remainders.map { [l] + $0 }
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
}

public struct Vector3D: VectorProtocol {
    public static let numberOfDimensions = 3

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
}
