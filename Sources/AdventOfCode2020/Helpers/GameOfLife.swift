enum GameOfLife {
    typealias Rule = (Bool, Int) -> Bool
    typealias Grid<P: GameOfLifePosition> = [P: Bool]

    static func playRound<P: GameOfLifePosition>(
        on grid: inout Grid<P>,
        using willBeActive: Rule
    ) {
        for position in grid.keys {
            for neighbor in position.neighbors where grid[neighbor] == nil {
                grid[neighbor] = false
            }
        }

        var cellsToFlip: [P] = []
        for (position, isActive) in grid {
            let neighborCount = position.neighbors.count { grid[$0] == true }
            if willBeActive(isActive, neighborCount) != isActive {
                cellsToFlip.append(position)
            }
        }

        flip(cellsToFlip, in: &grid)
    }

    private static func flip<P: GameOfLifePosition>(_ cells: [P], in grid: inout Grid<P>) {
        for p in cells {
            grid[p] = !grid[p, default: false]
        }
    }
}

protocol GameOfLifePosition: Hashable {
    var neighbors: [Self] { get }
}
