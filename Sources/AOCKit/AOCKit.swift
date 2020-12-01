import AppKit
import ArgumentParser
import CLISpinner
import Foundation
import Rainbow

private var puzzleCollection = PuzzleCollection([])
private var savedResults: SavedResults! = nil

private struct Command: ParsableCommand {
    @Option(name: .shortAndLong)
    var day: UInt8?

    @Option(name: .shortAndLong)
    var part: PuzzlePart?

    @Option(name: .shortAndLong, help: "The puzzle input")
    var input: String?

    @Option(name: [.customShort("f"), .customLong("file")], help: "A path to the file containing the puzzle input")
    var inputFile: String?

    private func inputType(for day: UInt8) -> InputType? {
        if let input = input {
            return .string(value: input)
        } else if let inputFile = inputFile {
            return .file(path: inputFile)
        } else if let savedResult = savedResults[day] {
            return savedResult.inputType
        }
        return nil
    }

    func validate() throws {
        guard day == nil || inputType(for: day!) != nil else {
            throw ValidationError("Please specify an input using either --input or --file")
        }
    }

    func run() throws {
        if let day = day, let part = part {
            if let answer = savedResults.answer(for: day, part) {
                try checkPuzzle(for: day, part, matches: answer)
            } else {
                try generateResult(for: day, part, with: inputType(for: day)!)
            }
        } else if let day = day {
            try checkAll(for: day)
        } else {
            try checkAllPuzzles()
        }
    }

    func checkAllPuzzles() throws {
        for day in savedResults.days {
            try checkAll(for: day)
        }
    }

    func checkAll(for day: UInt8) throws {
        for part in [PuzzlePart.partOne, PuzzlePart.partTwo] {
            if let answer = savedResults.answer(for: day, part) {
                try checkPuzzle(for: day, part, matches: answer)
            }
        }
    }

    private func checkPuzzle(for day: UInt8, _ part: PuzzlePart, matches answer: String) throws {
        let s = Spinner(pattern: .dots, text: "Day \(day) part \(part)")
        s.start()
        do {
            let result = try getResult(for: day, part, with: inputType(for: day)!)
            if result == answer {
                s.succeed()
            } else {
                s.fail(text: "Expected \(answer) but got \(result)")
            }
        } catch {
            s.fail()
        }
    }

    private func generateResult(for day: UInt8, _ part: PuzzlePart, with inputType: InputType) throws {
        let result = try getResult(for: day, part, with: inputType)
        copyToClipboard(result)
        print(result)
        if confirm("Is this correct?".cyan.bold) {
            savedResults.update(day, for: part, with: inputType, to: result)
            try savedResults.save()
        }
    }

    private func getResult(for day: UInt8, _ part: PuzzlePart, with inputType: InputType) throws -> String {
        let input = try getInput(for: inputType)
        return try puzzleCollection.runPuzzle(day: day, part: part, input: input)
    }
}

func confirm(_ text: String, default defaultAnswer: Bool = true) -> Bool {
    let options = defaultAnswer ? "[Y/n]" : "[y/N]"
    while true {
        print(text, options.lightBlack, terminator: " ")
        if let input = readLine() {
            if input.count == 0 {
                return defaultAnswer
            } else if isAffirmativeResponse(input) {
                return true
            } else if isNegativeResponse(input) {
                return false
            }
        }
    }
}

func isAffirmativeResponse(_ response: String) -> Bool {
    response.lowercased() == "y" || response.lowercased() == "yes"
}

func isNegativeResponse(_ response: String) -> Bool {
    response.lowercased() == "n" || response.lowercased() == "no"
}

fileprivate func copyToClipboard(_ value: String) {
    let pasteboard = NSPasteboard.general
    pasteboard.declareTypes([.string], owner: nil)
    pasteboard.setString(value, forType: .string)
}

/*
 $ aoc2020
   Run all saved puzzles and check that solutions still return correctly

 $ aoc2020 -d 1
   Run all saved puzzles for the given day and check that solutions
   still return correctly

 $ aoc2020 -d 1 -p 1
   Run saved puzzle for the given day and part, and check that solution
   still returns correctly

 $ aoc2020 -d 1 -p 1 -i 1000
   Run puzzle for given day and part using the provided input, display the
   output, and prompt user to save answer if correct.
 */

public enum AOC {
    public static func run(puzzles: [PuzzleDay], resultsPath: String) {
        puzzleCollection = PuzzleCollection(puzzles)
        savedResults = (try? .load(from: resultsPath)) ?? SavedResults(path: resultsPath)
        Command.main()
    }
}
