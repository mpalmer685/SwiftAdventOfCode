import Foundation

import ArgumentParser
import CLISpinner
import Files
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
    func input(for puzzle: any Puzzle) throws -> Input {
        let puzzleStatic = type(of: puzzle)
        if let input = puzzleStatic.rawInput {
            return Input(input)
        }
        if let input = readInput(for: puzzleStatic.day) {
            return input
        }
        if let input = downloadInput(for: puzzleStatic.day) {
            return input
        }
        throw PuzzleError.noPuzzleInput(puzzleStatic.day)
    }

    private var inputFolder: Folder? {
        try? Folder(path: "Inputs/\(year)")
    }

    private func readInput(for day: Int) -> Input? {
        guard let inputFolder = inputFolder,
              let inputFile = try? inputFolder.file(named: "day\(day)"),
              let content = try? inputFile.readAsString()
        else {
            return nil
        }
        return Input(content)
    }

    private func downloadInput(for day: Int) -> Input? {
        guard let inputFolder = inputFolder,
              let token = authToken,
              let url = URL(string: "https://adventofcode.com/\(year)/day/\(day)/input"),
              let cookie = HTTPCookie(properties: [
                  .domain: "adventofcode.com",
                  .path: "/",
                  .name: "session",
                  .value: token,
              ])
        else {
            return nil
        }

        URLSession.shared.configuration.httpCookieStorage?.setCookie(cookie)

        do {
            let str = try String(contentsOf: url)
            let file = try inputFolder.createFile(named: "day\(day)")
            try file.write(str)

            return Input(str)
        } catch {
            return nil
        }
    }

    private var authToken: String? {
        guard let file = try? File(path: "auth_token"),
              let content = try? file.readAsString()
        else {
            return nil
        }
        let token = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard token.isNotEmpty else {
            return nil
        }
        return token
    }

    func generateResult(for day: Int, part: PuzzlePart) throws {
        let puzzle = try puzzle(for: day)
        let input = try input(for: puzzle)
        let (result, duration) = try measure {
            try run(puzzle, part: part, with: input)
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
            let puzzle = try puzzle(for: day)
            let input = try input(for: puzzle)
            let (result, newDuration) = try measure { try run(puzzle, part: part, with: input) }
            guard result == savedAnswer else {
                spinner.fail()
                print("Expected \(savedAnswer) but got \(result).")
                return false
            }

            if let oldDuration = duration {
                let comparison = newDuration.compared(to: oldDuration)
                spinner
                    .succeed(text: "Day \(day) part \(part) took \(newDuration.formattedForDisplay()) (\(comparison)).")
                if comparison.isImprovement {
                    savedResults.update(newDuration, for: day, part)
                    try savedResults.save()
                }
            } else {
                spinner
                    .succeed(text: "Day \(day) part \(part) took \(newDuration.formattedForDisplay().blue).")
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
