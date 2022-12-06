import AOCKit
import Foundation

private typealias Stack = [Character]
private typealias Instruction = (Int, Int, Int)

class SupplyStacks: Puzzle {
    static let day = 5

    func part1() throws -> String {
        var stacks = startingState
        for (number, source, dest) in instructions {
            let stack = stacks[source]

            let removed = stack[0 ..< number]

            stacks[source] = Array(stack.dropFirst(number))
            stacks[dest] = removed.reversed() + stacks[dest]
        }

        let tops = stacks.map { $0.first! }

        return String(tops)
    }

    func part2() throws -> String {
        var stacks = startingState
        for (number, source, dest) in instructions {
            let stack = stacks[source]

            let removed = stack[0 ..< number]

            stacks[source] = Array(stack.dropFirst(number))
            stacks[dest] = removed + stacks[dest]
        }

        let tops = stacks.map { $0.first! }

        return String(tops)
    }

    private lazy var startingState: [Stack] = {
        let crateLines = input().lines.raw.split(whereSeparator: \.isEmpty).first!

        // make sure the lines are all the same length
        let longestLine = crateLines.max(by: \.count)!.count
        let padded = crateLines.map { $0.padded(toLength: longestLine, withPad: " ") }

        return stride(from: 1, to: longestLine, by: 4).map { offset in
            padded.map { $0[$0.index($0.startIndex, offsetBy: offset)] }.filter(\.isLetter)
        }
    }()

    private lazy var instructions: [Instruction] = {
        let pattern = NSRegularExpression("move (\\d+) from (\\d+) to (\\d+)")
        return input().lines.raw.compactMap { line -> Instruction? in
            guard let match = pattern.match(line) else { return nil }
            // convert from 1-indexed instructions to 0-indexed arrays
            return (
                Int(match[1])!,
                Int(match[2])! - 1,
                Int(match[3])! - 1
            )
        }
    }()
}

private func printStacks(_ stacks: [Stack]) {
    for (offset, element) in stacks.enumerated() {
        print("\(offset + 1): \(String(element))")
    }
}
