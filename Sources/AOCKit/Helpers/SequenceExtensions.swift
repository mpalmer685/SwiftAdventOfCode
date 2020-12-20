public extension Sequence {
    func count(where isIncluded: (Self.Element) throws -> Bool) rethrows -> Int {
        try filter(isIncluded).count
    }

    func min<T: Comparable>(by keyPath: KeyPath<Element, T>) -> Self.Element? {
        self.min { first, second in
            first[keyPath: keyPath] < second[keyPath: keyPath]
        }
    }

    func max<T: Comparable>(by keyPath: KeyPath<Element, T>) -> Self.Element? {
        self.max { first, second in
            first[keyPath: keyPath] < second[keyPath: keyPath]
        }
    }
}
