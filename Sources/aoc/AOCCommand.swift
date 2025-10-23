import AdventOfCode2020
import AdventOfCode2021
import AdventOfCode2022
import AOCKit
import ArgumentParser

@main
struct AOCCommand: AsyncParsableCommand {
    static let events: [AdventOfCodeEvent] = [aoc2020, aoc2021, aoc2022]

    static let configuration = CommandConfiguration(
        subcommands: [RunCommand.self, StatsCommand.self],
        defaultSubcommand: RunCommand.self
    )
}
