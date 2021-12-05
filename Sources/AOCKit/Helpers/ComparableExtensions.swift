public extension Comparable {
    func isBetween(_ min: Self, and max: Self) -> Bool {
        self >= min && self <= max
    }
}

public func minMax<T>(_ x: T, _ y: T) -> (min: T, max: T) where T : Comparable {
    (min(x, y), max(x, y))
}
