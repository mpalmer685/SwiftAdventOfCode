extension Collection where Element == Int {
    func findPair(totaling goal: Int) -> (Int, Int)? {
        let sorted = self.sorted()
        var low = sorted.startIndex
        var high = sorted.endIndex - 1

        while low < high {
            let first = sorted[low]
            let second = sorted[high]
            let total = first + second

            if total < goal {
                low += 1
            } else if total > goal {
                high -= 1
            } else {
                return (first, second)
            }
        }

        return nil
    }

    func findContiguousRange(totaling goal: Int) -> SubSequence? {
        var low = startIndex
        var high = index(startIndex, offsetBy: 1)

        while high < endIndex {
            let range = self[low ... high]
            let total = range.reduce(0, +)

            if total < goal {
                high = index(after: high)
            } else if total > goal {
                low = index(after: low)
            } else {
                return range
            }
        }

        return nil
    }
}

extension Array where Element: Equatable {
    mutating func remove(_ item: Element) {
        guard let index = firstIndex(of: item) else { return }
        remove(at: index)
    }

    func removing(_ item: Element) -> Self {
        var copy = self
        copy.remove(item)
        return copy
    }
}
