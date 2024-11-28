public struct Queue<Element> {
    private var elements: [Element] = []

    public var isEmpty: Bool { elements.isEmpty }

    public mutating func push(_ el: Element) {
        elements.append(el)
    }

    public mutating func push(contentsOf elements: some Sequence<Element>) {
        for el in elements {
            push(el)
        }
    }

    public mutating func pop() -> Element? {
        isEmpty ? nil : elements.removeFirst()
    }
}

extension Queue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        self.elements = elements
    }
}

extension Queue: CustomStringConvertible {
    public var description: String {
        String(describing: elements)
    }
}

extension Queue: Equatable where Element: Equatable {}
extension Queue: Hashable where Element: Hashable {}
