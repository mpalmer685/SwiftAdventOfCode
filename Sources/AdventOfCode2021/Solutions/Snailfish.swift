import AOCKit
import Foundation

struct Snailfish: Puzzle {
    static let day = 18

    func part1() throws -> Int {
        let numbers = input().lines.raw.map(Number.init)
        let sum = numbers.reduce(+)
        return sum.magnitude
    }

    func part2() throws -> Int {
        let numbers = input().lines.raw.map(Number.init)

        var maxMagnitude = 0
        for i in numbers.indices {
            for j in numbers.indices where i != j {
                let first = numbers[i]
                let second = numbers[j]
                let sum = first + second
                maxMagnitude = max(maxMagnitude, sum.magnitude)
            }
        }
        return maxMagnitude
    }
}

private class Number {
    private enum Branch: String, CustomStringConvertible {
        case left, right

        var description: String { rawValue }
    }

    private typealias Descendant = (value: Int, branches: [Branch])

    private var descendants: [Descendant]

    init(input: String) {
        var currentIndex = input.startIndex
        var branches: [Branch] = []
        descendants = []
        while currentIndex < input.endIndex {
            let c = input[currentIndex]
            if c == "[" {
                branches.append(.left)
            } else if c == "," {
                branches.removeLast()
                branches.append(.right)
            } else if c == "]" {
                branches.removeLast()
            } else {
                guard let value = Int(String(c)) else { fatalError("Couldn't parse \(c)") }
                descendants.append((value, branches))
            }
            currentIndex = input.index(after: currentIndex)
        }
    }

    private init(_ descendants: [(value: Int, branches: [Branch])]) {
        self.descendants = descendants
    }

    var magnitude: Int {
        guard let tree = TreeNode(descendants) else { fatalError() }
        return tree.magnitude
    }

    func reduce() {
        while true {
            if let explodeIndex = descendants.indices.first(where: needsExploding) {
                explode(at: explodeIndex)
                continue
            }
            if let splitIndex = descendants.firstIndex(where: { $0.value >= 10 }) {
                split(at: splitIndex)
                continue
            }
            break
        }
    }

    private func needsExploding(at index: Int) -> Bool {
        index < descendants.count - 1 &&
            descendants[index].branches.count > 4 &&
            descendants[index].branches.last == .left &&
            descendants[index + 1].branches.count == descendants[index].branches.count &&
            descendants[index + 1].branches.last == .right
    }

    private func explode(at index: Int) {
        let left = descendants[index]
        let right = descendants[index + 1]
        if descendants.indices.contains(index - 1) {
            descendants[index - 1].value += left.value
        }
        if descendants.indices.contains(index + 2) {
            descendants[index + 2].value += right.value
        }
        var branches = left.branches
        branches.removeLast()
        descendants[index] = (0, branches)
        descendants.remove(at: index + 1)
    }

    private func split(at index: Int) {
        let (value, branches) = descendants[index]
        let left = Int(floor(Double(value) / 2))
        let right = Int(ceil(Double(value) / 2))
        descendants[index] = (left, branches + [.left])
        descendants.insert((right, branches + [.right]), at: index + 1)
    }

    static func + (lhs: Number, rhs: Number) -> Number {
        let left = lhs.descendants.map { ($0.value, $0.branches.prepending(.left)) }
        let right = rhs.descendants.map { ($0.value, $0.branches.prepending(.right)) }
        let number = Number(left + right)
        number.reduce()
        return number
    }

    private class TreeNode: CustomStringConvertible {
        private(set) var value: Int = 0
        private(set) var left: TreeNode?
        private(set) var right: TreeNode?

        var magnitude: Int {
            if let left = left, let right = right {
                return 3 * left.magnitude + 2 * right.magnitude
            } else {
                return value
            }
        }

        init?(_ descendants: [Descendant]) {
            guard !descendants.isEmpty else { return nil }

            if descendants.count == 1, descendants[0].branches.isEmpty {
                value = descendants[0].value
            } else {
                let index = descendants.firstIndex { $0.branches.starts(with: .right) } ??
                    descendants.endIndex
                value = 0
                let leftDescendants = Array(descendants[0 ..< index])
                    .map { ($0.value, $0.branches.removingFirst()) }
                let rightDescendants = Array(descendants[index...])
                    .map { ($0.value, $0.branches.removingFirst()) }
                left = TreeNode(leftDescendants)
                right = TreeNode(rightDescendants)
            }
        }

        var description: String {
            if let left = left, let right = right {
                return "[\(left),\(right)]"
            } else {
                return "\(value)"
            }
        }
    }
}

extension Number: CustomStringConvertible {
    var description: String { "\(descendants)" }
}

private extension Collection {
    func reduce(
        _ nextPartialResult: (_ partialResult: Self.Element, Self.Element) -> Self.Element
    ) -> Self.Element {
        guard !isEmpty else { fatalError("Collection is empty") }
        return self[index(after: startIndex)...].reduce(self[startIndex], nextPartialResult)
    }
}

private extension Collection where Element: Equatable {
    func starts(with possiblePrefix: Self.Element) -> Bool {
        first == possiblePrefix
    }
}

private extension Array {
    mutating func prepend(_ element: Element) {
        insert(element, at: 0)
    }

    func prepending(_ element: Element) -> Self {
        var copy = self
        copy.prepend(element)
        return copy
    }

    func removingFirst() -> Self {
        var copy = self
        copy.removeFirst()
        return copy
    }
}
