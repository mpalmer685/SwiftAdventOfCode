import AOCKit

struct HandheldHalting: Puzzle {
    static let day = 8

    func part1() throws -> Int {
        var program = try Program(lines: input().lines.raw)
        return program.run()
    }

    func part2() throws -> Int {
        var program = try Program(lines: input().lines.raw)
        program.repair()
        return program.run()
    }
}

private struct Program {
    private var commands: [Command]
    private var currentIndex = 0
    private var visitedIndices = Set<Int>()
    private var accumulator = 0

    init(lines: [String]) throws {
        commands = try lines.map(Command.init)
    }

    private init(commands: [Command]) {
        self.commands = commands
    }

    mutating func run() -> Int {
        while !visitedIndices.contains(currentIndex), currentIndex < commands.count {
            visitedIndices.insert(currentIndex)
            let command = commands[currentIndex]
            execute(command)
        }
        return accumulator
    }

    private mutating func execute(_ command: Command) {
        if case let .accumulate(amount) = command {
            accumulator += amount
        }
        currentIndex += command.jumpOffset
    }

    enum Command {
        case accumulate(amount: Int)
        case jump(offset: Int)
        case noOp(offset: Int)

        init(_ string: String) throws {
            let pair = string.components(separatedBy: .whitespaces)
            guard pair.count == 2 else {
                throw HandheldHaltingError.invalidProgramLine(line: string)
            }
            guard let value = Int(pair[1]) else {
                throw HandheldHaltingError.invalidProgramLine(line: string)
            }

            switch pair[0] {
                case "acc":
                    self = .accumulate(amount: value)
                case "jmp":
                    self = .jump(offset: value)
                case "nop":
                    self = .noOp(offset: value)
                default:
                    throw HandheldHaltingError.unexpectedCommand(command: pair[0])
            }
        }

        var jumpOffset: Int {
            switch self {
                case .accumulate, .noOp:
                    return 1
                case let .jump(offset):
                    return offset
            }
        }

        var repaired: Self {
            switch self {
                case .accumulate:
                    return self
                case let .jump(offset):
                    return .noOp(offset: offset)
                case let .noOp(offset):
                    return .jump(offset: offset)
            }
        }
    }
}

// Use a graph to find the index of the command that needs to be repaired
extension Program {
    mutating func repair() {
        let graph = graphNodes()
        let fromStart = traverseFromStart(graph)
        let toEnd = traverseToEnd(graph)
        let index = findCorruptedIndex(graph, fromStart, toEnd)
        commands[index] = commands[index].repaired
    }

    private func graphNodes() -> [Int] {
        commands.enumerated().map { index, command in index + command.jumpOffset }
    }

    private func traverseFromStart(_ graph: [Int]) -> [Int] {
        var visited = [Int]()
        var currentIndex = 0
        while !visited.contains(currentIndex), currentIndex < graph.count {
            visited.append(currentIndex)
            currentIndex = graph[currentIndex]
        }
        return visited
    }

    private func traverseToEnd(_ graph: [Int]) -> [Int] {
        var visited = [Int]()
        var toVisit = [graph.count]
        while let nextIndex = toVisit.popLast(), !visited.contains(nextIndex) {
            visited.append(nextIndex)
            toVisit += graph.enumerated().filter { $0.element == nextIndex }.map(\.offset)
        }
        return visited
    }

    private func findCorruptedIndex(_: [Int], _ fromStart: [Int], _ toEnd: [Int]) -> Int {
        for index in fromStart {
            let command = commands[index]
            if case .jump = command, toEnd.contains(index + 1) {
                return index
            } else if case let .noOp(offset) = command, toEnd.contains(index + offset) {
                return index
            }
        }
        return -1
    }
}

// Brute force solution: try every branch
extension Program {
    mutating func runWithRepair() -> Int {
        while !visitedIndices.contains(currentIndex), currentIndex < commands.count {
            let command = commands[currentIndex]
            if case .accumulate = command {
                visitedIndices.insert(currentIndex)
                execute(command)
            } else {
                print("trying fork at", currentIndex, command)
                var subProgram = forked()
                if let result = subProgram.runToEnd() {
                    print("fork worked, got", result)
                    return result
                } else {
                    print("fork didn't work, continuing")
                    visitedIndices.insert(currentIndex)
                    execute(command)
                }
            }
        }
        return accumulator
    }

    private mutating func runToEnd() -> Int? {
        while currentIndex < commands.count {
            if visitedIndices.contains(currentIndex) {
                return nil
            }

            visitedIndices.insert(currentIndex)
            let command = commands[currentIndex]
            execute(command)
        }
        return accumulator
    }

    private func forked() -> Program {
        var program = Program(commands: commands)
        program.commands[currentIndex] = program.commands[currentIndex].repaired
        program.currentIndex = currentIndex
        program.visitedIndices = visitedIndices
        program.accumulator = accumulator
        return program
    }
}

private enum HandheldHaltingError: Error {
    case invalidProgramLine(line: String)
    case unexpectedCommand(command: String)
}
