import AOCKit

struct ShuttleSearch: Puzzle {
    static let day = 13

    func part1(input: Input) throws -> Int {
        let lines = input.lines
        guard lines.count == 2 else { fatalError() }
        let earliestDepartureTime = lines[0].integer!
        let ids = lines[1].csvWords.integers
        let (id, nextDeparture) = ids
            .map(nextDepartureTime(after: earliestDepartureTime))
            .sorted { $0.time < $1.time }
            .first!
        return id * (nextDeparture - earliestDepartureTime)
    }

    func part2(input: Input) throws -> Int {
        let lines = input.lines
        let buses = lines[1].csvWords
            .enumerated()
            .filter { $0.element.integer != nil }
            .map { (offset: $0.offset, id: $0.element.integer!) }
        var startTime = buses.first!.id
        var increment = startTime
        for i in 1 ..< buses.count {
            while buses[...i].contains(where: { (startTime + $0.offset) % $0.id != 0 }) {
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
