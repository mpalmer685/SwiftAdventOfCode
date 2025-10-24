import Foundation

import AOCKit
import CLISpinner
import Files

// MARK: - Saved Results

extension AdventOfCodeEvent {
    var savedResults: SavedResults {
        .init(year: year)
    }

    var latest: (day: Int, part: PuzzlePart)? {
        savedResults.latest
    }

    var next: (day: Int, part: PuzzlePart) {
        guard let (day, part) = latest else {
            return (1, .partOne)
        }

        switch part {
            case .partOne:
                return (day, .partTwo)
            case .partTwo:
                return (day + 1, .partOne)
        }
    }

    func hasSavedResult(for day: Int, part: PuzzlePart) -> Bool {
        savedResults.answer(for: day, part) != nil
    }
}

// MARK: - Input

extension AdventOfCodeEvent {
    func input(for puzzle: any Puzzle) async throws -> Input {
        let puzzleStatic = type(of: puzzle)
        if let input = readInputFile(for: puzzleStatic.day) {
            return input
        }
        if let input = await downloadInput(for: puzzleStatic.day) {
            return input
        }
        throw PuzzleError.noPuzzleInput(puzzleStatic.day)
    }

    private func input(for puzzle: any Puzzle, suffix: String) -> Input {
        let puzzleStatic = type(of: puzzle)
        guard let input = readInputFile(for: puzzleStatic.day, suffix: suffix) else {
            fatalError("Missing input file \(suffix) for day \(puzzleStatic.day)")
        }
        return input
    }

    private func readInputFile(for day: Int, suffix: String? = nil) -> Input? {
        var inputFileName = "day\(day)"
        if let suffix {
            inputFileName += ".\(suffix)"
        }

        guard let inputFolder,
              let inputFile = try? inputFolder.file(named: inputFileName),
              let content = try? inputFile.readAsString()
        else {
            return nil
        }

        return Input(content)
    }

    private var inputFolder: Folder? {
        try? Folder(path: "Data/\(year)")
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
                forHTTPHeaderField: "User-Agent",
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
}

// MARK: - Performance

extension AdventOfCodeEvent {
    func measure<T>(_ work: () throws -> T) rethrows -> (T, Duration) {
        let clock = ContinuousClock()
        var result: T?
        let duration = try clock.measure {
            result = try work()
        }
        return (result!, duration)
    }

    func measure<T>(_ work: () async throws -> T) async rethrows -> (T, Duration) {
        let clock = ContinuousClock()
        var result: T?
        let duration = try await clock.measure {
            result = try await work()
        }
        return (result!, duration)
    }
}

// MARK: - Testing

extension AdventOfCodeEvent {
    func testAllPuzzles() async throws -> Bool {
        let allDays = puzzles.map { type(of: $0).day }.sorted()
        return try await allDays.async.allSatisfy { day in
            try await runTests(for: day)
        }
    }

    func runTests(for day: Int) async throws -> Bool {
        try await PuzzlePart.allCases.async.allSatisfy { part in
            try await runTests(for: day, part: part)
        }
    }

    func runTests(for day: Int, part: PuzzlePart) async throws -> Bool {
        let puzzle = try puzzle(for: day)
        if let puzzle = puzzle as? any TestablePuzzle {
            return try await runTests(for: puzzle, part: part)
        } else if let puzzle = puzzle as? any TestablePuzzleWithConfig {
            return try await runTests(for: puzzle, part: part)
        } else {
            throw PuzzleError.testableNotImplemented
        }
    }

    private func runTests(for puzzle: some TestablePuzzle, part: PuzzlePart) async throws -> Bool {
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
        return try await puzzle.run(testCasesWithInput, for: part)
    }

    private func runTests(
        for puzzle: some TestablePuzzleWithConfig,
        part: PuzzlePart,
    ) async throws -> Bool {
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
        return try await puzzle.run(testCasesWithInput, for: part)
    }
}

// MARK: - Running

extension AdventOfCodeEvent {
    func generateResult(for day: Int, part: PuzzlePart) async throws {
        var saved = savedResults
        let puzzle = try puzzle(for: day)
        let input = try await input(for: puzzle)
        let (result, duration) = try await measure {
            try await run(puzzle, part: part, with: input)
        }
        copyToClipboard(result)
        print("\(result) \("(took \(duration.formattedForDisplay()))".blue)")
        if confirm("Is this correct?".cyan.bold) {
            saved.update(day, for: part, to: result, duration: duration)
            try saved.save()
        }
    }

    func checkPuzzleMatchesSavedAnswer(for day: Int, part: PuzzlePart) async throws -> Bool {
        var savedResults = savedResults
        guard let (savedAnswer, duration) = savedResults.savedResult(for: day, part) else {
            throw PuzzleError.noSavedResults
        }

        let spinner = Spinner(pattern: .dots, text: "Day \(day) part \(part)")
        spinner.start()

        do {
            let puzzle = try puzzle(for: day)
            let input = try await input(for: puzzle)
            let (result, newDuration) = try await measure {
                try await run(puzzle, part: part, with: input)
            }
            guard result == savedAnswer else {
                spinner.fail()
                print("Expected \(savedAnswer) but got \(result).")
                return false
            }

            if let oldDuration = duration {
                let comparison = newDuration.compared(to: oldDuration)
                spinner
                    .succeed(
                        text: "Day \(day) part \(part) took \(newDuration.formattedForDisplay()) (\(comparison)).",
                    )
                if comparison.isImprovement {
                    savedResults.update(newDuration, for: day, part)
                    try savedResults.save()
                }
            } else {
                spinner
                    .succeed(
                        text: "Day \(day) part \(part) took \(newDuration.formattedForDisplay().blue).",
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
        for part in PuzzlePart.allCases where hasSavedResult(for: day, part: part) {
            result &&= try await checkPuzzleMatchesSavedAnswer(for: day, part: part)
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

    private func run(
        _ puzzle: any Puzzle,
        part: PuzzlePart,
        with input: Input,
    ) async throws -> String {
        let runPuzzle = part == .partOne ? puzzle.part1(input:) : puzzle.part2(input:)
        return try await String(describing: runPuzzle(input))
    }
}
