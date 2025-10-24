import AOCKit

extension TestablePuzzle {
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

    func run(_ testCases: [TestCase<Input>], for part: PuzzlePart) async throws -> Bool {
        for (input, expected) in testCases {
            do {
                let result = try await part == .partOne
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

extension TestablePuzzleWithConfig {
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

    func run(_ testCases: [TestCase<Input>], for part: PuzzlePart) async throws -> Bool {
        for (input, config, expected) in testCases {
            do {
                let result = try await part == .partOne
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
