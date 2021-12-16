struct Grid {
    struct Point: Hashable {
        let x: Int
        let y: Int

        init(_ x: Int, _ y: Int) {
            self.x = x
            self.y = y
        }

        func offsetBy(_ dx: Int, _ dy: Int) -> Self {
            Point(x + dx, y + dy)
        }
    }

    private var cells: [[Int]]

    init(_ cells: [[Int]]) {
        let width = cells[0].count
        guard cells.allSatisfy({ $0.count == width }) else {
            fatalError("Irregular row lengths")
        }
        self.cells = cells
    }

    var width: Int { cells[0].count }
    var height: Int { cells.count }

    var count: Int { height * width }

    var points: [Point] {
        cells.indices.flatMap { y in cells[y].indices.map { x in Point(x, y) } }
    }

    func contains(_ point: Point) -> Bool {
        point.x.isBetween(0, and: width - 1) && point.y.isBetween(0, and: height - 1)
    }

    subscript(_ point: Point) -> Int {
        get {
            guard contains(point) else { fatalError("Out of bounds: \(point)") }
            return cells[point.y][point.x]
        }
        set {
            guard contains(point) else { fatalError("Out of bounds: \(point)") }
            cells[point.y][point.x] = newValue
        }
    }
}

extension Grid.Point: CustomStringConvertible {
    public var description: String { "(\(x), \(y))" }
}

extension Grid: CustomStringConvertible {
    public var description: String {
        cells.map { $0.map(String.init).joined() }.joined(separator: "\n")
    }
}

