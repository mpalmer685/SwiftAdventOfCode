import AOCKit
import Foundation

private let seaMonster: [(row: Int, col: Int)] = [
    "                  # ",
    "#    ##    ##    ###",
    " #  #  #  #  #  #   ",
].enumerated().reduce(into: []) { result, entry in
    for (col, cell) in entry.element.enumerated() where cell == "#" {
        result.append((entry.offset, col))
    }
}

private let seaMonsterPixels = seaMonster.count

private let tileIdPattern = NSRegularExpression("^Tile (\\d+):")

struct JurassicJigsaw: Puzzle {
    func part1Solution(for input: String) throws -> Int {
        let tiles = parse(input)
        return tiles
            .filter { neighbors(of: $0, in: tiles).count == 2 }
            .map(\.id)
            .reduce(1, *)
    }

    func part2Solution(for input: String) throws -> Int {
        let tiles = parse(input)
        let grid = assemble(tiles)
        return findMonsters(in: grid)
    }

    private func assemble(_ tiles: [Tile]) -> [[Tile]] {
        let gridSize = Int(sqrt(Double(tiles.count)))
        let grid: Grid<Tile> = Grid(width: gridSize, height: gridSize)
        var neighborsByTile = Dictionary(
            uniqueKeysWithValues: tiles
                .map { ($0, neighbors(of: $0, in: tiles)) }
        )

        func place(_ tile: Tile, at row: Int, _ col: Int) {
            grid[row, col] = tile
            remove(tile, in: &neighborsByTile)
        }

        var topLeftTile = neighborsByTile.first { $0.value.count == 2 }!.key
        let topLeftNeighbors = neighborsByTile[topLeftTile]!
        let neighborEdges = topLeftNeighbors.reduce(into: Set()) { $0.formUnion($1.allEdges) }
        for transform in transformations {
            topLeftTile.perform(transform)
            let targetEdges = [topLeftTile.rightEdge, topLeftTile.bottomEdge]
            if neighborEdges.intersection(targetEdges).count == targetEdges.count {
                place(topLeftTile, at: 0, 0)
                break
            }
        }

        func placeRow(
            _ row: Int,
            aligning edge: KeyPath<Tile, String>,
            with neighborEdge: KeyPath<Tile, String>,
            ofNeighborAt offset: (Int, Int)
        ) {
            let colStart = row == 0 ? 1 : 0
            for col in colStart ..< gridSize {
                let neighbor = grid[(row, col) + offset]!
                let next = neighborsByTile[neighbor]!
                    .first { $0.allEdges.contains(neighbor[keyPath: neighborEdge]) }!
                orient(next, aligning: edge, with: neighborEdge, of: neighbor) {
                    place($0, at: row, col)
                }
            }
        }

        placeRow(0, aligning: \.leftEdge, with: \.rightEdge, ofNeighborAt: (0, -1))
        for row in 1 ..< gridSize {
            placeRow(row, aligning: \.topEdge, with: \.bottomEdge, ofNeighborAt: (-1, 0))
        }

        return grid.result()
    }

    private func orient(
        _ tile: Tile,
        aligning edge: KeyPath<Tile, String>,
        with neighborEdge: KeyPath<Tile, String>,
        of neighbor: Tile,
        then completion: (Tile) -> Void
    ) {
        var tile = tile
        for transform in transformations {
            tile.perform(transform)
            if tile[keyPath: edge] == neighbor[keyPath: neighborEdge] {
                completion(tile)
                return
            }
        }
    }

    private func findMonsters(in grid: [[Tile]]) -> Int {
        var image = combine(grid)
        var matches = 0
        for transform in transformations {
            transform(&image)
            for row in 0 ..< image.count - 3 {
                for col in 0 ..< image.first!.count - 20 where imageContainsSeaMonster(
                    image,
                    at: row,
                    col
                ) {
                    matches += 1
                }
            }
            if matches > 0 {
                break
            }
        }
        if matches == 0 {
            fatalError("Could not find an image alignment")
        }

        let totalFilledPixels = image.reduce(0) { $0 + $1.count { $0 == "#" } }
        return totalFilledPixels - matches * seaMonsterPixels
    }

    private func imageContainsSeaMonster(_ image: [[Character]], at row: Int, _ col: Int) -> Bool {
        seaMonster.allSatisfy { image[row + $0.0][col + $0.1] == "#" }
    }

    private func combine(_ grid: [[Tile]]) -> [[Character]] {
        var result: [String] = []

        for row in grid {
            var imageRow: [String] = Array(repeating: "", count: row.first!.imagePixels.count)
            for tile in row {
                for (index, line) in tile.imagePixels.enumerated() {
                    imageRow[index] += line
                }
            }
            result.append(contentsOf: imageRow)
        }

        return result.map(Array.init)
    }

