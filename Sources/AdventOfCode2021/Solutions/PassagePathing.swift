import AOCKit

private let testInput1 = """
start-A
start-b
A-c
A-b
b-d
A-end
b-end
"""

private let testInput2 = """
dc-end
HN-start
start-kj
dc-start
dc-HN
LN-dc
HN-end
kj-sa
kj-HN
kj-dc
"""

private let testInput3 = """
fs-end
he-DX
fs-he
start-DX
pj-DX
end-zg
zg-sl
zg-pj
pj-he
RW-he
fs-DX
pj-RW
zg-RW
start-pj
he-WI
zg-he
pj-fs
start-RW
"""

struct PassagePathing: Puzzle {
    func part1Solution(for input: String) throws -> Int {
        let startCave = parseCaves(from: input)
        return countPaths(from: startCave, using: VisitOnceHistory())
    }

    func part2Solution(for input: String) throws -> Int {
        let startCave = parseCaves(from: input)
        return countPaths(from: startCave, using: VisitOneTwiceHistory())
    }

    private func parseCaves(from input: String) -> Cave {
        var caves: [Cave.CaveType: Cave] = [:]
        for line in getLines(from: input) {
            let names = line.components(separatedBy: "-")
            let firstType = Cave.CaveType(name: names[0])
            let secondType = Cave.CaveType(name: names[1])

            let first = caves[firstType] ?? Cave(type: firstType)
            let second = caves[secondType] ?? Cave(type: secondType)

            first.addConnection(to: second)
            second.addConnection(to: first)

            caves[firstType] = first
            caves[secondType] = second
        }

        guard let start = caves[.start] else {
            fatalError("Did not parse a 'start' cave")
        }
        return start
    }
}

private func countPaths(from cave: Cave, using history: History) -> Int {
    var history = history
    history.visit(cave: cave)
    guard cave.type != .end else { return 1 }

    return cave.connections
        .filter { history.canVisit(cave: $0) }
        .map { countPaths(from: $0, using: history) }
        .reduce(0, +)
}

private class Cave {
    enum CaveType: Hashable {
        case start, end
        case big(String)
        case small(String)

        init(name: String) {
            if name == "start" {
                self = .start
            } else if name == "end" {
                self = .end
            } else if name.uppercased() == name {
                self = .big(name)
            } else {
                self = .small(name)
            }
        }
    }

    let type: CaveType
    var connections: Set<Cave>

    init(type: CaveType) {
        self.type = type
        connections = []
    }

    func addConnection(to other: Cave) {
        connections.insert(other)
    }
}

extension Cave: Hashable {
    static func == (lhs: Cave, rhs: Cave) -> Bool {
        lhs.type == rhs.type
    }

    public func hash(into hasher: inout Hasher) {
        type.hash(into: &hasher)
    }
}

extension Cave: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(type): \(connections.map { "\($0.type)" })"
    }
}

private protocol History {
    mutating func visit(cave: Cave)
    func canVisit(cave: Cave) -> Bool
}

private struct VisitOnceHistory: History {
    private var visited: Set<Cave> = []

    mutating func visit(cave: Cave) {
        visited.insert(cave)
    }

    func canVisit(cave: Cave) -> Bool {
        switch cave.type {
            case .start: return false
            case .big, .end: return true
            default: return !visited.contains(cave)
        }
    }
}

private struct VisitOneTwiceHistory: History {
    private var visited: Set<Cave> = []
    private var revisitedCave: Cave?

    mutating func visit(cave: Cave) {
        if case .small = cave.type, visited.contains(cave) {
            revisitedCave = cave
        } else {
            visited.insert(cave)
        }
    }

    func canVisit(cave: Cave) -> Bool {
        switch cave.type {
            case .start: return false
            case .big, .end: return true
            default: return !visited.contains(cave) || revisitedCave == nil
        }
    }
}
