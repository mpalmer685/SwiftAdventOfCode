import AOCKit

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

        var maxPressureReleased = 0
        for myValves in destinations.combinations(ofCount: destinations.count / 2) {
            let myPart = maxPressure(
                forRooms: myValves,
                time: 26,
                costs: costsByOrigin,
                roomsByName: roomsByName
            )
            let elephant = maxPressure(
                forRooms: Array(Set(destinations).subtracting(myValves)),
                time: 26,
                costs: costsByOrigin,
                roomsByName: roomsByName
            )
            maxPressureReleased = max(maxPressureReleased, myPart + elephant)
        }

        return maxPressureReleased
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

private struct Room: Hashable {
    let name: String
    let flow: Int
    let neighbors: [String]

    static func == (lhs: Room, rhs: Room) -> Bool {
        lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
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

private struct RoomsCollection: DijkstraPathfindingGraph {
    let roomsByName: RoomsByName

    func nextStates(from state: Room) -> [(Room, Int)] {
        state.neighbors.map { (roomsByName[$0]!, 1) }
    }
}

private func calculateCosts(
    from start: Room,
    to endPositions: [Room],
    withRooms roomsByName: RoomsByName
) -> CostLookup {
    let rooms = RoomsCollection(roomsByName: roomsByName)
    let pathfinder = DijkstraPathfinder(rooms)
    let costs = pathfinder.calculateCosts(from: start)

    return endPositions.reduce(into: CostLookup()) { $0[$1.name] = costs[$1]! }
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
