import Foundation

public extension Character {
    var uppercased: Character { uppercased().first! }
    var lowercased: Character { lowercased().first! }

    var isUppercase: Bool { uppercased == self }

    var alphabeticIndex: Int? {
        guard isASCII, isLetter else { return nil }
        let lower = lowercased
        guard let ascii = lower.asciiValue else { return nil }
        return Int(ascii - 97)
    }

    var alphabeticOrdinal: Int? {
        guard let index = alphabeticIndex else { return nil }
        return index + 1
    }
}
