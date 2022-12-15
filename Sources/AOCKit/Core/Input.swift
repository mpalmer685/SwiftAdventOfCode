import Files
import Foundation

public protocol StringInput {
    init(_ raw: String)

    var raw: String { get }
    var trimmed: Self { get }

    var integer: Int? { get }
    var characters: [Character] { get }
    var digits: [Int] { get }
    var bits: [Bit] { get }

    var lines: [Line] { get }
    var words: [Word] { get }
    var csvWords: [Word] { get }

    func words(separatedBy: CharacterSet) -> [Word]
    func words(separatedBy: String) -> [Word]
}

public extension StringInput {
    var trimmed: Self { Self(raw.trimmingCharacters(in: .whitespacesAndNewlines)) }

    var integer: Int? { Int(raw) }
    var characters: [Character] { Array(raw) }
    var digits: [Int] { raw.compactMap(\.wholeNumberValue) }
    var bits: [Bit] { raw.compactMap(\.bitValue) }

    var lines: [Line] { raw.components(separatedBy: .newlines).map(Line.init) }
    var words: [Word] { self.words(separatedBy: .whitespaces) }
    var csvWords: [Word] { words(separatedBy: .comma) }

    func words(separatedBy: CharacterSet) -> [Word] {
        raw.components(separatedBy: separatedBy).filter(\.isNotEmpty).map(Word.init)
    }

    func words(separatedBy: String) -> [Word] {
        raw.components(separatedBy: separatedBy).filter(\.isNotEmpty).map(Word.init)
    }
}

public extension StringInput {
    var isEmpty: Bool { raw.isEmpty }
    var isNotEmpty: Bool { !isEmpty }

    func trimmingCharacters(in set: CharacterSet) -> Self {
        Self(raw.trimmingCharacters(in: set))
    }
}

public final class Input: StringInput {
    public let raw: String

    public init(_ raw: String) {
        self.raw = raw.trimmingCharacters(in: .newlines)
    }
}

public final class Line: StringInput {
    public let raw: String

    public init(_ raw: String) {
        self.raw = raw
    }

    public var lines: [Line] { [self] }

    public var integers: [Int] {
        let matches = NSRegularExpression("(-?\\d+)").matches(in: raw)
        return matches.compactMap { Int($0[1]) }
    }
}

public final class Word: StringInput {
    public let raw: String

    public init(_ raw: String) {
        self.raw = raw
    }

    public lazy var lines: [Line] = { [Line(raw)] }()
    public var words: [Word] { [self] }
    public var csvWords: [Word] { [self] }
}

public extension Collection where Element: StringInput {
    var raw: [String] { map(\.raw) }
    var integers: [Int] { compactMap(\.integer) }
    var characters: [[Character]] { map(\.characters) }
    var digits: [[Int]] { map(\.digits) }
    var bits: [[Bit]] { map(\.bits) }

    var trimmed: [Element] { map(\.trimmed) }
    var lines: [[Line]] { map(\.lines) }
    var words: [[Word]] { map(\.words) }
    var csvWords: [[Word]] { map(\.csvWords) }

    func words(separatedBy: CharacterSet) -> [[Word]] {
        map { $0.words(separatedBy: separatedBy) }
    }

    func words(separatedBy: String) -> [[Word]] {
        map { $0.words(separatedBy: separatedBy) }
    }
}

public extension Collection where Element: Collection, Element.Element: StringInput {
    var raw: [[String]] { map(\.raw) }
    var integers: [[Int]] { map(\.integers) }
}

public extension Collection where Element == Character {
    var integers: [Int] { compactMap(\.wholeNumberValue) }
    var bits: [Bit] { compactMap(\.bitValue) }
}

public extension CharacterSet {
    static let comma = CharacterSet(charactersIn: ",")
}
