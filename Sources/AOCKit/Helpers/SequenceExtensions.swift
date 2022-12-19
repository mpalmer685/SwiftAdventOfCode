public extension Sequence {
    func count(where isIncluded: (Self.Element) throws -> Bool) rethrows -> Int {
        try filter(isIncluded).count
    }

    func min<T: Comparable>(by keyPath: KeyPath<Element, T>) -> Self.Element? {
        self.min { first, second in
            first[keyPath: keyPath] < second[keyPath: keyPath]
        }
    }

    func min<N: Comparable>(of element: (Element) -> N) -> N? {
        var final: N?
        for i in self {
            let v = element(i)
            if let m = final {
                final = Swift.min(m, v)
            } else {
                final = v
            }
        }
        return final
    }

    func max<T: Comparable>(by keyPath: KeyPath<Element, T>) -> Self.Element? {
        self.max { first, second in
            first[keyPath: keyPath] < second[keyPath: keyPath]
        }
    }

    func max<N: Comparable>(of element: (Element) -> N) -> N? {
        var final: N?
        for i in self {
            let v = element(i)
            if let m = final {
                final = Swift.max(m, v)
            } else {
                final = v
            }
        }
        return final
    }
}

public extension Sequence where Element: Numeric {
    var sum: Element { reduce(0, +) }

    var product: Element { reduce(1, *) }
}
