import AOCKit

struct SeatingSystem: Puzzle {
    static let day = 11

    func part1(input: Input) throws -> Int {
        let chart = SeatingChart(lines: input.lines.raw)
        return settle(chart, using: .adjacentSeatingStrategy(chart)).occupiedSeats
    }

    func part2(input: Input) throws -> Int {
        let chart = SeatingChart(lines: input.lines.raw)
        return settle(chart, using: .visibleSeatingStrategy(chart)).occupiedSeats
    }

    private func settle(
        _ chart: SeatingChart,
        using strategy: SeatingChart.SeatingStrategy
    ) -> SeatingChart {
        var chart = chart
        var lastState = type(of: chart.seats).init()
        while chart.seats != lastState {
            lastState = chart.seats
            chart = chart.advance(using: strategy)
        }
        return chart
    }
}

private struct SeatingChart {
    typealias Neighbor = (dx: Int, dy: Int)
    typealias NeighborSet = [[[Neighbor]]]

    var seats: [[Seat]]
    var height: Range<Int>
    var width: Range<Int>

    init(lines: [String]) {
        seats = lines.map { Array($0).compactMap(Seat.init) }
        height = 0 ..< seats.count
        width = 0 ..< seats.first!.count
    }

    init(seats: [[Seat]]) {
        self.seats = seats
        height = 0 ..< seats.count
        width = 0 ..< seats.first!.count
    }

    var occupiedSeats: Int {
        seats.flatMap { $0 }.reduce(0) { $0 + ($1 == .taken ? 1 : 0) }
    }

    func advance(using strategy: SeatingStrategy) -> Self {
        var copy = seats
        for (rowIndex, row) in seats.enumerated() {
            for (colIndex, cell) in row.enumerated() where cell != .floor {
                let neighborCount = count(
                    neighbors: strategy.neighbors,
                    atRow: rowIndex,
                    column: colIndex
                )
                if cell == .empty, neighborCount == 0 {
                    copy[rowIndex][colIndex] = .taken
                } else if cell == .taken, neighborCount >= strategy.abandonThreshold {
                    copy[rowIndex][colIndex] = .empty
                }
            }
        }
        return Self(seats: copy)
    }

    private func count(neighbors: NeighborSet, atRow row: Int, column: Int) -> Int {
        neighbors[row][column]
            .reduce(0) { $0 + (seats[row + $1.dy][column + $1.dx] == .taken ? 1 : 0) }
    }

    enum Seat: Character, CustomStringConvertible {
        case floor = ".",
             empty = "L",
             taken = "#"

        var description: String { String(rawValue) }
    }

    struct SeatingStrategy {
        var neighbors: NeighborSet
        var abandonThreshold: Int

        static func adjacentSeatingStrategy(_ chart: SeatingChart) -> Self {
            var neighbors = NeighborSet()
            for row in chart.height {
                var neighborRow: [[Neighbor]] = []
                for column in chart.width {
                    var cellNeighbors = [Neighbor]()
                    for dy in -1 ... 1 where chart.height.contains(row + dy) {
                        for dx in -1 ... 1
                            where (dx != 0 || dy != 0) && chart.width.contains(column + dx)
                        {
                            cellNeighbors.append((dx, dy))
                        }
                    }
                    neighborRow.append(cellNeighbors)
                }
                neighbors.append(neighborRow)
            }
            return SeatingStrategy(neighbors: neighbors, abandonThreshold: 4)
        }

        static func visibleSeatingStrategy(_ chart: SeatingChart) -> Self {
            let directions = [(-1, -1), (0, -1), (1, -1), (-1, 0), (1, 0), (-1, 1), (0, 1), (1, 1)]
            let seats = chart.seats

            var neighbors = NeighborSet()
            for row in chart.height {
                var neighborRow = [[Neighbor]]()
                for col in chart.width {
                    var cellNeighbors = [Neighbor]()

                    for (dx, dy) in directions
                        where chart.height.contains(row + dy) && chart.width.contains(col + dx)
                    {
                        var neighbor: Neighbor = (dx, dy)
                        var seat = seats[row + neighbor.dy][col + neighbor.dx]
                        while seat == .floor {
                            neighbor = (neighbor.dx + dx, neighbor.dy + dy)
                            if !chart.height.contains(row + neighbor.dy) || !chart.width
                                .contains(col + neighbor.dx)
                            {
                                break
                            }
                            seat = seats[row + neighbor.dy][col + neighbor.dx]
                        }
                        if seat != .floor {
                            cellNeighbors.append(neighbor)
                        }
                    }
                    neighborRow.append(cellNeighbors)
                }
                neighbors.append(neighborRow)
            }
            return SeatingStrategy(neighbors: neighbors, abandonThreshold: 5)
        }
    }
}
