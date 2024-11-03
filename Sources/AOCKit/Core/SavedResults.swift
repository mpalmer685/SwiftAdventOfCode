import Codextended
import Files
import Foundation

struct SavedResults {
    struct Result: Codable {
        var partOneAnswer: String?
        var partTwoAnswer: String?

        private var partOneDebugTime: Duration?
        private var partTwoDebugTime: Duration?

        private var partOneReleaseTime: Duration?
        private var partTwoReleaseTime: Duration?
    }

    private let encoder = configure(JSONEncoder()) {
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

    func savedResult(for day: Int, _ part: PuzzlePart) -> (String, Duration?)? {
        guard let result = resultsByDay[day] else { return nil }
        switch part {
            case .partOne:
                guard let answer = result.partOneAnswer else { return nil }
                return (answer, result.partOneTime)
            case .partTwo:
                guard let answer = result.partTwoAnswer else { return nil }
                return (answer, result.partTwoTime)
        }
    }

    mutating func update(
        _ day: Int,
        for part: PuzzlePart,
        to answer: String,
        duration: Duration
    ) {
        var result = resultsByDay[day] ?? Result()
        switch part {
            case .partOne:
                result.partOneAnswer = answer
                result.partOneTime = duration
            case .partTwo:
                result.partTwoAnswer = answer
                result.partTwoTime = duration
        }

        resultsByDay[day] = result
    }

    mutating func update(_ duration: Duration, for day: Int, _ part: PuzzlePart) {
        guard var result = resultsByDay[day] else { return }
        switch part {
            case .partOne:
                result.partOneTime = duration
            case .partTwo:
                result.partTwoTime = duration
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

extension SavedResults.Result {
    var partOneTime: Duration? {
        get {
            #if DEBUG
                return partOneDebugTime
            #else
                return partOneReleaseTime
            #endif
        }
        set {
            #if DEBUG
                partOneDebugTime = newValue
            #else
                partOneReleaseTime = newValue
            #endif
        }
    }

    var partTwoTime: Duration? {
        get {
            #if DEBUG
                return partTwoDebugTime
            #else
                return partTwoReleaseTime
            #endif
        }
        set {
            #if DEBUG
                partTwoDebugTime = newValue
            #else
                partTwoReleaseTime = newValue
            #endif
        }
    }
}
