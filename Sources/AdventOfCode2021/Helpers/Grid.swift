struct Grid<Cell> {
    private(set) var cells: [[Cell]]

    init(_ cells: [[Cell]]) {
        let width = cells[0].count
        guard cells.allSatisfy({ $0.count == width }) else {
            fatalError("Irregular row lengths")
        }
        self.cells = cells
    }

    init(width: Int, height: Int, filledWith filler: Cell) {
        let cells: [[Cell]] = Array(
            repeating: Array(repeating: filler, count: width),
            count: height
        )
        self.init(cells)
    }

    var width: Int { cells[0].count }
    var height: Int { cells.count }

    var count: Int { height * width }

    var points: [GridPoint] {
        cells.indices.flatMap { y in cells[y].indices.map { x in GridPoint(x, y) } }
    }

    func contains(_ point: GridPoint) -> Bool {
        point.x.isBetween(0, and: width - 1) && point.y.isBetween(0, and: height - 1)
    }

    subscript(_ point: GridPoint) -> Cell {
        get {
            guard contains(point) else { fatalError("Out of bounds: \(point)") }
            return cells[point.y][point.x]
        }
        set {
            guard contains(point) else { fatalError("Out of bounds: \(point)") }
            cells[point.y][point.x] = newValue
        }
    }

    subscript(_ row: Int) -> [Cell] {
        guard row.isBetween(0, and: height - 1) else { fatalError("Row out of bounds: \(row)") }
        return cells[row]
    }
}

extension Grid: CustomStringConvertible where Cell: CustomStringConvertible {
    var description: String {
        cells.map { $0.map(\.description).joined() }.joined(separator: "\n")
    }
}

extension Grid: Equatable where Cell: Equatable {}
extension Grid: Hashable where Cell: Hashable {}

struct GridPoint: Hashable {
    let x: Int
    let y: Int

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    func offsetBy(_ dx: Int, _ dy: Int) -> Self {
        Self(x + dx, y + dy)
    }
}

extension GridPoint: CustomStringConvertible {
    public var description: String { "(\(x), \(y))" }
}
