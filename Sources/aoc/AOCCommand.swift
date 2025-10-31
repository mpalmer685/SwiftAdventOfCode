import AdventOfCode2020
import AdventOfCode2021
import AdventOfCode2022
import AdventOfCode2023
import AdventOfCode2024
import AdventOfCode2025
import AOCKit
import ArgumentParser

@main
struct AOCCommand: AsyncParsableCommand {
    static let events: [AdventOfCodeEvent] = [aoc2020, aoc2021, aoc2022, aoc2023, aoc2024, aoc2025]

    static let configuration = CommandConfiguration(
        subcommands: [RunCommand.self, StatsCommand.self],
        defaultSubcommand: RunCommand.self,
    )
}
