public struct Grid<Cell> {
    public struct Point: Hashable {
        public let x: Int
        public let y: Int

        public init(_ x: Int, _ y: Int) {
            self.x = x
            self.y = y
        }

        public func offsetBy(_ dx: Int, _ dy: Int) -> Self {
            Self(x + dx, y + dy)
        }
    }

    private(set) var cells: [[Cell]]

    public init(_ cells: [[Cell]]) {
        let width = cells[0].count
        guard cells.allSatisfy({ $0.count == width }) else {
            fatalError("Irregular row lengths")
        }
        self.cells = cells
    }

    public init(width: Int, height: Int, filledWith filler: Cell) {
        let cells = Array(
            repeating: Array(repeating: filler, count: width),
            count: height
        )
        self.init(cells)
    }

    public var width: Int { cells[0].count }
    public var height: Int { cells.count }

    public var count: Int { width * height }

    public var points: [Point] {
        cells.indices.flatMap { y in cells[y].indices.map { x in Point(x, y) } }
    }

    public func contains(_ point: Point) -> Bool {
        point.x.isBetween(0, and: width - 1) && point.y.isBetween(0, and: height - 1)
    }

    public subscript(_ point: Point) -> Cell {
        get {
            guard contains(point) else { fatalError("Out of bounds: \(point)") }
            return cells[point.y][point.x]
        }
        set {
            guard contains(point) else { fatalError("Out of bounds: \(point)") }
            cells[point.y][point.x] = newValue
        }
    }

    public subscript(row row: Int) -> [Cell] {
        guard row.isBetween(0, and: height - 1) else {
            fatalError("Row \(row) out of bounds")
        }
        return cells[row]
    }

    public subscript(column column: Int) -> [Cell] {
        guard column.isBetween(0, and: width - 1) else {
            fatalError("Column \(column) out of bounds")
        }
        return cells.map { $0[column] }
    }
}

extension Grid: CustomStringConvertible where Cell: CustomStringConvertible {
    public var description: String {
        cells.map { $0.map(\.description).joined() }.joined(separator: "\n")
    }
}

extension Grid: Equatable where Cell: Equatable {}
extension Grid: Hashable where Cell: Hashable {}

extension Grid.Point: CustomStringConvertible {
    public var description: String { "(\(x), \(y))" }
}
