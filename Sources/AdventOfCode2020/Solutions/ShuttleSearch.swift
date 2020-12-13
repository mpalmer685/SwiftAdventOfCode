import AOCKit

struct ShuttleSearch: Puzzle {
    func part1Solution(for input: String) throws -> Int {
        let lines = getLines(from: input)
        guard lines.count == 2 else { fatalError() }
        let earliestDepartureTime = Int(lines.first!)!
        let ids = split(lines[1], on: ",").compactMap(Int.init)
        let (id, nextDeparture) = ids
            .map(nextDepartureTime(after: earliestDepartureTime))
            .sorted { $0.time < $1.time }
            .first!
        return id * (nextDeparture - earliestDepartureTime)
    }

    func part2Solution(for input: String) throws -> Int {
        let lines = getLines(from: input)
        let buses = split(lines[1], on: ",")
            .enumerated()
            .filter { Int($0.element) != nil }
            .map { (offset: $0.offset, id: Int($0.element)!) }
        var startTime = buses.first!.id
        var increment = startTime
        for i in 1 ..< buses.count {
            while buses[...i].contains(where: { ( startTime + $0.offset) % $0.id != 0 }) {
                startTime += increment
            }
            increment *= buses[i].id
        }
        return startTime
    }

    private func nextDepartureTime(after time: Int) -> (Int) -> (id: Int, time: Int) {
        { id in (id: id, time: id * (1 + (time / id))) }
    }
}
