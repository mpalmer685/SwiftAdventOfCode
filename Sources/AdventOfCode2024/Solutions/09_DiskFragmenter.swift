import AOCKit

struct DiskFragmenter: Puzzle {
    static let day = 9

    func part1(input: Input) throws -> Int {
        var fileSystem = FileSystem.from(input)
        fileSystem.compactBlocks()
        return fileSystem.checksum
    }

    func part2(input: Input) throws -> Int {
        var fileSystem = FileSystem.from(input)
        fileSystem.compactFiles()
        return fileSystem.checksum
    }
}

private struct FileSystem {
    enum Block: CustomDebugStringConvertible, Equatable {
        case file(Int)
        case free

        var debugDescription: String {
            switch self {
                case let .file(id): "\(id)"
                case .free: "."
            }
        }

        var isFree: Bool {
            if case .free = self {
                true
            } else {
                false
            }
        }

        var isFile: Bool {
            if case .file = self {
                true
            } else {
                false
            }
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
                case let (.file(id1), .file(id2)): id1 == id2
                case (.free, .free): true
                default: false
            }
        }
    }

    private var memory: [(block: Block, length: Int)]

    private var blocks: [Block] {
        memory.flatMap { Array(repeating: $0.block, count: $0.length) }
    }

    static func from(_ input: Input) -> Self {
        var memory = [(block: Block, length: Int)]()
        var isFree = false
        var currentId = 0

        for length in input.digits {
            if isFree {
                memory.append((.free, length))
            } else {
                memory.append((.file(currentId), length))
                currentId += 1
            }

            isFree.toggle()
        }

        return Self(memory: memory)
    }

    mutating func compactBlocks() {
        var blocks = blocks

        var firstFreeIndex = blocks.firstIndex(where: \.isFree)
        var lastFileIndex = blocks.lastIndex(where: \.isFile)

        while let freeIndex = firstFreeIndex, let fileIndex = lastFileIndex, freeIndex < fileIndex {
            blocks.swapAt(freeIndex, fileIndex)
            firstFreeIndex = blocks[freeIndex...].firstIndex(where: \.isFree)
            lastFileIndex = blocks[...fileIndex].lastIndex(where: \.isFile)
        }

        memory = blocks.reduce(into: [(block: Block, length: Int)]()) { result, block in
            if let last = result.last, last.block == block {
                result[result.count - 1].length += 1
            } else {
                result.append((block, 1))
            }
        }
    }

    mutating func compactFiles() {
        let files = memory.filter(\.block.isFile).reversed()
        var blocks = blocks

        for (block, length) in files {
            guard let freeStartIndex = blocks.indices.first(where: {
                blocks.hasFreeSpace(at: $0, length: length)
            }) else {
                continue
            }
            guard let fileStartIndex = blocks.firstIndex(of: block) else {
                fatalError("Couldn't file block \(block) in blocks")
            }
            guard freeStartIndex < fileStartIndex else {
                continue
            }

            blocks.replaceSubrange(
                freeStartIndex ..< freeStartIndex + length,
                with: Array(repeating: block, count: length),
            )
            blocks.replaceSubrange(
                fileStartIndex ..< fileStartIndex + length,
                with: Array(repeating: .free, count: length),
            )
        }

        memory = blocks.reduce(into: [(block: Block, length: Int)]()) { result, block in
            if let last = result.last, last.block == block {
                result[result.count - 1].length += 1
            } else {
                result.append((block, 1))
            }
        }
    }

    var checksum: Int {
        blocks.enumerated().sum { index, block in
            if case let .file(id) = block {
                id * index
            } else {
                0
            }
        }
    }
}

private extension [FileSystem.Block] {
    func hasFreeSpace(at index: Index, length: Int) -> Bool {
        let end: Index = index + length
        guard end <= endIndex else {
            return false
        }

        return self[index ..< end].allSatisfy(\.isFree)
    }
}

extension DiskFragmenter: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.raw("12345")).expects(part1: 60),
            .given(.raw("2333133121414131402")).expects(part1: 1928, part2: 2858),
        ]
    }
}
