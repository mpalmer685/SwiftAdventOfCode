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
            if let answer = event.savedResults.answer(for: day, part) {
                success = try event.checkPuzzle(for: day, part: part, matches: answer)
            } else {
                try event.generateResult(for: day, part: part)
                success = true
            }
        } else if let day = day {
            success = try event.checkAllParts(for: day)
        } else if latest {
            guard let (day, part) = event.savedResults.latest,
                  let answer = event.savedResults.answer(for: day, part)
            else {
                throw PuzzleError.noSavedResults
            }

            success = try event.checkPuzzle(for: day, part: part, matches: answer)
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
        let result = try runPuzzle(for: day, part: part)
        copyToClipboard(result)
        print(result)
        if confirm("Is this correct?".cyan.bold) {
            savedResults.update(day, for: part, to: result)
            try savedResults.save()
        }
    }

    func checkPuzzle(for day: Int, part: PuzzlePart, matches answer: String) throws -> Bool {
        let spinner = Spinner(pattern: .dots, text: "Day \(day) part \(part)")
        spinner.start()

        do {
            let result = try runPuzzle(for: day, part: part)
            if result == answer {
                spinner.succeed()
                return true
            } else {
                spinner.fail(text: "Expected \(answer) but got \(result)")
            }
        } catch {
            spinner.fail()
            throw error
        }

        return false
    }

    func checkAllParts(for day: Int) throws -> Bool {
        try PuzzlePart.allCases.allSatisfy { part in
            if let answer = savedResults.answer(for: day, part) {
                return try checkPuzzle(for: day, part: part, matches: answer)
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
