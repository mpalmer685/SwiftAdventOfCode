protocol LinkedPath: Hashable {
    associatedtype Value

    var value: Value { get }
    var parent: Self? { get }
}

extension LinkedPath {
    var path: [Value] {
        var result: [Value] = []
        var node = self
        while let parent = node.parent {
            result.append(node.value)
            node = parent
        }
        return result.reversed()
    }
}

extension LinkedPath where Value: Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}
