import AOCKit

struct TransparentOrigami: Puzzle {
    static let day = 13

    func part1(input: Input) throws -> Int {
        var (dots, folds) = parse(input)
        guard let firstFold = folds.first else { fatalError() }
        perform(fold: firstFold, using: &dots)
        return dots.count
    }

    func part2(input: Input) throws -> String {
        var (dots, folds) = parse(input)
        for fold in folds {
            perform(fold: fold, using: &dots)
        }
        return format(dots)
    }

    private func parse(_ input: Input) -> (dots: Set<Point2D>, folds: [Fold]) {
        let parts = input.lines.split(whereSeparator: \.isEmpty)
        let dots = parts[0].map(Point2D.init)
        let folds = parts[1].map(Fold.init)
        return (Set(dots), folds)
    }
}

private func perform(fold: Fold, using dots: inout Set<Point2D>) {
    switch fold {
        case let .up(y):
            foldUp(at: y, dots: &dots)
        case let .left(x):
            foldLeft(at: x, dots: &dots)
    }
}

private func foldUp(at y: Int, dots: inout Set<Point2D>) {
    for dot in dots where dot.y > y {
        dots.remove(dot)
        dots.insert(Point2D(x: dot.x, y: 2 * y - dot.y))
    }
}

private func foldLeft(at x: Int, dots: inout Set<Point2D>) {
    for dot in dots where dot.x > x {
        dots.remove(dot)
        dots.insert(Point2D(x: 2 * x - dot.x, y: dot.y))
    }
}

private func format(_ points: Set<Point2D>) -> String {
    guard let height = points.map(\.y).max(), let width = points.map(\.x).max() else {
        fatalError()
    }
    return (0 ... height).map { y in
        (0 ... width).map { x in points.contains(Point2D(x: x, y: y)) ? "#" : " " }.joined()
    }.joined(separator: "\n")
}

private extension Point2D {
    init(line: Line) {
        let parts = line.csvWords
        guard let x = parts[0].integer else {
            fatalError("Unable to parse x coordinate: \(parts[0])")
        }
        guard let y = parts[1].integer else {
            fatalError("Unable to parse y coordinate: \(parts[1])")
        }
        self.init(x, y)
    }
}

private let foldInstructionPattern = NSRegularExpression("fold along (x|y)=(\\d+)")

private enum Fold {
    case up(Int)
    case left(Int)

    init(line: Line) {
        guard let match = foldInstructionPattern.match(line.raw) else {
            fatalError("Line does not match pattern: \(line)")
        }
        guard let coord = Int(match[2]) else {
            fatalError("Unable to parse Int from \"\(match[2])\"")
        }
        let direction = match[1]
        self = direction == "x" ? .left(coord) : .up(coord)
    }
}
