import AOCKit

struct ParabolicReflectorDish: Puzzle {
    static let day = 14

    // static let rawInput: String? = """
    // O....#....
    // O.OO#....#
    // .....##...
    // OO.#O....O
    // .O.....O#.
    // O.#..O.#.#
    // ..O..#O..O
    // .......O..
    // #....###..
    // #OO..#....
    // """

    func part1(input: Input) throws -> Int {
        let tiltedMap = tiltNorth(parse(input))
        return calculateLoad(for: tiltedMap, withHeight: input.lines.count)
    }

    func part2(input: Input) throws -> Int {
        var map = parse(input)
        var memory = [map]
        let targetCycleCount = 1_000_000_000

        // we should find a cycle before we get here, but worst case...
        for cycle in 1 ..< targetCycleCount {
            map = runSpinCycle(on: map)

            if let cycleStart = memory.firstIndex(of: map) {
                let cycleLength = cycle - cycleStart
                let offset = cycleStart + (targetCycleCount - cycleStart) % cycleLength
                let seenMap = memory[offset]
                return calculateLoad(for: seenMap, withHeight: input.lines.count)
            }

            memory.append(map)
        }

        return calculateLoad(for: map, withHeight: input.lines.count)
    }

    private func calculateLoad(for map: Map, withHeight height: Int) -> Int {
        map.filter { $0.value == .rounded }.sum { location, _ in
            height - location.y
        }
    }

    private func runSpinCycle(on map: Map) -> Map {
        var spun = tiltNorth(map)
        spun = tiltWest(spun)
        spun = tiltSouth(spun)
        return tiltEast(spun)
    }

    private func tiltNorth(_ map: Map) -> Map {
        guard let width = map.max(of: \.key.x) else {
            fatalError()
        }

        var tiltedMap = Map()

        for x in 0 ... width {
            let column = map.filter { $0.key.x == x }.sorted(using: \.key.y)
            var tiltedColumn = [Int: Rock]()

            for (location, rock) in column {
                if rock == .rounded {
                    let nextY = (tiltedColumn.max(of: \.key) ?? -1) + 1
                    tiltedColumn[nextY] = rock
                } else {
                    tiltedColumn[location.y] = rock
                }
            }

            for (y, rock) in tiltedColumn {
                tiltedMap[Point2D(x, y)] = rock
            }
        }

        return tiltedMap
    }

    private func tiltSouth(_ map: Map) -> Map {
        guard let maxX = map.max(of: \.key.x), let maxY = map.max(of: \.key.y) else {
            fatalError()
        }

        var tiltedMap = Map()

        for x in 0 ... maxX {
            let column = map.filter { $0.key.x == x }.sorted(using: \.key.y).reversed()
            var tiltedColumn = [Int: Rock]()

            for (location, rock) in column {
                if rock == .rounded {
                    let nextY = (tiltedColumn.min(of: \.key) ?? (maxY + 1)) - 1
                    tiltedColumn[nextY] = rock
                } else {
                    tiltedColumn[location.y] = rock
                }
            }

            for (y, rock) in tiltedColumn {
                tiltedMap[Point2D(x, y)] = rock
            }
        }

        return tiltedMap
    }

    private func tiltWest(_ map: Map) -> Map {
        guard let maxY = map.max(of: \.key.y) else {
            fatalError()
        }

        var tiltedMap = Map()

        for y in 0 ... maxY {
            let row = map.filter { $0.key.y == y }.sorted(using: \.key.x)
            var tiltedColumn = [Int: Rock]()

            for (location, rock) in row {
                if rock == .rounded {
                    let nextX = (tiltedColumn.max(of: \.key) ?? -1) + 1
                    tiltedColumn[nextX] = rock
                } else {
                    tiltedColumn[location.x] = rock
                }
            }

            for (x, rock) in tiltedColumn {
                tiltedMap[Point2D(x, y)] = rock
            }
        }

        return tiltedMap
    }

    private func tiltEast(_ map: Map) -> Map {
        guard let maxY = map.max(of: \.key.y), let maxX = map.max(of: \.key.x) else {
            fatalError()
        }

        var tiltedMap = Map()

        for y in 0 ... maxY {
            let row = map.filter { $0.key.y == y }.sorted(using: \.key.x).reversed()
            var tiltedColumn = [Int: Rock]()

            for (location, rock) in row {
                if rock == .rounded {
                    let nextX = (tiltedColumn.min(of: \.key) ?? (maxX + 1)) - 1
                    tiltedColumn[nextX] = rock
                } else {
                    tiltedColumn[location.x] = rock
                }
            }

            for (x, rock) in tiltedColumn {
                tiltedMap[Point2D(x, y)] = rock
            }
        }

        return tiltedMap
    }

    private func parse(_ input: Input) -> Map {
        var map = Map()

        let tiles = input.lines.characters
        for (y, row) in tiles.enumerated() {
            for (x, tile) in row.enumerated() {
                if let rock = Rock(rawValue: tile) {
                    map[Point2D(x, y)] = rock
                }
            }
        }

        return map
    }

    private func render(_ map: Map) {
        let maxX = map.max(of: \.key.x) ?? 0
        let maxY = map.max(of: \.key.y) ?? 0
        let width = maxX + 1
        let height = maxY + 1

        var rendered = ""

        for row in 0 ..< height {
            for col in 0 ..< width {
                let loc = Point2D(col, row)
                if let rock = map[loc] {
                    rendered += String(rock.rawValue)
                } else {
                    rendered += "."
                }
            }
            rendered += "\n"
        }

        print(rendered)
    }
}

private typealias Map = [Point2D: Rock]

private enum Rock: Character {
    case rounded = "O"
    case cubed = "#"
}
