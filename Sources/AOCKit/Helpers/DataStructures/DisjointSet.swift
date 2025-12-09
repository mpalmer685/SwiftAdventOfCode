public struct DisjointSet<Element: Hashable> {
    private var indices: [Element: Int]
    private var parents: [Int]
    private var sizes: [Int]

    public init(_ elements: [Element]) {
        indices = Dictionary(uniqueKeysWithValues: elements.enumerated().map { ($1, $0) })
        parents = Array(0 ..< elements.count)
        sizes = Array(repeating: 1, count: elements.count)
    }

    public mutating func setCount() -> Int {
        Set(parents).reduce(into: Set<Int>()) { result, index in
            result.insert(root(from: index))
        }.count
    }

    public mutating func allSets() -> [Set<Element>] {
        var sets = [Int: Set<Element>]()

        for (element, index) in indices {
            let rootIndex = root(from: index)
            sets[rootIndex, default: []].insert(element)
        }

        return Array(sets.values)
    }

    public mutating func createSet(for element: Element) {
        guard indices[element] == nil else { return }

        indices[element] = parents.count
        parents.append(parents.count)
        sizes.append(1)
    }

    public mutating func unionSets(containing first: Element, and second: Element) {
        guard let firstRoot = root(of: first), let secondRoot = root(of: second) else {
            return
        }
        guard firstRoot != secondRoot else {
            return
        }

        if sizes[firstRoot] < sizes[secondRoot] {
            parents[firstRoot] = secondRoot
            sizes[secondRoot] += sizes[firstRoot]
        } else {
            parents[secondRoot] = firstRoot
            sizes[firstRoot] += sizes[secondRoot]
        }
    }

    private mutating func root(of element: Element) -> Int? {
        guard let index = indices[element] else { return nil }
        return root(from: index)
    }

    private mutating func root(from index: Int) -> Int {
        if index != parents[index] {
            parents[index] = root(from: parents[index])
        }
        return parents[index]
    }
}
