public struct Scanner<C: Collection> {
    private let data: C
    private var cursor: C.Index

    public init(_ data: C) {
        self.data = data
        cursor = data.startIndex
    }

    public var location: C.Index { cursor }

    public var hasMore: Bool { cursor < data.endIndex }

    public func peek() -> C.Element {
        assert(hasMore, "Reached the end")
        return data[cursor]
    }

    public func peek(next count: Int) -> C.SubSequence? {
        guard let end = data.index(cursor, offsetBy: count, limitedBy: data.endIndex) else {
            return nil
        }
        return data[cursor ..< end]
    }

    @discardableResult
    public mutating func next() -> C.Element {
        assert(hasMore, "Reached the end")
        defer { advance() }
        return data[cursor]
    }

    public mutating func scan(while matches: (C.Element) -> Bool) -> C.SubSequence {
        let start = cursor
        while hasMore, matches(data[cursor]) {
            cursor = data.index(after: cursor)
        }
        return data[start ..< cursor]
    }

    public mutating func scan(count: Int) -> C.SubSequence {
        let start = cursor
        cursor = data.index(cursor, offsetBy: count, limitedBy: data.endIndex) ?? data.endIndex
        return data[start ..< cursor]
    }

    @discardableResult
    public mutating func skip(while matches: (C.Element) -> Bool) -> Bool {
        scan(while: matches).isNotEmpty
    }

    @discardableResult
    public mutating func skip(count: Int) -> Bool {
        scan(count: count).isNotEmpty
    }

    private mutating func advance() {
        cursor = data.index(after: cursor)
    }
}

public extension Scanner where C.Element: Equatable {
    mutating func expect(_ element: C.Element) {
        assert(hasMore, "Reached the end")
        if data[cursor] != element {
            fatalError(
                "Expected next character to be '\(element)' but got '\(data[cursor])'"
            )
        }
        advance()
    }

    @discardableResult
    mutating func skip(_ element: C.Element) -> Bool {
        assert(hasMore, "Reached the end")
        if data[cursor] == element {
            advance()
            return true
        }
        return false
    }

    mutating func expect(_ other: some Collection<C.Element>) {
        assert(hasMore, "Reached the end")
        for element in other {
            expect(element)
        }
    }

    @discardableResult
    mutating func skip(_ other: some Collection<C.Element>) -> Bool {
        let start = cursor
        var iterator = other.makeIterator()
        while let next = iterator.next() {
            if !hasMore || peek() != next {
                cursor = start
                return false
            }
            advance()
        }
        return true
    }

    func starts(with other: some Collection<C.Element>) -> Bool {
        guard let next = peek(next: other.count) else { return false }

        for (expected, actual) in zip(other, next) where expected != actual {
            return false
        }

        return true
    }
}

public extension Scanner where C.Element == Character {
    mutating func scanInt() -> Int? {
        let digits = scan(while: \.isNumber)
        return Int(String(digits))
    }

    mutating func tryScanInt() -> Int? {
        let start = cursor
        if let int = scanInt() { return int }
        cursor = start
        return nil
    }

    mutating func tryScanDigit() -> Int? {
        peek().isNumber ? Int(String(next())) : nil
    }
}

public extension Scanner where C == String {
    func starts(with other: String) -> Bool {
        guard let next = peek(next: other.count) else {
            return false
        }

        return next == other
    }

    func starts(with regex: some RegexComponent) -> Bool {
        data[cursor...].starts(with: regex)
    }

    mutating func scan<R>(using pattern: R) -> Regex<R.RegexOutput>.Match? where R: RegexComponent {
        let sample = data[cursor...]
        guard let match = sample.prefixMatch(of: pattern) else {
            return nil
        }

        let matchLength = sample.distance(from: match.range.lowerBound, to: match.range.upperBound)
        skip(count: matchLength)
        return match
    }
}
