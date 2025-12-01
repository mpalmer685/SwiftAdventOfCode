import AOCKit
import CLISpinner

struct TestEventRunner {
    private let event: AdventOfCodeEvent

    init(event: AdventOfCodeEvent) {
        self.event = event
    }

    func testAllPuzzles() async throws -> Bool {
        let allDays = event.puzzles.map { type(of: $0).day }.sorted()
        return try await allDays.async.allSatisfy { day in
            try await runTests(for: day)
        }
    }

    func runTests(for day: Int) async throws -> Bool {
        try await PuzzlePart.allCases.async.allSatisfy { part in
            try await runTests(for: day, part: part, allowNotTestable: true)
        }
    }

    func runTests(
        for day: Int,
        part: PuzzlePart,
        allowNotTestable: Bool = false,
    ) async throws -> Bool {
        let puzzle = try event.puzzle(for: day)
        if let puzzle = puzzle as? any TestablePuzzle {
            return try await runTests(for: puzzle, part: part, allowNotTestable: allowNotTestable)
        } else if let puzzle = puzzle as? any TestablePuzzleWithConfig {
            return try await runTests(for: puzzle, part: part, allowNotTestable: allowNotTestable)
        } else if !allowNotTestable {
            throw PuzzleError.testableNotImplemented
        } else {
            return true
        }
    }
}

private extension TestEventRunner {
    private func runTests(
        for puzzle: some TestablePuzzle,
        part: PuzzlePart,
        allowNotTestable: Bool,
    ) async throws -> Bool {
        let testCases = puzzle.testCases(for: part)
        guard testCases.isNotEmpty else {
            if allowNotTestable {
                return true
            }
            throw PuzzleError.noTestCases
        }
        let testCasesWithInput = testCases.map { testCase in
            let input = switch testCase.input {
                case let .raw(raw): Input(raw)
                case let .file(suffix): event.input(for: puzzle, suffix: suffix)
            }
            return (input, testCase.output)
        }
        return try await puzzle.run(testCasesWithInput, for: part)
    }

    private func runTests(
        for puzzle: some TestablePuzzleWithConfig,
        part: PuzzlePart,
        allowNotTestable: Bool,
    ) async throws -> Bool {
        let testCases = puzzle.testCases(for: part)
        guard testCases.isNotEmpty else {
            if allowNotTestable {
                return true
            }
            throw PuzzleError.noTestCases
        }
        let testCasesWithInput = testCases.map { testCase in
            let input = switch testCase.input {
                case let .raw(raw): Input(raw)
                case let .file(suffix): event.input(for: puzzle, suffix: suffix)
            }
            return (input, testCase.config, testCase.output)
        }
        return try await puzzle.run(testCasesWithInput, for: part)
    }
}

struct EventRunner {
    private let event: AdventOfCodeEvent
    private let saveBenchmark: Bool
    private var savedResults: SavedResults

    init(event: AdventOfCodeEvent, saveBenchmark: Bool) {
        self.event = event
        self.saveBenchmark = saveBenchmark
        savedResults = event.savedResults
    }

    mutating func checkAllPuzzles() async throws -> Bool {
        var result = true
        for day in savedResults.days {
            for part in PuzzlePart.allCases where event.hasSavedResult(for: day, part: part) {
                result &&= try await checkOutput(for: day, part: part)
            }
        }
        try savedResults.save()
        return result
    }

    mutating func checkAllParts(for day: Int) async throws -> Bool {
        var result = true
        for part in PuzzlePart.allCases where event.hasSavedResult(for: day, part: part) {
            result &&= try await checkOutput(for: day, part: part)
        }
        try savedResults.save()
        return result
    }

    mutating func checkPuzzleMatchesSavedAnswer(
        for day: Int,
        part: PuzzlePart,
    ) async throws -> Bool {
        let result = try await checkOutput(for: day, part: part)
        try savedResults.save()
        return result
    }

    mutating func generateResult(for day: Int, part: PuzzlePart) async throws {
        let puzzle = try event.puzzle(for: day)
        let input = try await event.input(for: puzzle)
        let (result, duration) = try await measure {
            try await run(puzzle, part: part, with: input)
        }
        copyToClipboard(result)
        print("\(result) \("(took \(duration.formattedForDisplay()))".blue)")
        if confirm("Is this correct?".cyan.bold) {
            savedResults.update(day, for: part, to: result, duration: duration)
            try savedResults.save()
        }
    }
}

private extension EventRunner {
    private mutating func checkOutput(for day: Int, part: PuzzlePart) async throws -> Bool {
        guard let (savedAnswer, savedBenchmark) =
            savedResults.savedResult(for: day, part)
        else {
            throw PuzzleError.noSavedResults
        }

        let spinner = Spinner(pattern: .dots, text: "Day \(day) part \(part)")
        spinner.start()

        do {
            let puzzle = try event.puzzle(for: day)
            let input = try await event.input(for: puzzle)
            let (result, newDuration) = try await measure {
                try await run(puzzle, part: part, with: input)
            }
            guard result == savedAnswer else {
                spinner.fail()
                print("Expected \(savedAnswer) but got \(result)")
                return false
            }

            if let savedBenchmark {
                let comparison = newDuration.compared(to: savedBenchmark)
                spinner.succeed(
                    text: "Day \(day) part \(part) took \(newDuration.formattedForDisplay()) (\(comparison)).",
                )
            } else {
                spinner.succeed(
                    text: "Day \(day) part \(part) took \(newDuration.formattedForDisplay()).",
                )
            }

            if saveBenchmark {
                savedResults.addMeasurement(newDuration, for: day, part)
            }
            return true
        } catch {
            spinner.fail()
            throw error
        }
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

// MARK: - Performance

extension EventRunner {
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
