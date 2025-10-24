import AOCKit
import ArgumentParser

struct RunCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "run",
        abstract: "Run one or more puzzles for an event.",
    )

    @OptionGroup var eventOptions: EventOptions

    @Option(name: .shortAndLong)
    var day: Int?

    @Option(name: .shortAndLong)
    var part: PuzzlePart?

    @Flag(name: .long)
    var next = false

    @Flag(name: .long)
    var latest = false

    @Flag(name: .long)
    var test = false

    func validate() throws {
        if let day, !(1 ... 25).contains(day) {
            throw ValidationError("Day should be between 1 and 25")
        }
    }

    func run() async throws {
        guard let event = AOCCommand.events.first(where: { $0.year == eventOptions.year }) else {
            fatalError("No event defined for \(eventOptions.year)")
        }

        let success = try await test ? runTests(for: event) : run(event)

        throw success ? ExitCode.success : ExitCode.failure
    }

    private func runTests(for event: AdventOfCodeEvent) async throws -> Bool {
        if let day, let part {
            return try await event.runTests(for: day, part: part)
        } else if let day {
            return try await event.runTests(for: day)
        } else if latest {
            guard let (day, part) = event.latest else {
                throw PuzzleError.noSavedResults
            }
            return try await event.runTests(for: day, part: part)
        } else if next {
            let (day, part) = event.next
            return try await event.runTests(for: day, part: part)
        } else {
            return try await event.testAllPuzzles()
        }
    }

    private func run(_ event: AdventOfCodeEvent) async throws -> Bool {
        if let day, let part {
            if event.hasSavedResult(for: day, part: part) {
                return try await event.checkPuzzleMatchesSavedAnswer(for: day, part: part)
            } else {
                try await event.generateResult(for: day, part: part)
                return true
            }
        } else if let day {
            return try await event.checkAllParts(for: day)
        } else if latest {
            guard let (day, part) = event.latest,
                  event.hasSavedResult(for: day, part: part)
            else {
                throw PuzzleError.noSavedResults
            }

            return try await event.checkPuzzleMatchesSavedAnswer(for: day, part: part)
        } else if next {
            let (day, part) = event.next
            try await event.generateResult(for: day, part: part)
            return true
        } else {
            return try await event.checkAllPuzzles()
        }
    }
}
