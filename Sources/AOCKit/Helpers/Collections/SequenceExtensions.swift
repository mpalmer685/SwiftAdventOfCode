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

    func map<T>(as type: T.Type) -> [T] where T: RawRepresentable, T.RawValue == Element {
        compactMap(T.init(rawValue:))
    }

    func sorted<T: Comparable>(using getValue: (Element) -> T) -> [Element] {
        sorted(by: { l, r in
            getValue(l) < getValue(r)
        })
    }

    func sum<N: Numeric>(of element: (Element) -> N) -> N {
        var sum: N = 0
        for i in self {
            sum += element(i)
        }
        return sum
    }

    func product<N: Numeric>(of element: (Element) -> N) -> N {
        var prod: N = 1
        for i in self {
            prod *= element(i)
        }
        return prod
    }
}

public extension Sequence where Element: Equatable {
    func count(of element: Element) -> Int {
        count(where: { $0 == element })
    }
}

public extension Sequence where Element: Numeric {
    var sum: Element { reduce(0, +) }

    var product: Element { reduce(1, *) }
}
