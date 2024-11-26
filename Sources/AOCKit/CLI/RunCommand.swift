import Foundation

import ArgumentParser
import CLISpinner
import Files
import Rainbow

struct RunCommand: AsyncParsableCommand {
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

    @Flag(name: .long)
    var test = false

    func validate() throws {
        if let day, !day.isBetween(1, and: 25) {
            throw ValidationError("Day should be between 1 and 25")
        }
    }

    func run(event: AdventOfCode) async throws {
        let success: Bool
        if let day, let part {
            if test {
                success = try event.runTests(for: day, part: part)
            } else if event.hasSavedResult(for: day, part) {
                success = try await event.checkPuzzleMatchesSavedAnswer(for: day, part)
            } else {
                try await event.generateResult(for: day, part: part)
                success = true
            }
        } else if let day {
            if test {
                success = try event.runTests(for: day)
            } else {
                success = try await event.checkAllParts(for: day)
            }
        } else if latest {
            guard let (day, part) = event.savedResults.latest,
                  event.hasSavedResult(for: day, part)
            else {
                throw PuzzleError.noSavedResults
            }

            success = try await event.checkPuzzleMatchesSavedAnswer(for: day, part)
        } else if next {
            let (day, part) = nextPuzzle(after: event.savedResults.latest)
            if test {
                success = try event.runTests(for: day, part: part)
            } else {
                try await event.generateResult(for: day, part: part)
                success = true
            }
        } else {
            success = test ? try event.testAllPuzzles() : try await event.checkAllPuzzles()
        }

        throw success ? ExitCode.success : ExitCode.failure
    }
}

private extension AdventOfCode {
    func testAllPuzzles() throws -> Bool {
        let allDays = puzzles.map { type(of: $0).day }.sorted()
        return try allDays.allSatisfy { day in
            try runTests(for: day)
        }
    }

    func runTests(for day: Int) throws -> Bool {
        try PuzzlePart.allCases.allSatisfy { part in
            try runTests(for: day, part: part)
        }
    }

    func runTests(for day: Int, part: PuzzlePart) throws -> Bool {
        let puzzle = try puzzle(for: day)
        if let puzzle = puzzle as? any TestablePuzzle {
            return try runTests(for: puzzle, part: part)
        } else if let puzzle = puzzle as? any TestablePuzzleWithConfig {
            return try runTests(for: puzzle, part: part)
        } else {
            throw PuzzleError.testableNotImplemented
        }
    }

    private func runTests(for puzzle: some TestablePuzzle, part: PuzzlePart) throws -> Bool {
        let testCases = puzzle.testCases(for: part)
        guard testCases.isNotEmpty else {
            throw PuzzleError.noTestCases
        }
        let testCasesWithInput = testCases.map { testCase in
            let input = switch testCase.input {
                case let .raw(raw): Input(raw)
                case let .file(suffix): input(for: puzzle, suffix: suffix)
            }
            return (input, testCase.output)
        }
        return try puzzle.run(testCasesWithInput, for: part)
    }

    private func runTests(
        for puzzle: some TestablePuzzleWithConfig,
        part: PuzzlePart
    ) throws -> Bool {
        let testCases = puzzle.testCases(for: part)
        guard testCases.isNotEmpty else {
            throw PuzzleError.noTestCases
        }
        let testCasesWithInput = testCases.map { testCase in
            let input = switch testCase.input {
                case let .raw(raw): Input(raw)
                case let .file(suffix): input(for: puzzle, suffix: suffix)
            }
            return (input, testCase.config, testCase.output)
        }
        return try puzzle.run(testCasesWithInput, for: part)
    }

    private func input(for puzzle: any Puzzle, suffix: String) -> Input {
        let puzzleStatic = type(of: puzzle)
        let inputFileName = "day\(puzzleStatic.day).\(suffix)"
        guard let inputFolder,
              let inputFile = try? inputFolder.file(named: inputFileName),
              let content = try? inputFile.readAsString()
        else {
            fatalError("Missing input file \(inputFileName)")
        }
        return Input(content)
    }
}

private extension TestablePuzzle {
    typealias TestCase<Input> = (input: Input, output: String)

    func testCases(for part: PuzzlePart) -> [TestCase<InputSource>] {
        testCases.compactMap { testCase in
            if part == .partOne, let expected = testCase.expectedPart1 {
                (testCase.input, String(describing: expected))
            } else if part == .partTwo, let expected = testCase.expectedPart2 {
                (testCase.input, String(describing: expected))
            } else {
                nil
            }
        }
    }

