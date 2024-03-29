import AOCKit

struct ConwayCubes: Puzzle {
    static let day = 17

    func part1(input: Input) throws -> Int {
        var field: [Point3D: Bool] = try parse(input)
        for _ in 0 ..< 6 {
            GameOfLife.playRound(on: &field, using: willCellBeActive)
        }

        return field.count { $0.value }
    }

    func part2(input: Input) throws -> Int {
        var field: [Point4D: Bool] = try parse(input)
        for _ in 0 ..< 6 {
            GameOfLife.playRound(on: &field, using: willCellBeActive)
        }

        return field.count { $0.value }
    }

    private func parse<T: Position>(_ input: Input) throws -> [T: Bool] {
        var field: [T: Bool] = [:]
        for (y, line) in input.lines.enumerated() {
            for (x, cell) in line.characters.enumerated() {
                let components = [x, y]
                    .compactMap(T.Precision.init(exactly:))
                    .padded(toLength: T.numberOfDimensions, with: 0)
                field[T(components)] = cell == "#"
            }
        }
        return field
    }

    private func willCellBeActive(isActive: Bool, activeNeighbors: Int) -> Bool {
        if isActive, activeNeighbors != 2, activeNeighbors != 3 {
            return false
        } else if !isActive, activeNeighbors == 3 {
            return true
        }
        return isActive
    }
}

private protocol Position: PointProtocol, GameOfLifePosition {}

extension Point3D: Position {}
extension Point4D: Position {}

private extension Array {
    subscript(index: Index, default defaultValue: @autoclosure () -> Element) -> Element {
        guard index < count else { return defaultValue() }
        return self[index]
    }
}
