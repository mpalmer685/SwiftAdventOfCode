import AOCKit

struct NoSpaceLeftOnDevice: Puzzle {
    static let day = 7

    func part1(input: Input) throws -> Int {
        filesystem(from: input).filter(\.isDirectory).filter { $0.size <= 100_000 }.map(\.size).sum
    }

    func part2(input: Input) throws -> Int {
        let directories = filesystem(from: input).filter(\.isDirectory)
        let root = directories.first { $0.name == "/" }!

        let availableSpace = 70_000_000 - root.size
        let neededSpace = 30_000_000 - availableSpace

        return directories
            .filter { $0.size >= neededSpace }
            .min(of: \.size)!
    }

    private func filesystem(from input: Input) -> [Node<Entry>] {
        let root = Node<Entry>(value: .folder("/"))
        var current = root

        for line in input.lines.dropFirst() {
            if line.raw.hasPrefix("$ cd ") {
                let folder = line.raw.dropFirst(5)
                if folder == ".." {
                    current = current.parent!
                } else {
                    current = current.children.first { $0.name == folder }!
                }
            } else if line.raw.hasPrefix("$ ls") {
                // ls output handled below
            } else if line.raw.hasPrefix("dir ") {
                let name = line.raw.dropFirst(4)
                current.addChild(.folder(String(name)))
            } else {
                let parts = line.words
                let size = parts[0].integer!
                let name = parts[1].raw
                current.addChild(.file(name, size))
            }
        }

        return root.flattened()
    }
}

private enum Entry {
    case file(String, Int)
    case folder(String)
}

private class Node<T> {
    let value: T

    private(set) weak var parent: Node<T>?
    private(set) var children: [Node<T>]

    init(value: T) {
        self.value = value
        children = []
    }

    func addChild(_ node: Node<T>) {
        node.parent = self
        children.append(node)
    }

    func addChild(_ value: T) {
        addChild(Node(value: value))
    }

    func flattened() -> [Node<T>] {
        var flattened: [Node<T>] = [self]
        for child in children {
            flattened.append(contentsOf: child.flattened())
        }
        return flattened
    }
}

private extension Node where T == Entry {
    var isDirectory: Bool {
        if case .folder = value {
            return true
        }
        return false
    }

    var name: String {
        switch value {
            case let .file(name, _):
                name
            case let .folder(name):
                name
        }
    }

    var size: Int {
        switch value {
            case let .file(_, size):
                size
            case .folder:
                children.map(\.size).sum
        }
    }
}
