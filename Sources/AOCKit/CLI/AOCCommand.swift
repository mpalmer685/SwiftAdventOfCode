import ArgumentParser

struct AOCCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        subcommands: [RunCommand.self],
        defaultSubcommand: RunCommand.self
    )
}