    func run(_ testCases: [TestCase<Input>], for part: PuzzlePart) throws -> Bool {
        for (input, expected) in testCases {
            do {
                let result = try part == .partOne
                    ? String(describing: part1(input: input))
                    : String(describing: part2(input: input))
                if result == expected {
                    print("✅ \(input) -> \(result)")
                } else {
                    print("❌ \(input) -> \(result) (expected \(expected))")
                    return false
                }
            } catch {
                print("❌ \(input) -> \(error)")
                return false
            }
        }

        return true
    }
}

private extension TestablePuzzleWithConfig {
    typealias TestCase<Input> = (input: Input, config: Config, output: String)

    func testCases(for part: PuzzlePart) -> [TestCase<InputSource>] {
        testCases.compactMap { testCase in
            if part == .partOne, let expected = testCase.expectedPart1 {
                (testCase.input, testCase.config, String(describing: expected))
            } else if part == .partTwo, let expected = testCase.expectedPart2 {
                (testCase.input, testCase.config, String(describing: expected))
            } else {
                nil
            }
        }
    }

    func run(_ testCases: [TestCase<Input>], for part: PuzzlePart) throws -> Bool {
        for (input, config, expected) in testCases {
            do {
                let result = try part == .partOne
                    ? String(describing: part1(input: input, config))
                    : String(describing: part2(input: input, config))
                if result == expected {
                    print("✅ \(input) -> \(result)")
                } else {
                    print("❌ \(input) -> \(result) (expected \(expected))")
                    return false
                }
            } catch {
                print("❌ \(input) -> \(error)")
                return false
            }
        }

        return true
    }
}

private extension AdventOfCode {
    func input(for puzzle: any Puzzle) async throws -> Input {
        let puzzleStatic = type(of: puzzle)
        if let input = puzzleStatic.rawInput {
            return Input(input)
        }
        if let input = readInput(for: puzzleStatic.day) {
            return input
        }
        if let input = await downloadInput(for: puzzleStatic.day) {
            return input
        }
        throw PuzzleError.noPuzzleInput(puzzleStatic.day)
    }

    private var inputFolder: Folder? {
        try? Folder(path: "Data/\(year)")
    }

    private func readInput(for day: Int) -> Input? {
        guard let inputFolder,
              let inputFile = try? inputFolder.file(named: "day\(day)"),
              let content = try? inputFile.readAsString()
        else {
            return nil
        }
        return Input(content)
    }

    private func downloadInput(for day: Int) async -> Input? {
        guard confirm("Do you want to download the input for day \(day)?".cyan.bold) else {
            return nil
        }

        guard let inputFolder,
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
            var request = URLRequest(url: url)
            request.setValue(
                "github.com/mpalmer685/SwiftAdventOfCode by mrpalmer685@gmail.com",
                forHTTPHeaderField: "User-Agent"
            )
            let (data, _) = try await URLSession.shared.data(for: request)
            guard let str = String(data: data, encoding: .utf8) else {
                return nil
            }
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

    func generateResult(for day: Int, part: PuzzlePart) async throws {
        let puzzle = try puzzle(for: day)
        let input = try await input(for: puzzle)
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

    func checkPuzzleMatchesSavedAnswer(for day: Int, _ part: PuzzlePart) async throws -> Bool {
        guard let (savedAnswer, duration) = savedResults.savedResult(for: day, part) else {
            throw PuzzleError.noSavedResults
        }

        let spinner = Spinner(pattern: .dots, text: "Day \(day) part \(part)")
        spinner.start()

        do {
            let puzzle = try puzzle(for: day)
            let input = try await input(for: puzzle)
            let (result, newDuration) = try measure { try run(puzzle, part: part, with: input) }
            guard result == savedAnswer else {
                spinner.fail()
                print("Expected \(savedAnswer) but got \(result).")
                return false
            }

            if let oldDuration = duration {
                let comparison = newDuration.compared(to: oldDuration)
                spinner
                    .succeed(
                        text: "Day \(day) part \(part) took \(newDuration.formattedForDisplay()) (\(comparison))."
                    )
                if comparison.isImprovement {
                    savedResults.update(newDuration, for: day, part)
                    try savedResults.save()
                }
            } else {
                spinner
                    .succeed(
                        text: "Day \(day) part \(part) took \(newDuration.formattedForDisplay().blue)."
                    )
                savedResults.update(newDuration, for: day, part)
                try savedResults.save()
            }
            return true
        } catch {
            spinner.fail()
            throw error
        }
    }

    func checkAllParts(for day: Int) async throws -> Bool {
        var result = true
        for part in PuzzlePart.allCases where hasSavedResult(for: day, part) {
            result &&= try await checkPuzzleMatchesSavedAnswer(for: day, part)
        }
        return result
    }

    func checkAllPuzzles() async throws -> Bool {
        var result = true
        for day in savedResults.days {
            result &&= try await checkAllParts(for: day)
        }
        return result
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
