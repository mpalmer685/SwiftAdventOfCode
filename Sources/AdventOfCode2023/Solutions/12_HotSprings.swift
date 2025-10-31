import AOCKit

struct HotSprings: Puzzle {
    static let day = 12

    // static let rawInput: String? = """
    // ???.### 1,1,3
    // .??..??...?##. 1,1,3
    // ?#?#?#?#?#?#?#? 1,3,1,6
    // ????.#...#... 4,1,1
    // ????.######..#####. 1,6,5
    // ?###???????? 3,2,1
    // """

    func part1(input: Input) throws -> Int {
        parse(input).sum(of: { record in
            countValidArrangements(of: record)
        })
    }

    func part2(input: Input) throws -> Int {
        parse(input).map(unfold).sum(of: { record in
            countValidArrangements(of: record)
        })
    }

    // private func parse(_ input: Input) -> [(pattern: String, runs: [Int])] {
    //     input.lines.map { line in
    //         let segments = line.words
    //         let pattern = segments[0].raw
    //         let runs = Line(segments[1].raw).csvWords.integers
    //         return (pattern, runs)
    //     }
    // }

    // private func unfold(_ record: (String, [Int])) -> (String, [Int]) {
    //     let (pattern, runs) = record
    //     return (
    //         Array(repeating: pattern, count: 5).joined(separator: "?"),
    //         Array(repeating: runs, count: 5).flattened
    //     )
    // }

    private func unfold(_ record: MaintenanceRecord) -> MaintenanceRecord {
        let pattern = Array(repeating: record.pattern, count: 5).joined(separator: "?")
        let runs = Array(repeating: record.runs, count: 5).flattened

        return MaintenanceRecord(pattern: pattern, runs: runs)
    }

    private func parse(_ input: Input) -> [MaintenanceRecord] {
        input.lines.map(MaintenanceRecord.init)
    }

    // private func countValidArrangements(in pattern: String, using runs: [Int]) -> Int {
    //     let countValidArrangements =
    //         recursiveMemoize { (next: (String, [Int]) -> Int, pattern: String, runs: [Int]) ->
    //         Int in
    //             if pattern.isEmpty {
    //                 return runs.isEmpty ? 1 : 0
    //             }
    //             if runs.isEmpty {
    //                 return pattern.contains("#") ? 0 : 1
    //             }
    //             if pattern.count < runs.sum + runs.count - 1 {
    //                 return 0
    //             }

    //             switch pattern[0] {
    //                 case ".":
    //                     return next(pattern[from: 1], runs)
    //                 case "#":
    //                     let runLength = runs[0]
    //                     if pattern.count < runLength ||
    //                         pattern[from: 0, to: runLength].contains(".") ||
    //                         (pattern.count > runLength && pattern[runLength] == "#")
    //                     {
    //                         return 0
    //                     }
    //                     if pattern.count == runLength {
    //                         return 1
    //                     }
    //                     return next(
    //                         pattern[from: runLength + 1],
    //                         Array(runs[1...])
    //                     )
    //                 case "?":
    //                     return next("#" + pattern[from: 1], runs) +
    //                         next("." + pattern[from: 1], runs)
    //                 default:
    //                     fatalError()
    //             }
    //         }

    //     return countValidArrangements(pattern, runs)
    // }

    private func countValidArrangements(of record: MaintenanceRecord) -> Int {
        let countValidArrangements: (MaintenanceRecord) -> Int =
            recursiveMemoize { countNext, record -> Int in
                let status = record.status
                if status == .valid {
                    return 1
                }
                if status == .invalid {
                    return 0
                }

                let pattern = record.pattern,
                    runs = record.runs

                switch pattern[0] {
                    case ".":
                        return countNext(record.next { pattern, _ in
                            pattern.removeFirst()
                        })
                    case "#":
                        let runLength = runs[0]
                        if pattern.count < runLength || pattern[from: 0, to: runLength]
                            .contains(".")
                        {
                            return 0
                        }
                        if pattern.count > runLength, pattern[runLength] == "#" {
                            return 0
                        }
                        if pattern.count == runLength {
                            return 1
                        }

                        return countNext(record.next { pattern, runs in
                            pattern.removeFirst(runLength + 1)
                            runs.removeFirst()
                        })
                    case "?":
                        let countIfOperational = countNext(record.next { pattern, _ in
                            pattern = "." + pattern[from: 1]
                        })
                        let countIfDamaged = countNext(record.next { pattern, _ in
                            pattern = "#" + pattern[from: 1]
                        })
                        return countIfOperational + countIfDamaged
                    default:
                        fatalError()
                }
            }

        return countValidArrangements(record)

        // var memory = [MaintenanceRecord: Int]()

        // func countValidArrangements(of record: MaintenanceRecord) -> Int {
        //     if let calculated = memory[record] {
        //         return calculated
        //     }

        //     var count: Int

        //     switch record.status {
        //         case .valid: count = 1
        //         case .invalid: count = 0
        //         case .unknown:
        //             switch record.pattern[0] {
        //                 case ".":
        //                     let nextRecord = record.next { pattern, _ in
        //                         pattern.removeFirst()
        //                     }
        //                     count = countValidArrangements(of: nextRecord)
        //                 case "#":
        //                     let runLength = record.runs[0]
        //                     count = if record.pattern.count < runLength {
        //                         0
        //                     } else if record.pattern[from: 0, to: runLength].contains(".") {
        //                         0
        //                     } else if record.pattern.count > runLength,
        //                               record.pattern[runLength] == "#"
        //                     {
        //                         0
        //                     } else if record.pattern.count == runLength {
        //                         1
        //                     } else {
        //                         countValidArrangements(of: record.next { pattern, runs in
        //                             pattern.removeFirst(runLength + 1)
        //                             runs.removeFirst()
        //                         })
        //                     }
        //                 case "?":
        //                     let countIfOperational = countValidArrangements(
        //                         of: record
        //                             .next { pattern, _ in
        //                                 pattern = "." + pattern[from: 1]
        //                             }
        //                     )
        //                     let countIfDamaged = countValidArrangements(
        //                         of: record
        //                             .next { pattern, _ in
        //                                 pattern = "#" + pattern[from: 1]
        //                             }
        //                     )
        //                     count = countIfOperational + countIfDamaged
        //                 default:
        //                     fatalError()
        //             }
        //     }

        //     memory[record] = count
        //     return count
        // }

        // return countValidArrangements(of: record)
    }
}

private struct MaintenanceRecord: Hashable {
    let pattern: String
    let runs: [Int]

    init(_ line: Line) {
        let segments = line.words
        pattern = segments[0].raw
        runs = Line(segments[1].raw).csvWords.integers
    }

    init(pattern: String, runs: [Int]) {
        self.pattern = pattern
        self.runs = runs
    }

    var status: Status {
        if pattern.isEmpty {
            return runs.isEmpty ? .valid : .invalid
        }
        if runs.isEmpty {
            return pattern.contains("#") ? .invalid : .valid
        }
        if pattern.count < runs.sum + runs.count - 1 {
            return .invalid
        }
        return .unknown
    }

    func next(using transform: (inout String, inout [Int]) -> Void) -> Self {
        var pattern = pattern
        var runs = runs
        transform(&pattern, &runs)
        return Self(pattern: pattern, runs: runs)
    }

    enum Status {
        case valid, invalid, unknown
    }
}
