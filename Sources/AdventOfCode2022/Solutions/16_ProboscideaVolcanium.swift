import AOCKit
import Foundation

class ProboscideaVolcanium: Puzzle {
    static let day = 16

    private lazy var rooms: [Room] = {
        input().lines.words.map { words -> Room in
            let name = words[1].raw
            let flow = words[4].trimmingCharacters(in: .semicolon).words(separatedBy: "=")[1]
                .integer!
            let neighbors = words[9...].map { $0.trimmingCharacters(in: .comma) }.raw
            return Room(name: name, flow: flow, neighbors: neighbors)
        }
    }()

    func part1() throws -> Int {
        let (destinations, costsByOrigin, roomsByName) = startingState()
        return maxPressure(
            forRooms: destinations,
            time: 30,
            costs: costsByOrigin,
            roomsByName: roomsByName
        )
    }

    func part2() throws -> Int {
        let (destinations, costsByOrigin, roomsByName) = startingState()
        return maxPressureReleasedWithElephant(
            forRooms: destinations,
            time: 26,
            costs: costsByOrigin,
            roomsByName: roomsByName
        )
    }

    private func startingState() -> ([Room], CostsByOrigin, RoomsByName) {
        let roomsByName = rooms.reduce(into: RoomsByName()) { $0[$1.name] = $1 }

        let startingRoom = roomsByName["AA"]!
        let destinations = rooms.filter { $0.flow > 0 }
        let startingRooms = [startingRoom] + destinations

        let costsByOrigin = startingRooms.reduce(into: CostsByOrigin()) { costs, room in
            costs[room.name] = calculateCosts(
                from: room,
                to: destinations.filter { $0.name != room.name },
                withRooms: roomsByName
            )
        }

        return (destinations, costsByOrigin, roomsByName)
    }
}

private struct Room {
    let name: String
    let flow: Int
    let neighbors: [String]
}

private typealias RoomsByName = [String: Room]
private typealias CostLookup = [String: Int]
private typealias CostsByOrigin = [String: CostLookup]

private final class Path {
    let roomName: String
    let toVisit: [String]
    let timeLeft: Int
    let steps: [String]
    let finalPressure: Int

    var finished: Bool

    init(
        roomName: String,
        toVisit: [String],
        timeLeft: Int,
        steps: [String] = [],
        finalPressure: Int = 0,
        finished: Bool = false
    ) {
        self.roomName = roomName
        self.toVisit = toVisit
        self.timeLeft = timeLeft
        self.steps = steps
        self.finalPressure = finalPressure
        self.finished = finished
    }
}

private func calculateCosts(
    from start: Room,
    to endPositions: [Room],
    withRooms roomsByName: RoomsByName
) -> CostLookup {
    var visited = Set<String>()
    var toVisit: SimpleQueue<Room> = [start]

    var lowestCost = CostLookup(uniqueKeysWithValues: [(start.name, 0)])

    while let curr = toVisit.pop() {
        if visited.contains(curr.name) {
            continue
        }
        let neighborsToVisit = curr.neighbors
            .filter { !visited.contains($0) }
            .map { roomsByName[$0]! }
        toVisit.push(contentsOf: neighborsToVisit)
        let costToCurr = lowestCost[curr.name]!

        for neighbor in neighborsToVisit {
            let newCostToNeighbor = costToCurr + 1
            let costToNeighbor = lowestCost[neighbor.name] ?? newCostToNeighbor

            if newCostToNeighbor <= costToNeighbor {
                lowestCost[neighbor.name] = newCostToNeighbor
            }
        }
        visited.insert(curr.name)
    }
    return endPositions.reduce(into: CostLookup()) { $0[$1.name] = lowestCost[$1.name]! }
}

