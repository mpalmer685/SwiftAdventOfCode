import AOCKit

struct Dive: Puzzle {
    func part1Solution(for input: String) throws -> Int {
        struct SimplePosition: Position {
            let x: Int
            let depth: Int

            static let origin = Self(x: 0, depth: 0)

            fileprivate func next(after command: Command) -> SimplePosition {
                switch command.direction {
                    case .forward:
                        return Self(x: x + command.distance, depth: depth)
                    case .up:
                        return Self(x: x, depth: depth - command.distance)
                    case .down:
                        return Self(x: x, depth: depth + command.distance)
                }
            }
        }

        let commands = try parse(input)
        let finalPosition = follow(commands, startingAt: SimplePosition.origin)
        return finalPosition.x * finalPosition.depth
    }

    func part2Solution(for input: String) throws -> Int {
        struct AimedPosition: Position {
            let x: Int
            let depth: Int
            let aim: Int

            static let origin = Self(x: 0, depth: 0, aim: 0)

            fileprivate func next(after command: Command) -> AimedPosition {
                switch command.direction {
                    case .up:
                        return Self(x: x, depth: depth, aim: aim - command.distance)
                    case .down:
                        return Self(x: x, depth: depth, aim: aim + command.distance)
                    case .forward:
                        return Self(
                            x: x + command.distance,
                            depth: depth + (aim * command.distance),
                            aim: aim
                        )
                }
            }
        }

        let commands = try parse(input)
        let finalPosition = follow(commands, startingAt: AimedPosition.origin)
        return finalPosition.x * finalPosition.depth
    }

    private func parse(_ input: String) throws -> [Command] {
        try getLines(from: input).map(Command.parse)
    }

    private func follow<P: Position>(_ commands: [Command], startingAt origin: P) -> P {
        commands.reduce(origin) { pos, command in pos.next(after: command) }
    }
}

private protocol Position {
    static var origin: Self { get }

    var x: Int { get }
    var depth: Int { get }

    func next(after command: Command) -> Self
}

private struct Command {
    enum Direction: String {
        case forward, up, down
    }

    let direction: Direction
    let distance: Int

    static func parse(_ line: String) throws -> Self {
        let parts = line.split(separator: " ").map(String.init)
        guard let direction = Direction(rawValue: parts[0]), let distance = Int(parts[1]) else {
            throw DiveError.parseError
        }
        return Self(direction: direction, distance: distance)
    }
}

private enum DiveError: Error {
    case parseError
}
