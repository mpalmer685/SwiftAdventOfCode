import AOCKit

struct PlutonianPebbles: Puzzle {
    static let day = 11

    func part1(input: Input) throws -> Int {
        var simulation = Simulation(input)
        for _ in 0 ..< 25 {
            simulation.blink()
        }
        return simulation.count
    }

    func part2(input: Input) throws -> Int {
        var simulation = Simulation(input)
        for _ in 0 ..< 75 {
            simulation.blink()
        }
        return simulation.count
    }
}

private struct Simulation {
    private var stones: [Int: Int]

    private let processStone: (Int) -> [Int]

    init(_ input: Input) {
        stones = input.words.integers.reduce(into: [Int: Int]()) { counts, stone in
            counts[stone, default: 0] += 1
        }

        processStone = memoize { (stone: Int) -> [Int] in
            if stone == 0 {
                return [1]
            }

            let s = String(stone)
            if s.count.isEven {
                let left = Int(s.prefix(s.count / 2))!
                let right = Int(s.suffix(s.count / 2))!
                return [left, right]
            }

            return [stone * 2024]
        }
    }

    mutating func blink() {
        var nextStones = [Int: Int]()
        for (stone, count) in stones {
            for nextStone in processStone(stone) {
                nextStones[nextStone, default: 0] += count
            }
        }

        stones = nextStones
    }

    var count: Int {
        stones.sum(of: \.value)
    }
}

extension PlutonianPebbles: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.raw("125 17")).expects(part1: 55312),
        ]
    }
}
