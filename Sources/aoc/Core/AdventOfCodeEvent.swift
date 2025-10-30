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

    func input(for puzzle: any Puzzle, suffix: String) -> Input {
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
