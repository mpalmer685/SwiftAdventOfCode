import Foundation

// MARK: - String subscript

extension String {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}

// MARK: - String padding

public extension String {
    enum Padding {
        case left
        case right
        case center

        public func pad(
            text: String,
            toLength length: Int,
            withPad filler: Character = " "
        ) -> String {
            let padding: String = {
                let byteLength = text.lengthOfBytes(using: String.Encoding.utf32) / 4
                guard length > byteLength else { return "" }
                let paddingLength = length - byteLength
                return String(repeating: String(filler), count: paddingLength)
            }()

            switch self {
                case .left: return padding + text
                case .right: return text + padding
                case .center:
                    let halfDistance = padding.distance(
                        from: padding.startIndex,
                        to: padding.endIndex
                    ) / 2
                    let halfIndex = padding.index(padding.startIndex, offsetBy: halfDistance)
                    let leftHalf = padding[..<halfIndex]
                    let rightHalf = padding[halfIndex...]
                    return leftHalf + text + rightHalf
            }
        }
    }

    func padded(
        toLength length: Int,
        withPad filler: Character = " ",
        padding: Padding = .right
    ) -> String {
        padding.pad(text: self, toLength: length, withPad: filler)
    }
}

public extension CustomDebugStringConvertible {
    func padded(
        toLength length: Int,
        withPad filler: Character = " ",
        padding: String.Padding = .right
    ) -> String {
        debugDescription.padded(toLength: length, withPad: filler, padding: padding)
    }
}

public extension CustomStringConvertible {
    func padded(
        toLength length: Int,
        withPad filler: Character = " ",
        padding: String.Padding = .right
    ) -> String {
        description.padded(toLength: length, withPad: filler, padding: padding)
    }
}
