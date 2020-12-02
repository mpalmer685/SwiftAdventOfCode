extension Comparable {
    func isBetween(_ min: Self, and max: Self) -> Bool {
        self >= min && self <= max
    }
}
