import AOCKit
import ArgumentParser
import Rainbow

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
        if day == nil, part != nil {
            throw ValidationError("Cannot specify --part without --day")
        }
        if day != nil, next {
            throw ValidationError("Cannot specify both --day and --next")
        }
        if day != nil, latest {
            throw ValidationError("Cannot specify both --day and --latest")
        }
        if next, latest {
            throw ValidationError("Cannot specify both --next and --latest")
        }
        if let day, !(1 ... 25).contains(day) {
            throw ValidationError("Day should be between 1 and 25")
        }
        if case let .specific(year) = eventOptions.year,
           !AOCCommand.events.contains(where: { $0.year == year })
        {
            throw ValidationError("No event defined for year \(year)")
        }
        if case .all = eventOptions.year, day != nil || part != nil || next || latest {
            throw ValidationError(
                "The 'run' command with --year all cannot be combined with --day, --part, --next, or --latest",
            )
        }
    }

    func run() async throws {
        let success = try await events.async.allSatisfy { event in
            if case .all = eventOptions.year {
                print(String(describing: event.year).bold.underline)
            }
            return try await test ? runTests(for: event) : run(event)
        }

        throw success ? ExitCode.success : ExitCode.failure
    }

    private var events: [AdventOfCodeEvent] {
        switch eventOptions.year {
            case .all:
                return AOCCommand.events
            case let .specific(year):
                guard let event = AOCCommand.events.first(where: { $0.year == year }) else {
                    fatalError("No event defined for \(year)")
                }
                return [event]
        }
    }

    private func runTests(for event: AdventOfCodeEvent) async throws -> Bool {
        let runner = TestEventRunner(event: event)
        if let day, let part {
            return try await runner.runTests(for: day, part: part)
        } else if let day {
            return try await runner.runTests(for: day)
        } else if latest {
            guard let (day, part) = event.latest else {
                throw PuzzleError.noSavedResults
            }
            return try await runner.runTests(for: day, part: part)
        } else if next {
            let (day, part) = event.next
            return try await runner.runTests(for: day, part: part)
        } else {
            return try await runner.testAllPuzzles()
        }
    }

    private func run(_ event: AdventOfCodeEvent) async throws -> Bool {
        var runner = EventRunner(event: event)
        if let day, let part {
            if event.hasSavedResult(for: day, part: part) {
                return try await runner.checkPuzzleMatchesSavedAnswer(for: day, part: part)
            } else {
                try await runner.generateResult(for: day, part: part)
                return true
            }
        } else if let day {
            return try await runner.checkAllParts(for: day)
        } else if latest {
            guard let (day, part) = event.latest,
                  event.hasSavedResult(for: day, part: part)
            else {
                throw PuzzleError.noSavedResults
            }

            return try await runner.checkPuzzleMatchesSavedAnswer(for: day, part: part)
        } else if next {
            let (day, part) = event.next
            try await runner.generateResult(for: day, part: part)
            return true
        } else {
            return try await runner.checkAllPuzzles()
        }
    }
}
