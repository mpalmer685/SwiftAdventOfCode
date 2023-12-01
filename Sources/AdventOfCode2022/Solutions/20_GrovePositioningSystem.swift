import AOCKit

class GrovePositioningSystem: Puzzle {
    static let day = 20

    func part1(input: Input) throws -> Int {
        let numbers = input.lines.integers
        let list = CircularList(numbers)
        list.mix()
        return list.groveCoordinates.sum
    }

    func part2(input: Input) throws -> Int {
        let numbers = input.lines.integers
        let list = CircularList(numbers, key: 811_589_153)
        for _ in 0 ..< 10 {
            list.mix()
        }
        return list.groveCoordinates.sum
    }
}

private class CircularList {
    private class Node {
        let value: Int
        let shift: Int

        var previous: Node?
        var next: Node?

        init(_ value: Int, shift: Int) {
            self.value = value
            self.shift = shift
        }
    }

    private var elements: [Node]

    init(_ elements: [Int], key: Int = 1) {
        self.elements = elements.map { Node($0 * key, shift: ($0 * key) % (elements.count - 1)) }
        for (first, second) in self.elements.adjacentPairs() {
            first.next = second
            second.previous = first
        }
        self.elements.first?.previous = self.elements.last
        self.elements.last?.next = self.elements.first
    }

    var groveCoordinates: [Int] {
        var current = elements.first { $0.value == 0 }!
        var coordinates = [Int]()
        for n in 1 ... 3000 {
            current = current.next!
            if n.isMultiple(of: 1000) {
                coordinates.append(current.value)
            }
        }
        return coordinates
    }

    func mix() {
        for node in elements {
            var shift = abs(node.shift)
            var value = node.value

            // switch direction if it results in fewer swaps
            if shift > elements.count / 2 {
                shift = elements.count - shift - 1
                value = -value
            }

            for _ in 0 ..< shift {
                if value < 0 {
                    swap(node.previous, node)
                } else {
                    swap(node, node.next)
                }
            }
        }
    }

    private func swap(_ lhs: Node?, _ rhs: Node?) {
        guard let prev = lhs?.previous, let next = rhs?.next else { return }

        next.previous = lhs
        lhs?.previous = rhs
        lhs?.next = next
        rhs?.previous = prev
        rhs?.next = lhs
        prev.next = rhs
    }
}
