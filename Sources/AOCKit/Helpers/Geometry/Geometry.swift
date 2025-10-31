public protocol Dimensioned: Hashable, CustomStringConvertible, Sendable {
    associatedtype Precision: SignedNumeric, CustomStringConvertible, Comparable, Sendable

    static var numberOfDimensions: Int { get }
    static var descriptionWrappers: (String, String) { get }

    var components: [Precision] { get }
    init(_ components: [Precision])
}

public extension Dimensioned {
    static var descriptionWrappers: (String, String) {
        ("(", ")")
    }
}

public extension Dimensioned {
    static var zero: Self {
        Self(Array(repeating: 0, count: numberOfDimensions))
    }

    static prefix func - (lhs: Self) -> Self {
        Self(lhs.components.map { -$0 })
    }

    var description: String {
        let (start, end) = Self.descriptionWrappers
        return start + components.map(String.init).joined(separator: ", ") + end
    }
}

public extension Dimensioned {
    static func assertComponents(_ components: [Precision], caller: StaticString = #function) {
        if components.count != numberOfDimensions {
            fatalError(
                "Invalid components provided to \(caller). Expected \(numberOfDimensions), but got \(components.count)",
            )
        }
    }
}
