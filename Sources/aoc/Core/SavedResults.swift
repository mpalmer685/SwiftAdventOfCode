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

        guard let fileContents = try? file.read() else {
            fatalError("Failed to read contents of file at \(path)")
        }
        if fileContents.isEmpty {
            return SavedResult(path: path)
        }

        guard let result = try? JSONDecoder().decode([Int: Result<Value>].self, from: fileContents)
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

    var days: [Int] {
        resultsByDay.keys.sorted()
    }

    func save() throws {
        try saveLocation.write(resultsByDay.encoded(using: jsonEncoder))
    }
}

private let benchmarkWindowSize = 10

private typealias SavedBenchmarks = SavedResult<[Duration]>

private extension SavedBenchmarks {
    static func load(fromFile fileName: String) -> SavedBenchmarks {
        load(from: "Benchmarks/\(fileName).json")
    }
}

private extension SavedBenchmarks {
    func benchmark(for day: Int, _ part: PuzzlePart) -> Duration.SavedBenchmark? {
        let measurements = switch part {
            case .partOne: self[day]?.part1
            case .partTwo: self[day]?.part2
        }
        guard let measurements, measurements.isNotEmpty else {
            return nil
        }

        let measurementsInMilliseconds = measurements.map(\.inMilliseconds)
        let mean =
            measurementsInMilliseconds.reduce(0, +) / Double(measurementsInMilliseconds.count)
        guard measurementsInMilliseconds.count > 1 else {
            return (.milliseconds(mean), nil)
        }

        let numerator = measurementsInMilliseconds.reduce(0) { total, duration in
            total + pow(duration - mean, 2)
        }
        let standardDeviation = sqrt(numerator / Double(measurementsInMilliseconds.count))

        return (.milliseconds(mean), standardDeviation)
    }

    mutating func addMeasurement(
        _ duration: Duration,
        for day: Int,
        _ part: PuzzlePart,
    ) {
        var results = self[day] ?? Result()
        switch part {
            case .partOne:
                var measurements = results.part1 ?? []
                measurements.append(duration)
                while measurements.count > benchmarkWindowSize {
                    measurements.removeFirst()
                }
                results.part1 = measurements
            case .partTwo:
                var measurements = results.part2 ?? []
                measurements.append(duration)
                while measurements.count > benchmarkWindowSize {
                    measurements.removeFirst()
                }
                results.part2 = measurements
        }

        self[day] = results
    }
}

public struct SavedResults {
    private var answers: SavedResult<String>
    private var benchmarks: SavedBenchmarks

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
        answers.days
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

    func savedResult(
        for day: Int,
        _ part: PuzzlePart,
    ) -> (answer: String, Duration.SavedBenchmark?)? {
        guard let answer = answers[day] else { return nil }
        let benchmark = benchmarks.benchmark(for: day, part)
        switch part {
            case .partOne:
                guard let answer = answer.part1 else { return nil }
                return (answer, benchmark)
            case .partTwo:
                guard let answer = answer.part2 else { return nil }
                return (answer, benchmark)
        }
    }

    mutating func update(
        _ day: Int,
        for part: PuzzlePart,
        to answer: String,
        duration: Duration,
    ) {
        var answers = answers[day] ?? Result()
        switch part {
            case .partOne:
                answers.part1 = answer
            case .partTwo:
                answers.part2 = answer
        }
        self.answers[day] = answers

        benchmarks.addMeasurement(duration, for: day, part)
    }

    mutating func addMeasurement(_ duration: Duration, for day: Int, _ part: PuzzlePart) {
        benchmarks.addMeasurement(duration, for: day, part)
    }

    func save() throws {
        try answers.save()
        try benchmarks.save()
    }
}

struct PuzzleDescriptor: Hashable, Sendable {
    let day: Int
    let part: PuzzlePart
}

extension PuzzleDescriptor: Comparable {
    static func < (lhs: PuzzleDescriptor, rhs: PuzzleDescriptor) -> Bool {
        if lhs.day == rhs.day {
            lhs.part.rawValue < rhs.part.rawValue
        } else {
            lhs.day < rhs.day
        }
    }
}

extension PuzzleDescriptor: CustomStringConvertible {
    var description: String {
        "Day \(day), Part \(part.rawValue)"
    }
}

struct Benchmark {
    let year: Int
    let puzzle: PuzzleDescriptor
    let debugTime: Duration?
    let releaseTime: Duration?

    static func loadAll(forYear year: Int) -> [Self] {
        let debugBenchmarks = SavedBenchmarks.load(fromFile: "\(year)-debug")
        let releaseBenchmarks = SavedBenchmarks.load(fromFile: "\(year)-release")

        let days = Set(debugBenchmarks.days)
            .union(releaseBenchmarks.days)
            .sorted()

        return days
            .flatMap { day in
                [
                    Benchmark(
                        year: year,
                        puzzle: PuzzleDescriptor(day: day, part: .partOne),
                        debugTime: debugBenchmarks.benchmark(for: day, .partOne)?.mean,
                        releaseTime: releaseBenchmarks.benchmark(for: day, .partOne)?.mean,
                    ),
                    Benchmark(
                        year: year,
                        puzzle: PuzzleDescriptor(day: day, part: .partTwo),
                        debugTime: debugBenchmarks.benchmark(for: day, .partTwo)?.mean,
                        releaseTime: releaseBenchmarks.benchmark(for: day, .partTwo)?.mean,
                    ),
                ]
            }
            .filter { benchmark in
                benchmark.debugTime != nil || benchmark.releaseTime != nil
            }
    }
}
