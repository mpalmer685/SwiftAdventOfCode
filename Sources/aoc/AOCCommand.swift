import AOCKit
import ArgumentParser

@main
struct AOCCommand: AsyncParsableCommand {
    static let events: [AdventOfCodeEvent] = []

    static let configuration = CommandConfiguration(
        subcommands: [RunCommand.self],
        defaultSubcommand: RunCommand.self
    )
}
