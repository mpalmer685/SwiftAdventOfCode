public struct Stack<Element> {
    private var elements: [Element] = []

    public var isEmpty: Bool { elements.isEmpty }

    public init() {}

    public func peek() -> Element? { elements.last }

    public mutating func push(_ el: Element) {
        elements.append(el)
    }

    public mutating func push(contentsOf elements: some Sequence<Element>) {
        for el in elements {
            push(el)
        }
    }

    public mutating func pop() -> Element? {
        isEmpty ? nil : elements.removeLast()
    }
}

extension Stack: CustomStringConvertible {
    public var description: String {
        String(describing: elements.reversed())
    }
}

extension Stack: Equatable where Element: Equatable {}
extension Stack: Hashable where Element: Hashable {}
