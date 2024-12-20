public struct Grid<Cell> {
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

    public init<T>(data: [[T]], withTransform transform: (T) -> Cell) {
        let cells = data.map { row in row.map(transform) }
        self.init(cells)
    }

    public var width: Int { cells[0].count }
    public var height: Int { cells.count }

    public var count: Int { width * height }

    public var points: [Point2D] {
        cells.indices.flatMap { y in cells[y].indices.map { x in Point2D(x, y) } }
    }

    public func contains(_ point: Point2D) -> Bool {
        point.x.isBetween(0, and: width - 1) && point.y.isBetween(0, and: height - 1)
    }

    public func contains(x: Int, y: Int) -> Bool {
        (0 ..< width).contains(x) && (0 ..< height).contains(y)
    }

    public subscript(_ point: Point2D) -> Cell {
        get {
            guard contains(point) else { fatalError("Out of bounds: \(point)") }
            return cells[point.y][point.x]
        }
        set {
            guard contains(point) else { fatalError("Out of bounds: \(point)") }
            cells[point.y][point.x] = newValue
        }
    }

    public subscript(safe point: Point2D) -> Cell? {
        contains(point) ? self[point] : nil
    }

    public subscript(x: Int, y: Int) -> Cell {
        get {
            guard contains(x: x, y: y) else {
                fatalError("Out of bounds: (\(x), \(y))")
            }
            return cells[y][x]
        }
        set {
            guard contains(x: x, y: y) else {
                fatalError("Out of bounds: (\(x), \(y))")
            }
            cells[y][x] = newValue
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

    public subscript(rows rows: Range<Int>) -> [[Cell]] {
        Array(cells[rows])
    }

    public subscript(columns columns: Range<Int>) -> [[Cell]] {
        columns.map { self[column: $0] }
    }

    public mutating func insertRow(_ row: [Cell], at rowIndex: Int) {
        guard row.count == width else {
            fatalError("Expected row of length \(width) but got \(row.count)")
        }

        cells.insert(row, at: rowIndex)
    }

    public mutating func insertColumn(_ column: [Cell], at columnIndex: Int) {
        guard column.count == height else {
            fatalError("Expected column of length \(height) but got \(column.count)")
        }

        for row in 0 ..< height {
            cells[row].insert(column[row], at: columnIndex)
        }
    }
}

extension Grid: CustomStringConvertible where Cell: CustomStringConvertible {
    public var description: String {
        cells.map { $0.map(String.init).joined() }.joined(separator: "\n")
    }
}

public extension Grid where Cell: Equatable {
    func location(of cell: Cell) -> Point2D? {
        points.first { self[$0] == cell }
    }
}

extension Grid: Equatable where Cell: Equatable {}
extension Grid: Hashable where Cell: Hashable {}
extension Grid: Sendable where Cell: Sendable {}
