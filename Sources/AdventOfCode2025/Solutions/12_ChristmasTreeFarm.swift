import AOCKit

struct ChristmasTreeFarm: Puzzle {
    static let day = 12

    func part1(input: Input) async throws -> Int {
        let sections = input.lines.split(whereSeparator: \.isEmpty)
        let shapes = sections.dropLast().map { parseShape(from: $0) }
        let regions = sections.last!.map { parseRegion(from: $0, shapes: shapes) }

        let obviousFits = regions.count { region in
            // if the total area of the region is at least the sum of the shape areas, it will
            // definitely fit without needing to pack more tightly
            let unpackedArea = region.shapes.sum { shape, count in
                shape.area * count
            }
            return unpackedArea <= region.area
        }

        let obviousRejects = regions.count { region in
            // if the total footprint area of the shapes is more than the region area, it definitely
            // won't fit
            let totalFootprint = region.shapes.sum { shape, count in
                shape.footprintArea * count
            }
            return totalFootprint > region.area
        }

        guard obviousFits + obviousRejects == regions.count else {
            fatalError(
                "Non-obvious packing required for \(regions.count - obviousFits - obviousRejects) regions",
            )
        }

        return obviousFits
    }

    private func parseShape(from lines: some Collection<Line>) -> Shape {
        let lines = Array(lines.raw.dropFirst())
        let height = lines.count
        let width = lines[0].count
        var occupiedCells = Set<Point2D>()
        for (y, line) in lines.enumerated() {
            for (x, char) in line.enumerated() where char == "#" {
                occupiedCells.insert(Point2D(x: x, y: y))
            }
        }
        return Shape(width: width, height: height, occupiedCells: occupiedCells)
    }

    private func parseRegion(from line: Line, shapes: [Shape]) -> Region {
        let parts = line.words(separatedBy: ": ")
        let dimensions = parts[0].words(separatedBy: "x").integers
        let width = dimensions[0]
        let height = dimensions[1]
        let shapeCounts = parts[1].words(separatedBy: .whitespaces)
            .integers
            .enumerated()
            .reduce(into: [Shape: Int]()) { result, pair in
                let (index, count) = pair
                result[shapes[index]] = count
            }
        return Region(width: width, height: height, shapes: shapeCounts)
    }
}

private struct Shape: Hashable {
    let width: Int
    let height: Int
    let occupiedCells: Set<Point2D>

    var footprintArea: Int { occupiedCells.count }
    var area: Int { width * height }
}

private struct Region {
    let width: Int
    let height: Int
    let shapes: [Shape: Int]

    var area: Int { width * height }
}
