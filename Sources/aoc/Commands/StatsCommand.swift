import ArgumentParser
import AsciiTable

/*
 # Shows both debug and release runtimes for all puzzles, sorted by puzzle
 aoc stats [--sort puzzle]

 # Shows both debug and release runtimes for all puzzles, sorted by debug runtime
 aoc stats --sort debug

 # Shows both debug and release runtimes for all puzzles, sorted by release runtime
 aoc stats --sort release

 # Shows only release runtimes for all puzzles, sorted by runtime
 aoc stats --release

 # Shows the 5 slowest puzzles by release runtime
 aoc stats --release --slowest 5
 */

struct StatsCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "stats",
        abstract: "Show runtime statistics for all puzzles",
    )

    @OptionGroup var eventOptions: EventOptions

    @Option(name: .long, help: "Sort order")
    var sort: SortOption?

    @Flag
    var sortDirection: SortDirection?

    @Flag
    var buildConfig: [BuildConfiguration] = [.debug, .release]

    @Option(name: .long, help: "Show only the specified number of puzzles with the slowest runtime")
    var slowest: Int?

    @Option(name: .long, help: "Show only the specified number of puzzles with the fastest runtime")
    var fastest: Int?

    func validate() throws {
        if slowest != nil, fastest != nil {
            throw ValidationError("Cannot specify both --slowest and --fastest")
        }
        if slowest != nil || fastest != nil, buildConfig.count != 1 {
            throw ValidationError(
                "Cannot specify --slowest or --fastest with multiple build configurations",
            )
        }
    }

    func run() throws {
        let table = Table<Benchmark> {
            Column("Puzzle", content: \.puzzle)
            if buildConfig.contains(.debug) {
                Column("Debug Time") { $0.debugTime?.formattedForComparison() ?? "" }
                    .align(.right)
            }
            if buildConfig.contains(.release) {
                Column("Release Time") { $0.releaseTime?.formattedForComparison() ?? "" }
                    .align(.right)
            }
        }

        var benchmarks = benchmarkData(forYear: eventOptions.year).filter { benchmark in
            (buildConfig.contains(.release) || benchmark.debugTime != nil)
                && (buildConfig.contains(.debug) || benchmark.releaseTime != nil)
        }

        let (sort, direction) = sortOptions()

        switch sort {
            case .puzzle:
                benchmarks.sort(using: \.puzzle)
            case .debug:
                benchmarks.sort(using: \.debugTime)
            case .release:
                benchmarks.sort(using: \.releaseTime)
        }

        if direction == .desc {
            benchmarks.reverse()
        }

        print(table.render(benchmarks))
    }

    private func benchmarkData(forYear year: Int) -> [Benchmark] {
        var allBenchmarks = Benchmark.loadAll(forYear: year)
        let getRuntime: (Benchmark) -> Duration? = buildConfig.contains(.debug)
            ? \.debugTime
            : \.releaseTime

        if let fastest {
            allBenchmarks.sort(using: getRuntime)
            return Array(allBenchmarks.prefix(fastest))
        } else if let slowest {
            allBenchmarks.sort(nilLast: false, using: getRuntime)
            return Array(allBenchmarks.suffix(slowest))
        } else {
            return allBenchmarks
        }
    }

    private func sortOptions() -> (SortOption, SortDirection) {
        if let sort, let sortDirection {
            return (sort, sortDirection)
        }

        let sort = if let sort {
            sort
        } else {
            buildConfig == [.release] ? SortOption.release
                : buildConfig == [.debug] ? .debug
                : .puzzle
        }

        let direction = slowest != nil ? SortDirection.desc : .asc

        return (sort, direction)
    }
}

enum SortOption: String, ExpressibleByArgument {
    case puzzle
    case debug
    case release
}

enum SortDirection: String, EnumerableFlag {
    case asc
    case desc
}

enum BuildConfiguration: String, EnumerableFlag {
    case debug
    case release
}
