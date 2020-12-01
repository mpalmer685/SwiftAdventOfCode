import Codextended
import Files
import Foundation

struct SavedResults {
    struct Result: Codable {
        var inputType: InputType
        var partOneAnswer: String?
        var partTwoAnswer: String?
    }

    private var resultsByDay: [UInt8 : Result]
    private var saveLocation: File?

    static func load(from path: String) throws -> SavedResults {
        let file = try File(path: path)
        let fileContents = try file.read()
        var result = try JSONDecoder().decode(SavedResults.self, from: fileContents)
        result.saveLocation = file
        return result
    }

    init(path: String) {
        resultsByDay = [:]
        saveLocation = try! Folder.current.createFileIfNeeded(at: path)
    }

    var days: [UInt8] {
        resultsByDay.keys.sorted()
    }

    subscript(day: UInt8) -> Result? {
        resultsByDay[day]
    }

    func answer(for day: UInt8, _ part: PuzzlePart) -> String? {
        let result = resultsByDay[day]
        switch part {
            case .partOne:
                return result?.partOneAnswer
            case .partTwo:
                return result?.partTwoAnswer
        }
    }

    mutating func update(_ day: UInt8, for part: PuzzlePart, with inputType: InputType, to answer: String) {
        var result = resultsByDay[day] ?? Result(inputType: inputType)
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
        try saveLocation.write(self.encoded())
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

extension InputType: Codable {
    enum CodingKeys: CodingKey {
        case file, string
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first

        switch key {
            case .file:
                let path = try container.decode(String.self, forKey: .file)
                self = .file(path: path)
            case .string:
                let value = try container.decode(String.self, forKey: .string)
                self = .string(value: value)
            default:
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: container.codingPath,
                        debugDescription: "Unable to decode InputType enum"
                    )
                )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
            case .file(let path):
                try container.encode(path, forKey: .file)
            case .string(let value):
                try container.encode(value, forKey: .string)
        }
    }
}
