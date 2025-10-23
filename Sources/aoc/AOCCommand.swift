import AOCKit
import ArgumentParser

@main
struct AOCCommand: AsyncParsableCommand {
    static let events: [AdventOfCodeEvent] = []

    static let configuration = CommandConfiguration(
        subcommands: [RunCommand.self, StatsCommand.self],
        defaultSubcommand: RunCommand.self
    )
}
