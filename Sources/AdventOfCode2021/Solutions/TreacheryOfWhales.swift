import AOCKit

private let testInput = "16,1,2,0,4,2,7,1,2,14"

struct TreacheryOfWhales: Puzzle {
    static let day = 7

    func part1(input: Input) throws -> Int {
        let positions = getPositions(from: input)
        return getBestDestination(
            for: positions,
            startingAt: median(of: positions),
            using: identityCost,
        )
    }

    func part2(input: Input) throws -> Int {
        let positions = getPositions(from: input)
        return getBestDestination(
            for: positions,
            startingAt: mean(of: positions),
            using: triangleCost,
        )
    }
}

private func getPositions(from input: Input) -> [Int] {
    input.csvWords.integers
}

private func getBestDestination(
    for positions: [Int],
    startingAt startingPosition: Int,
    using calculateCost: CostCalculator,
) -> Int {
    var cache = [Int: Int]()
    var destination = startingPosition

    func getTotalCost(movingTo destination: Int) -> Int {
        if let cost = cache[destination] {
            return cost
        }

        let cost = positions
            .map { abs($0 - destination) }
            .map(calculateCost)
            .reduce(0, +)
        cache[destination] = cost
        return cost
    }

    let maxTries = 10
    for _ in 0 ..< maxTries {
        let currentCost = getTotalCost(movingTo: destination)
        let nextCost = getTotalCost(movingTo: destination + 1)
        let prevCost = getTotalCost(movingTo: destination - 1)

        switch min(currentCost, nextCost, prevCost) {
            case currentCost:
                return currentCost
            case nextCost:
                destination += 1
            case prevCost:
                destination -= 1
            default:
                fatalError("How did this happen?")
        }
    }
    fatalError("Didn't find a solution within \(maxTries) tries.")
}

private typealias CostCalculator = @Sendable (Int) -> Int

private let identityCost: CostCalculator = { $0 }
// https://en.wikipedia.org/wiki/1_%2B_2_%2B_3_%2B_4_%2B_%E2%8B%AF
private let triangleCost: CostCalculator = { $0.triangle }
