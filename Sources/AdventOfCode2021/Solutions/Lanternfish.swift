import AOCKit

private let testInput = "3,4,3,1,2"

struct Lanternfish: Puzzle {
    static let day = 6

    func part1() throws -> Int {
        let fish = parseInput()
        return countFish(fish, forDays: 80)
    }

    func part2() throws -> Int {
        let fish = parseInput()
        return countFish(fish, forDays: 256)
    }

    private func parseInput() -> [Int: Int] {
        input().csvWords.integers
            .reduce(into: [:]) { fishByAge, age in
                fishByAge[age, default: 0] += 1
            }
    }
}

private func countFish(_ fish: [Int: Int], forDays days: Int) -> Int {
    var fish = fish
    for _ in 0 ..< days {
        let fishReadyToReproduce = fish[0, default: 0]
        // decrement the number of days until each fish is ready to reproduce
        for i in 0 ..< 8 {
            fish[i] = fish[i + 1, default: 0]
        }

        // reset all fish that have reproduced to 6
        fish[6, default: 0] += fishReadyToReproduce

        // add new fish from the ones that reproduced
        fish[8] = fishReadyToReproduce
    }

    return fish.values.reduce(0, +)
}

private extension Int {
    init?(_ s: ArraySlice<Character>) {
        self.init(String(s))
    }
}
