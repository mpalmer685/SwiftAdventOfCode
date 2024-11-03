import Codextended
import Files
import Foundation

private struct Result<Value: Codable>: Codable {
    var part1: Value?
    var part2: Value?
}

private let jsonEncoder = configure(JSONEncoder()) {
    $0.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
}

private struct SavedResult<Value: Codable> {
    private let saveLocation: File

    fileprivate var resultsByDay: [Int: Result<Value>]

    static func load(from path: String) -> SavedResult {
        guard let file = try? File(path: path) else {
            return SavedResult(path: path)
        }

        guard let fileContents = try? file.read(),
              let result = try? JSONDecoder().decode([Int: Result<Value>].self, from: fileContents)
        else {
            fatalError("Failed to decode saved results from \(path)")
        }

        return SavedResult(resultsByDay: result, saveLocation: file)
    }

    init(path: String) {
        resultsByDay = [:]
        do {
            saveLocation = try Folder.current.createFileIfNeeded(at: path)
        } catch {
            fatalError("Failed to create file at \(path): \(error)")
        }
    }

    init(resultsByDay: [Int: Result<Value>], saveLocation: File) {
        self.resultsByDay = resultsByDay
        self.saveLocation = saveLocation
    }

    subscript(day: Int) -> Result<Value>? {
        get { resultsByDay[day] }
        set { resultsByDay[day] = newValue }
    }

    func save() throws {
        try saveLocation.write(resultsByDay.encoded(using: jsonEncoder))
    }
}

struct SavedResults {
    private var answers: SavedResult<String>
    private var benchmarks: SavedResult<Duration>

    init(year: Int) {
        answers = .load(from: "Data/\(year)/Answers.json")

        #if DEBUG
            let benchmarkFile = "\(year)-debug"
        #else
            let benchmarkFile = "\(year)-release"
        #endif
        benchmarks = .load(from: "Benchmarks/\(benchmarkFile).json")
    }

    var days: [Int] {
        answers.resultsByDay.keys.sorted()
    }

    var latest: (day: Int, part: PuzzlePart)? {
        guard var latestDay = days.max() else { return nil }
        while latestDay > 0 {
            guard let result = answers.resultsByDay[latestDay] else { continue }
            if result.part2 != nil {
                return (latestDay, .partTwo)
            } else if result.part1 != nil {
                return (latestDay, .partOne)
            }

            latestDay -= 1
        }

        return nil
    }

    func answer(for day: Int, _ part: PuzzlePart) -> String? {
        let result = answers[day]
        switch part {
            case .partOne:
                return result?.part1
            case .partTwo:
                return result?.part2
        }
    }

    func savedResult(for day: Int, _ part: PuzzlePart) -> (String, Duration?)? {
        guard let answer = answers[day] else { return nil }
        let benchmark = benchmarks[day]
        switch part {
            case .partOne:
                guard let answer = answer.part1 else { return nil }
                return (answer, benchmark?.part1)
            case .partTwo:
                guard let answer = answer.part2 else { return nil }
                return (answer, benchmark?.part2)
        }
    }

    mutating func update(
        _ day: Int,
        for part: PuzzlePart,
        to answer: String,
        duration: Duration
    ) {
        var answers = answers[day] ?? Result()
        var benchmarks = benchmarks[day] ?? Result()
        switch part {
            case .partOne:
                answers.part1 = answer
                benchmarks.part1 = duration
            case .partTwo:
                answers.part2 = answer
                benchmarks.part2 = duration
        }

        self.answers[day] = answers
        self.benchmarks[day] = benchmarks
    }

    mutating func update(_ duration: Duration, for day: Int, _ part: PuzzlePart) {
        var benchmarks = benchmarks[day] ?? Result()
        switch part {
            case .partOne:
                benchmarks.part1 = duration
            case .partTwo:
                benchmarks.part2 = duration
        }

        self.benchmarks[day] = benchmarks
    }

    func save() throws {
        try answers.save()
        try benchmarks.save()
    }
}
