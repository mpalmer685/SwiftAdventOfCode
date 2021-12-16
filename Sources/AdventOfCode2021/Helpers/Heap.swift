//    Copyright (c) 2016 Matthijs Hollemans and contributors
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in
//    all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//    THE SOFTWARE.

struct Heap<T> {
    private(set) var nodes = [T]()

    private var orderCriteria: (T, T) -> Bool

    /**
     Creates an empty heap.
     - Parameter sort: determines whether this is a min-heap or max-heap. For Comparable data types, > makes a max-heap and < makes a min-heap.
     */
    init(sort: @escaping (T, T) -> Bool) {
        orderCriteria = sort
    }

    private mutating func configureHeap(from array: [T]) {
        nodes = array
        for i in stride(from: nodes.count / 2 - 1, through: 0, by: -1) {
            shiftDown(i)
        }
    }

    var isEmpty: Bool { nodes.isEmpty }

    var count: Int { nodes.count }

    func peek() -> T? {
        nodes.first
    }

    mutating func insert(_ value: T) {
        nodes.append(value)
        shiftUp(nodes.count - 1)
    }

    mutating func replace(at i: Int, value: T) {
        guard i < nodes.count else { return }

        remove(at: i)
        insert(value)
    }

    @discardableResult mutating func remove() -> T? {
        guard !nodes.isEmpty else { return nil }

        if nodes.count == 1 {
            return nodes.removeLast()
        } else {
            let value = nodes[0]
            nodes[0] = nodes.removeLast()
            shiftDown(0)
            return value
        }
    }

    @discardableResult mutating func remove(at index: Int) -> T? {
        guard index < nodes.count else { return nil }

        let size = nodes.count - 1
        if index != size {
            nodes.swapAt(index, size)
            shiftDown(from: index, to: size)
            shiftUp(index)
        }
        return nodes.removeLast()
    }

    private mutating func shiftUp(_ index: Int) {
        var childIndex = index
        let child = nodes[childIndex]
        var parentIndex = parentIndex(of: childIndex)

        while childIndex > 0, orderCriteria(child, nodes[parentIndex]) {
            nodes[childIndex] = nodes[parentIndex]
            childIndex = parentIndex
            parentIndex = self.parentIndex(of: childIndex)
        }

        nodes[childIndex] = child
    }

    private mutating func shiftDown(from index: Int, to endIndex: Int) {
        let leftChildIndex = leftChildIndex(of: index)
        let rightChildIndex = leftChildIndex + 1

        var first = index
        if leftChildIndex < endIndex, orderCriteria(nodes[leftChildIndex], nodes[first]) {
            first = leftChildIndex
        }
        if rightChildIndex < endIndex, orderCriteria(nodes[rightChildIndex], nodes[first]) {
            first = rightChildIndex
        }
        if first == index { return }

        nodes.swapAt(index, first)
        shiftDown(from: first, to: endIndex)
    }

    private mutating func shiftDown(_ index: Int) {
        shiftDown(from: index, to: nodes.count)
    }

    @inline(__always) private func parentIndex(of i: Int) -> Int {
        (i - 1) / 2
    }

    @inline(__always) private func leftChildIndex(of i: Int) -> Int {
        2 * i + 1
    }
}

extension Heap where T: Equatable {
    func index(of node: T) -> Int? {
        nodes.firstIndex(of: node)
    }
}
