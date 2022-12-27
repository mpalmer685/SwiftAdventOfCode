import ArgumentParser
import CLISpinner
import Rainbow

struct RunCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "run",
        abstract: "Run one or more puzzles for and event."
    )

    @Option(name: .shortAndLong)
    var day: Int?

    @Option(name: .shortAndLong)
    var part: PuzzlePart?

    @Flag(name: .long)
    var next = false

    @Flag(name: .long)
    var latest = false

    func validate() throws {
        if let day = day, !day.isBetween(1, and: 25) {
            throw ValidationError("Day should be between 1 and 25")
        }
    }

    func run(event: AdventOfCode) throws {
        let success: Bool
        if let day = day, let part = part {
            if event.hasSavedResult(for: day, part) {
                success = try event.checkPuzzleMatchesSavedAnswer(for: day, part)
            } else {
                try event.generateResult(for: day, part: part)
                success = true
            }
        } else if let day = day {
            success = try event.checkAllParts(for: day)
        } else if latest {
            guard let (day, part) = event.savedResults.latest,
                  event.hasSavedResult(for: day, part)
            else {
                throw PuzzleError.noSavedResults
            }

            success = try event.checkPuzzleMatchesSavedAnswer(for: day, part)
        } else if next {
            let (day, part) = nextPuzzle(after: event.savedResults.latest)
            try event.generateResult(for: day, part: part)
            success = true
        } else {
            success = try event.checkAllPuzzles()
        }

        throw success ? ExitCode.success : ExitCode.failure
    }
}

private extension AdventOfCode {
    func generateResult(for day: Int, part: PuzzlePart) throws {
        let (result, duration) = try measure {
            try runPuzzle(for: day, part: part)
        }
        copyToClipboard(result)
        print("\(result) \("(took \(duration))".blue)")
        if confirm("Is this correct?".cyan.bold) {
            savedResults.update(day, for: part, to: result, duration: duration)
            try savedResults.save()
        }
    }

    func checkPuzzleMatchesSavedAnswer(for day: Int, _ part: PuzzlePart) throws -> Bool {
        guard let (savedAnswer, duration) = savedResults.savedResult(for: day, part) else {
            throw PuzzleError.noSavedResults
        }

        let spinner = Spinner(pattern: .dots, text: "Day \(day) part \(part)")
        spinner.start()

        do {
            let (result, newDuration) = try measure { try runPuzzle(for: day, part: part) }
            guard result == savedAnswer else {
                spinner.fail()
                print("Expected \(savedAnswer) but got \(result).")
                return false
            }

            if let oldDuration = duration {
                let comparison = newDuration.compared(to: oldDuration)
                spinner
                    .succeed(text: "Day \(day) part \(part) took \(newDuration) (\(comparison)).")
                if comparison.isImprovement {
                    savedResults.update(newDuration, for: day, part)
                    try savedResults.save()
                }
            } else {
                spinner
                    .succeed(text: "Day \(day) part \(part) took \(newDuration.description.blue).")
                savedResults.update(newDuration, for: day, part)
                try savedResults.save()
            }
            return true
        } catch {
            spinner.fail()
            throw error
        }
    }

    func checkAllParts(for day: Int) throws -> Bool {
        try PuzzlePart.allCases.allSatisfy { part in
            if hasSavedResult(for: day, part) {
                return try checkPuzzleMatchesSavedAnswer(for: day, part)
            } else {
                return true
            }
        }
    }

    func checkAllPuzzles() throws -> Bool {
        try savedResults.days.allSatisfy(checkAllParts)
    }
}

private func nextPuzzle(after puzzle: (day: Int, part: PuzzlePart)?)
    -> (day: Int, part: PuzzlePart)
{
    guard let (day, part) = puzzle else {
        return (1, .partOne)
    }

    switch part {
        case .partOne:
            return (day, .partTwo)
        case .partTwo:
            return (day + 1, .partOne)
    }
}

extension PuzzlePart: ExpressibleByArgument {}
