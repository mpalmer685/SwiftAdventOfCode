import Files

public protocol Puzzle {
    associatedtype Part1Result: CustomStringConvertible
    associatedtype Part2Result: CustomStringConvertible

    static var day: Int { get }
    static var rawInput: String? { get }

    func part1() throws -> Part1Result
    func part2() throws -> Part2Result
}

public extension Puzzle {
    static var rawInput: String? { nil }

    func part1() throws -> Int {
        throw PuzzleError.partNotImplemented(1)
    }

    func part2() throws -> Int {
        throw PuzzleError.partNotImplemented(2)
    }
}

public extension Puzzle {
    func input(_ caller: StaticString = #file) -> Input {
        if let raw = Self.rawInput {
            return Input(raw)
        }

        do {
            let file = try File(path: caller.description)
            var parent = file.parent
            while let location = parent {
                if let inputFolder = try? location.subfolder(named: "Inputs") {
                    let inputFile = try inputFolder.file(named: "day\(Self.day)")
                    let inputContent = try inputFile.readAsString()
                    return Input(inputContent)
                }
                parent = parent?.parent
            }
        } catch {}

        fatalError("Could not find input for day \(Self.day)")
    }
}
