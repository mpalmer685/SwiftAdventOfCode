public extension Array {
    func padded(toLength length: Int, with element: Element) -> Self {
        let neededLength = length - count
        guard neededLength > 0 else { return self }

        return self + Self(repeating: element, count: neededLength)
    }
}