private func maxPressure(
    forRooms destinations: [Room],
    time: Int,
    costs: CostsByOrigin,
    roomsByName: RoomsByName
) -> Int {
    var paths: [Path] = [Path(roomName: "AA", toVisit: destinations.map(\.name), timeLeft: time)]

    var n = 0
    while n < paths.count {
        if paths[n].timeLeft <= 0 || paths[n].finished {
            paths[n].finished = true
            continue
        }
        guard let currPrices = costs[paths[n].roomName] else {
            fatalError("Couldn't find current prices for \(paths[n].roomName)")
        }

        var madeNewPath = false
        for roomName in paths[n].toVisit {
            guard let currentPrice = currPrices[roomName] else {
                fatalError("Couldn't find current price for \(roomName)")
            }
            if roomName == paths[n].roomName || paths[n].timeLeft - currentPrice <= 1 {
                continue
            }
            guard let room = roomsByName[roomName] else {
                fatalError("No room with name \(roomName)")
            }

            let path = paths[n]
            madeNewPath = true
            paths.append(Path(
                roomName: roomName,
                toVisit: path.toVisit.filter { $0 != roomName },
                timeLeft: path.timeLeft - currentPrice - 1,
                steps: path.steps + [roomName],
                finalPressure: path.finalPressure + (path.timeLeft - currentPrice - 1) * room.flow
            ))
        }
        if !madeNewPath {
            paths[n].finished = true
        }
        n += 1
    }

    guard let maxPressure = paths.filter(\.finished).max(of: \.finalPressure) else {
        fatalError("Couldn't find best path.")
    }
    return maxPressure
}

private func maxPressureReleasedWithElephant(
    forRooms destinations: [Room],
    time: Int,
    costs: CostsByOrigin,
    roomsByName: RoomsByName
) -> Int {
    var mostPressureReleased = -1
    let paths = allPaths(to: destinations, time: time, costs: costs, roomsByName: roomsByName)

    for (h, humanPath) in paths.enumerated() {
        if h % 100 == 0 { print("checking \(h) of \(paths.count)") }
        let set = Set(humanPath.steps)
        for elephantPath in paths[(h + 1)...] where set.isDisjoint(with: elephantPath.steps) {
            let pressure = humanPath.finalPressure + elephantPath.finalPressure
            mostPressureReleased = max(mostPressureReleased, pressure)
        }
    }
    return mostPressureReleased
}

private func allPaths(
    to destinations: [Room],
    time: Int,
    costs: CostsByOrigin,
    roomsByName: RoomsByName
) -> [Path] {
    var paths: [Path] = [Path(roomName: "AA", toVisit: destinations.map(\.name), timeLeft: time)]

    var n = 0
    while n < paths.count {
        if paths[n].timeLeft <= 0 || paths[n].finished {
            paths[n].finished = true
            n += 1
            continue
        }

        guard let currPrices = costs[paths[n].roomName] else {
            fatalError("Couldn't find current prices for \(paths[n].roomName)")
        }

        var madeNewPath = false
        for roomName in paths[n].toVisit {
            guard let currentPrice = currPrices[roomName] else {
                fatalError("Couldn't find current price for \(roomName)")
            }
            if roomName == paths[n].roomName || paths[n].timeLeft - currentPrice <= 1 {
                continue
            }
            guard let room = roomsByName[roomName] else {
                fatalError("No room with name \(roomName)")
            }

            let path = paths[n]
            madeNewPath = true
            let newTimeAfterVisitAndValveOpen = path.timeLeft - currentPrice - 1
            let finalPressure = path.finalPressure + newTimeAfterVisitAndValveOpen * room.flow
            paths += [
                Path(
                    roomName: roomName,
                    toVisit: path.toVisit.filter { $0 != roomName },
                    timeLeft: newTimeAfterVisitAndValveOpen,
                    steps: path.steps + [roomName],
                    finalPressure: finalPressure
                ),
                Path(
                    roomName: roomName,
                    toVisit: [],
                    timeLeft: newTimeAfterVisitAndValveOpen,
                    steps: path.steps + [roomName],
                    finalPressure: finalPressure,
                    finished: true
                ),
            ]
        }

        if !madeNewPath {
            paths[n].finished = true
        }
        n += 1
    }

    return paths.filter(\.finished).sorted(using: \.finalPressure)
}

private struct SimpleQueue<Element> {
    private var elements: [Element] = []

    mutating func push(_ el: Element) {
        elements.insert(el, at: 0)
    }

    mutating func push<S>(contentsOf elements: S) where S: Sequence, S.Element == Element {
        for el in elements {
            push(el)
        }
    }

    mutating func pop() -> Element? {
        elements.popLast()
    }
}

extension SimpleQueue: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Element...) {
        self.elements = elements
    }
}

private extension CharacterSet {
    static let semicolon = CharacterSet(charactersIn: ";")
}

private extension Collection {
    func sorted<C: Comparable>(using value: (Element) -> C) -> [Element] {
        sorted(by: { l, r in
            let lValue = value(l)
            let rValue = value(r)
            return lValue < rValue
        })
    }
}
