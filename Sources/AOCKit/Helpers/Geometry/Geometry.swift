public protocol Dimensioned: Hashable, CustomStringConvertible {
    static var numberOfDimensions: Int { get }
    static var descriptionWrappers: (String, String) { get }

    var components: [Int] { get }
    init(_ components: [Int])
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
        return start + components.map(\.description).joined(separator: ", ") + end
    }
}

extension Dimensioned {
    static func assertComponents(_ components: [Int], caller: StaticString = #function) {
        if components.count != numberOfDimensions {
            fatalError(
                "Invalid components provided to \(caller). Expected \(numberOfDimensions), but got \(components.count)"
            )
        }
    }
}
