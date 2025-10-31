import AOCKit

struct Seeds: Puzzle {
    static let day = 5

    // static let rawInput: String? = """
    // seeds: 79 14 55 13

    // seed-to-soil map:
    // 50 98 2
    // 52 50 48

    // soil-to-fertilizer map:
    // 0 15 37
    // 37 52 2
    // 39 0 15

    // fertilizer-to-water map:
    // 49 53 8
    // 0 11 42
    // 42 0 7
    // 57 7 4

    // water-to-light map:
    // 88 18 7
    // 18 25 70

    // light-to-temperature map:
    // 45 77 23
    // 81 45 19
    // 68 64 13

    // temperature-to-humidity map:
    // 0 69 1
    // 1 0 69

    // humidity-to-location map:
    // 60 56 37
    // 56 93 4
    // """

    func part1(input: Input) throws -> Int {
        let (seeds, maps) = parse(input)
        return seeds.min { seed in location(for: seed, in: maps) }!
    }

    func part2(input: Input) throws -> Int {
        let (seedRangeDescriptors, maps) = parse(input)
        let seedRanges = seedRangeDescriptors.chunks(ofCount: 2).map { chunk in
            Range(lowerBound: chunk.first!, length: chunk.last!)
        }

        let locationRanges = seedRanges.flatMap { seedRange in
            maps.reduce([seedRange]) { ranges, map in
                map.destinations(for: ranges)
            }
        }

        guard let min = locationRanges.min(of: \.lowerBound) else {
            fatalError("Couldn't find solution")
        }
        return min
    }

    private func location(for seed: Int, in maps: [Map]) -> Int {
        maps.reduce(seed) { source, map in map.destination(for: source) }
    }

    private func parse(_ input: Input) -> (seeds: [Int], maps: [Map]) {
        let lines = input.lines
        let seeds = lines[0].integers

        var maps = [Map]()
        var categoryLines = [Line]()
        for line in lines[3...] {
            if line.isEmpty {
                maps.append(Map(categoryLines))
                categoryLines = []
                continue
            }
            if !line.raw[0].isNumber {
                continue
            }
            categoryLines.append(line)
        }
        maps.append(Map(categoryLines))
        return (seeds, maps)
    }
}

private struct Map {
    private let categories: [Category]

    init(_ lines: [Line]) {
        categories = lines.map(Category.init).sorted(using: \.sourceRange.lowerBound)
    }

    func destination(for source: Int) -> Int {
        guard let category = categories.first(where: { $0.contains(source) }) else {
            return source
        }

        return category.destination(for: source)
    }

    func destinations(for sources: [Range<Int>]) -> [Range<Int>] {
        var splitRanges = Set<Range<Int>>()
        var rangesToSplit = sources
        while !rangesToSplit.isEmpty {
            let range = rangesToSplit.removeFirst()
            splitRanges.insert(range)
            for category in categories where category.sourceRange.overlaps(range) {
                let (overlappingRange, unmappedRanges) = range.intersect(
                    with: category.sourceRange,
                    addingOffset: category.destinationOffset,
                )
                splitRanges.remove(range)
                splitRanges.insert(overlappingRange)
                rangesToSplit.append(contentsOf: unmappedRanges)
            }
        }

        return Array(splitRanges)
    }

    private struct Category {
        let sourceRange: Range<Int>
        let destinationOffset: Int

        init(_ line: Line) {
            let numbers = line.words.integers
            guard numbers.count == 3 else {
                fatalError("Could not parse map from line: \(line.raw)")
            }

            let destinationStart = numbers[0]
            let sourceStart = numbers[1]
            let rangeLength = numbers[2]

            sourceRange = Range(lowerBound: sourceStart, length: rangeLength)
            destinationOffset = destinationStart - sourceStart
        }

        func contains(_ source: Int) -> Bool {
            sourceRange.contains(source)
        }

        func destination(for source: Int) -> Int {
            guard contains(source) else {
                fatalError("source range (\(sourceRange)) does not contain value \(source)")
            }

            return source + destinationOffset
        }
    }
}

private extension Range<Int> {
    init(lowerBound: Bound, length: Int) {
        self.init(uncheckedBounds: (lowerBound, lowerBound + length))
    }

    func offset(by offset: Int) -> Self {
        lowerBound + offset ..< upperBound + offset
    }

    func intersect(
        with other: Self,
        addingOffset offset: Int,
    ) -> (overlap: Self, unmappedRanges: [Self]) {
        let overlapLowerBound = Swift.max(lowerBound, other.lowerBound)
        let overlapUpperBound = Swift.min(upperBound, other.upperBound)
        let overlap = (overlapLowerBound ..< overlapUpperBound).offset(by: offset)

        var unmappedRanges: [Self] = []
        if lowerBound < other.lowerBound {
            unmappedRanges.append(lowerBound ..< other.lowerBound)
        }
        if upperBound > other.upperBound {
            unmappedRanges.append(other.upperBound ..< upperBound)
        }

        return (overlap, unmappedRanges)
    }
}
