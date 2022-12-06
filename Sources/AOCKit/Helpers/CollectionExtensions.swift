public extension Collection {
    var isNotEmpty: Bool { isEmpty == false }

    var tail: SubSequence {
        let start = index(startIndex, offsetBy: 1)
        return self[start...]
    }

    func reject(_ isRejected: @escaping (Element) -> Bool) -> [Element] {
        filter(not(isRejected))
    }

    func dividing(into count: Int) -> [SubSequence] {
        let (sliceLength, _) = self.count.quotientAndRemainder(dividingBy: count)

        return (0 ..< count).map { slice -> SubSequence in
            let start = self.index(startIndex, offsetBy: slice * sliceLength)
            if slice < count - 1 {
                let end = self.index(start, offsetBy: sliceLength)
                return self[start ..< end]
            } else {
                return self[start...]
            }
        }
    }
}

public extension Collection where Element: Collection, Element.Element: Hashable {
    var commonElements: Set<Element.Element> {
        if isEmpty { return [] }

        var set = Set(first!)
        for remaining in dropFirst() {
            // this extra Set() call here is necessary because of this:
            // https://github.com/apple/swift/pull/59422
            //
            // This was discovered in Swift 5.7
            set.formIntersection(Set(remaining))

            if set.isEmpty { break }
        }
        return set
    }
}

private typealias Predicate<T> = (T) -> Bool
private func not<T>(_ fn: @escaping Predicate<T>) -> Predicate<T> {
    { !fn($0) }
}
