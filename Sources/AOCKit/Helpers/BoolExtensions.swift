public typealias Bit = Bool

public extension Bool {
    init?(_ character: Character) {
        if trueBitCharacters.contains(character) {
            self = true
        } else if falseBitCharacters.contains(character) {
            self = false
        } else {
            return nil
        }
    }

    func exclusiveOr(_ other: Bool) -> Bool {
        (self || other) && self != other
    }
}

infix operator &&=: AssignmentPrecedence
public func &&= (lhs: inout Bool, rhs: Bool) {
    lhs = lhs && rhs
}

public extension Character {
    var bitValue: Bit? { Bit(self) }
}

private let trueBitCharacters = Set("1Tt+Yy")
private let falseBitCharacters = Set("0Ff-Nn")
