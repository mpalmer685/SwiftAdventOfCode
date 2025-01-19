import ArgumentParser

struct AOCCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        subcommands: [RunCommand.self, StatsCommand.self],
        defaultSubcommand: RunCommand.self
    )
}
