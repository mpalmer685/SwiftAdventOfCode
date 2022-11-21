import Codextended
import Files
import Foundation

struct SavedResults {
    struct Result: Codable {
        var partOneAnswer: String?
        var partTwoAnswer: String?
    }

    private let encoder = configure(JSONEncoder()) {
        guard #available(macOS 10.15, *) else {
            fatalError("Platform not supported")
        }
        $0.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    }

    private var resultsByDay: [Int: Result]
    private var saveLocation: File?

    static func load(from path: String) -> SavedResults {
        do {
            let file = try File(path: path)
            let fileContents = try file.read()
            var result = try JSONDecoder().decode(SavedResults.self, from: fileContents)
            result.saveLocation = file
            return result
        } catch {
            return SavedResults(path: path)
        }
    }

    init(path: String) {
        resultsByDay = [:]
        // swiftlint:disable:next force_try
        saveLocation = try! Folder.current.createFileIfNeeded(at: path)
    }

    var days: [Int] {
        resultsByDay.keys.sorted()
    }

    subscript(day: Int) -> Result? {
        resultsByDay[day]
    }

    var latest: (day: Int, part: PuzzlePart)? {
        guard var latestDay = days.max() else { return nil }
        while latestDay > 0 {
            guard let result = resultsByDay[latestDay] else { continue }
            if result.partTwoAnswer != nil {
                return (latestDay, .partTwo)
            } else if result.partOneAnswer != nil {
                return (latestDay, .partOne)
            }

            latestDay -= 1
        }

        return nil
    }

    func answer(for day: Int, _ part: PuzzlePart) -> String? {
        let result = resultsByDay[day]
        switch part {
            case .partOne:
                return result?.partOneAnswer
            case .partTwo:
                return result?.partTwoAnswer
        }
    }

    mutating func update(
        _ day: Int,
        for part: PuzzlePart,
        to answer: String
    ) {
        var result = resultsByDay[day] ?? Result()
        switch part {
            case .partOne:
                result.partOneAnswer = answer
            case .partTwo:
                result.partTwoAnswer = answer
        }

        resultsByDay[day] = result
    }

    func save() throws {
        guard let saveLocation = saveLocation else { return }
        try saveLocation.write(encoded(using: encoder))
    }
}

extension SavedResults: Codable {
    public init(from decoder: Decoder) throws {
        resultsByDay = try decoder.decode("resultsByDay")
    }

    public func encode(to encoder: Encoder) throws {
        try encoder.encode(resultsByDay, for: "resultsByDay")
    }
}
