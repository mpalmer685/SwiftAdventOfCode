public extension Collection {
    var tail: SubSequence {
        let start = index(startIndex, offsetBy: 1)
        return self[start...]
    }
}