    private func neighbors(of tile: Tile, in tiles: [Tile]) -> [Tile] {
        tiles
            .removing(tile)
            .filter { neighbor in
                neighbor.allEdges.intersection(tile.edges).count > 0
            }
    }

    private func parse(_ input: String) -> [Tile] {
        var tiles = [Tile]()
        var tileId = 0
        var rows = [String]()

        for line in getLines(from: input) {
            if let match = tileIdPattern.match(line) {
                if !rows.isEmpty {
                    tiles.append(Tile(id: tileId, pixels: rows.map(Array.init)))
                }
                tileId = Int(match[1])!
                rows = []
            } else {
                rows.append(line)
            }
        }
        tiles.append(Tile(id: tileId, pixels: rows.map(Array.init)))

        return tiles
    }
}

private typealias Transformation = (inout [[Character]]) -> Void
private let transformations: [Transformation] = [
    rotate,
    rotate,
    rotate,
    rotate,
    flip,
    rotate,
    rotate,
    rotate,
]

private struct Tile: Equatable, Hashable {
    let id: Int
    var pixels: [[Character]]

    var topEdge: String { String(pixels.first!) }
    var bottomEdge: String { String(pixels.last!) }
    var rightEdge: String { String(pixels.map(\.last!)) }
    var leftEdge: String { String(pixels.map(\.first!)) }

    var edges: [String] {
        [topEdge, bottomEdge, rightEdge, leftEdge]
    }

    var reversedEdges: [String] {
        edges.map { String($0.reversed()) }
    }

    var allEdges: Set<String> {
        Set(edges + reversedEdges)
    }

    var imagePixels: [String] {
        pixels[1 ..< pixels.count - 1].map { String($0[1 ..< $0.count - 1]) }
    }

    mutating func perform(_ transform: Transformation) {
        transform(&pixels)
    }

    static func == (lhs: Tile, rhs: Tile) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

private class Grid<T> {
    private let width: Int
    private let height: Int

    private var grid: [T?]

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        grid = Array(repeating: nil, count: width * height)
    }

    private func indexIsValid(_ row: Int, _ col: Int) -> Bool {
        row.isBetween(0, and: height - 1) && col.isBetween(0, and: width - 1)
    }

    subscript(_ row: Int, _ col: Int) -> T? {
        get {
            guard indexIsValid(row, col) else { fatalError() }
            return grid[row * width + col]
        }
        set {
            guard indexIsValid(row, col) else { fatalError("Invalid index (\(row), \(col))") }
            grid[row * width + col] = newValue
        }
    }

    subscript(location: (row: Int, col: Int)) -> T? {
        get {
            guard indexIsValid(location.row, location.col) else {
                fatalError("Invalid index (\(location.row), \(location.col))")
            }
            return grid[location.row * width + location.col]
        }
        set {
            guard indexIsValid(location.row, location.col) else {
                fatalError("Invalid index (\(location.row), \(location.col))")
            }
            grid[location.row * width + location.col] = newValue
        }
    }

    func result() -> [[T]] {
        var output: [[T]] = []
        for row in 0 ..< height {
            let start = grid.index(grid.startIndex, offsetBy: row * width)
            let end = grid.index(start, offsetBy: width)
            output.append(Array(grid[start ..< end]).map { $0! })
        }
        return output
    }
}

private func remove<Value: Equatable>(_ item: Value, in dict: inout [Value: [Value]]) {
    for (key, value) in dict {
        if value.count == 1, value.first! == item {
            dict[key] = nil
        } else {
            dict[key] = value.removing(item)
        }
    }
}

private func flip<T>(_ array: inout [[T]]) {
    array.reverse()
}

private func rotate<T>(_ array: inout [[T]]) {
    array.reverse()
    for row in 0 ..< array.count {
        for col in 0 ..< row {
            (array[row][col], array[col][row]) = (array[col][row], array[row][col])
        }
    }
}

private func + (lhs: (Int, Int), rhs: (Int, Int)) -> (Int, Int) {
    (lhs.0 + rhs.0, lhs.1 + rhs.1)
}

/*
 123 321 789 987
 147 741 369 963

 start:
 1 2 3
 4 5 6
 7 8 9

 rotate:
 7 4 1
 8 5 2
 9 6 3

 rotate:
 9 8 7
 6 5 4
 3 2 1

 rotate:
 3 6 9
 2 5 8
 1 4 7

 rotate, flip horizontally:
 3 2 1
 6 5 4
 9 8 7

 rotate:
 9 6 3
 8 5 2
 7 4 1

 rotate:
 7 8 9
 4 5 6
 1 2 3

 rotate:
 1 4 7
 2 5 8
 3 6 9

 */
