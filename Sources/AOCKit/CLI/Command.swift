import AppKit
import ArgumentParser
import CLISpinner
import Rainbow

struct Command: ParsableCommand {
    static var puzzleCollection: PuzzleCollection!
    static var savedResults: SavedResults!

    @Option(name: .shortAndLong)
    var day: Int?

    @Option(name: .shortAndLong)
    var part: PuzzlePart?

    @Option(name: .shortAndLong, help: "The puzzle input")
    var input: String?

    @Option(
        name: [.customShort("f"), .customLong("file")],
        help: "A path to the file containing the puzzle input"
    )
    var inputFile: String?

    private func inputType(for day: Int) -> InputType? {
        if let input = input {
            return .string(value: input)
        } else if let inputFile = inputFile {
            return .file(path: inputFile)
        } else if let savedResult = Self.savedResults[day] {
            return savedResult.inputType
        }
        return nil
    }

    func validate() throws {
        if let day = day, inputType(for: day) == nil {
            throw ValidationError("Please specify an input using either --input or --file")
        }
        if let day = day, !day.isBetween(0, and: 25) {
            throw ValidationError("Day should be between 0 and 25")
        }
    }

    func run() throws {
        let success: Bool
        if let day = day, let part = part {
            if let answer = Self.savedResults.answer(for: day, part) {
                success = try checkPuzzle(for: day, part, matches: answer)
            } else {
                try generateResult(for: day, part, with: inputType(for: day)!)
                success = true
            }
        } else if let day = day {
            success = try checkAll(for: day)
        } else {
            success = try checkAllPuzzles()
        }

        throw success ? ExitCode.success : ExitCode.failure
    }

    private func checkAllPuzzles() throws -> Bool {
        try Self.savedResults.days.allSatisfy(checkAll)
    }

    private func checkAll(for day: Int) throws -> Bool {
        try PuzzlePart.allCases.allSatisfy { part in
            if let answer = Self.savedResults.answer(for: day, part) {
                return try checkPuzzle(for: day, part, matches: answer)
            } else {
                return true
            }
        }
    }

    private func checkPuzzle(
        for day: Int,
        _ part: PuzzlePart,
        matches answer: String
    ) throws -> Bool {
        let spinner = Spinner(pattern: .dots, text: "Day \(day) part \(part)")
        spinner.start()
        do {
            let result = try getResult(for: day, part, with: inputType(for: day)!)
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

    private func generateResult(
        for day: Int,
        _ part: PuzzlePart,
        with inputType: InputType
    ) throws {
        let result = try getResult(for: day, part, with: inputType)
        copyToClipboard(result)
        print(result)
        if confirm("Is this correct?".cyan.bold) {
            Self.savedResults.update(day, for: part, with: inputType, to: result)
            try Self.savedResults.save()
        }
    }

    private func getResult(
        for day: Int,
        _ part: PuzzlePart,
        with inputType: InputType
    ) throws -> String {
        let input = try getInput(for: inputType)
        return try Self.puzzleCollection.runPuzzle(day: day, part: part, input: input)
    }
}

private func copyToClipboard(_ value: String) {
    let pasteboard = NSPasteboard.general
    pasteboard.declareTypes([.string], owner: nil)
    pasteboard.setString(value, forType: .string)
}
