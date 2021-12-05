public extension Collection {
    var tail: SubSequence {
        let start = index(startIndex, offsetBy: 1)
        return self[start...]
    }
}

public extension Collection {
    func reject(_ isRejected: @escaping (Element) -> Bool) -> [Element] {
        filter(not(isRejected))
    }
}

private typealias Predicate<T> = (T) -> Bool
private func not<T>(_ fn: @escaping Predicate<T>) -> Predicate<T> {
    { !fn($0) }
}
