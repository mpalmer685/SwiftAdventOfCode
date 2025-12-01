@testable import AOCKit
import Testing

@Suite("Grid tests")
struct GridTests {
    @Test func gridInitialization() {
        let data = [
            [1, 2, 3],
            [4, 5, 6],
            [7, 8, 9],
        ]
        let grid = Grid(data)
        #expect(grid.width == 3)
        #expect(grid.height == 3)
        #expect(grid.count == 9)

        for y in 0 ..< grid.height {
            for x in 0 ..< grid.width {
                #expect(grid[x, y] == data[y][x])
            }
        }
    }

    @Test func gridInitializationWithFiller() {
        let grid = Grid(width: 4, height: 3, filledWith: 0)
        #expect(grid.width == 4)
        #expect(grid.height == 3)
        #expect(grid.count == 12)

        for y in 0 ..< grid.height {
            for x in 0 ..< grid.width {
                #expect(grid[x, y] == 0)
            }
        }
    }

    @Test func gridInitializationWithTransform() {
        let data = [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"],
        ]
        let grid = Grid(data: data) { Int($0)! }
        #expect(grid.width == 3)
        #expect(grid.height == 3)
        #expect(grid.count == 9)

        for y in 0 ..< grid.height {
            for x in 0 ..< grid.width {
                #expect(grid[x, y] == Int(data[y][x])!)
            }
        }
    }

    @Test func gridContainsPoint() {
        let grid = Grid(width: 3, height: 3, filledWith: 0)

        #expect(grid.contains(Point2D(1, 1)) == true)
        #expect(grid.contains(Point2D(3, 1)) == false)
        #expect(grid.contains(Point2D(1, 3)) == false)
        #expect(grid.contains(Point2D(-1, 1)) == false)
        #expect(grid.contains(Point2D(1, -1)) == false)

        #expect(grid.contains(x: 1, y: 1) == true)
        #expect(grid.contains(x: 3, y: 1) == false)
        #expect(grid.contains(x: 1, y: 3) == false)
        #expect(grid.contains(x: -1, y: 1) == false)
        #expect(grid.contains(x: 1, y: -1) == false)
    }

    @Test func gridSubscripts() {
        var grid = Grid(width: 2, height: 2, filledWith: 0)

        grid[Point2D(0, 0)] = 1
        grid[1, 0] = 2
        grid[Point2D(0, 1)] = 3
        grid[1, 1] = 4

        #expect(grid[Point2D(0, 0)] == 1)
        #expect(grid[1, 0] == 2)
        #expect(grid[Point2D(0, 1)] == 3)
        #expect(grid[1, 1] == 4)

        #expect(grid[safe: Point2D(2, 2)] == nil)
        #expect(grid[safe: Point2D(1, 1)] == 4)
    }

    @Test func gridRowSubscripts() {
        let grid = Grid([
            [1, 2, 3, 4],
            [5, 6, 7, 8],
            [9, 10, 11, 12],
            [13, 14, 15, 16],
        ])

        #expect(grid[row: 0] == [1, 2, 3, 4])
        #expect(grid[row: 1] == [5, 6, 7, 8])
        #expect(grid[row: 2] == [9, 10, 11, 12])
        #expect(grid[row: 3] == [13, 14, 15, 16])

        #expect(grid[rows: 1 ..< 3] == [
            [5, 6, 7, 8],
            [9, 10, 11, 12],
        ])
    }

    @Test func gridColumnSubscripts() {
        let grid = Grid([
            [1, 2, 3, 4],
            [5, 6, 7, 8],
            [9, 10, 11, 12],
            [13, 14, 15, 16],
        ])

        #expect(grid[column: 0] == [1, 5, 9, 13])
        #expect(grid[column: 1] == [2, 6, 10, 14])
        #expect(grid[column: 2] == [3, 7, 11, 15])
        #expect(grid[column: 3] == [4, 8, 12, 16])

        #expect(grid[columns: 1 ..< 3] == [
            [2, 6, 10, 14],
            [3, 7, 11, 15],
        ])
    }

    @Test func gridLocationOfCell() {
        let grid = Grid([
            [1, 2, 3],
            [4, 5, 6],
            [7, 8, 9],
        ])

        #expect(grid.location(of: 5) == Point2D(1, 1))
        #expect(grid.location(of: 1) == Point2D(0, 0))
        #expect(grid.location(of: 9) == Point2D(2, 2))
        #expect(grid.location(of: 10) == nil)
    }
}
