import AdventOfCode2020
import AOCKit
import ArgumentParser

@main
struct AOCCommand: AsyncParsableCommand {
    static let events: [AdventOfCodeEvent] = [aoc2020]

    static let configuration = CommandConfiguration(
        subcommands: [RunCommand.self, StatsCommand.self],
        defaultSubcommand: RunCommand.self
    )
}
