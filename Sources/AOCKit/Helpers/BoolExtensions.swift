public extension Bool {
    func exclusiveOr(_ other: Bool) -> Bool {
        (self || other) && self != other
    }
}

infix operator &&=: AssignmentPrecedence
public func &&= (lhs: inout Bool, rhs: Bool) {
    lhs = lhs && rhs
}
