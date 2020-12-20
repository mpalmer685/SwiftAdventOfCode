extension Bool {
    func exclusiveOr(_ other: Bool) -> Bool {
        self != other && (self || other)
    }
}
