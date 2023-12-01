import AOCKit

struct CrabCups: Puzzle {
    static let day = 23
    static let rawInput: String? = "253149867"

    func part1(input: Input) throws -> String {
        var game = Game(cups: parse(input))
        game.play(rounds: 100)
        return game.stringResult
    }

    func part2(input: Input) throws -> Int {
        let cups = parse(input)
        var game = Game(cups: cups + Array(cups.max()! + 1 ... 1_000_000))
        game.play(rounds: 10_000_000)
        return game.intResult
    }

    private func parse(_ input: Input) -> [Int] {
        input.digits
    }
}

private struct Game {
    private let maxValue: Int
    private var cupRing: [Int]
    private let cups: [Int]

    var stringResult: String {
        var label = cupRing[1]
        var result = ""
        while label != 1 {
            result += label.description
            label = cupRing[label]
        }
        return result
    }

    var intResult: Int {
        let first = cupRing[1]
        let second = cupRing[first]
        return first * second
    }

    init(cups: [Int]) {
        maxValue = cups.max()!
        cupRing = Self.getNextAddresses(for: cups)
        self.cups = cups
    }

    mutating func play(rounds: Int) {
        var currentCup = cups[0]
        for _ in 0 ..< rounds {
            let removed = cupsToRemove(for: currentCup)

            var destination = currentCup
            repeat {
                destination -= 1
                if destination == 0 {
                    destination = maxValue
                }
            } while removed.contains(destination)

            rotate(removed, from: currentCup, to: destination)

            currentCup = cupRing[currentCup]
        }
    }

    private func cupsToRemove(for currentCup: Int) -> [Int] {
        var removed: [Int] = []
        var current = currentCup
        while removed.count < 3 {
            current = cupRing[current]
            removed.append(current)
        }
        return removed
    }

    private mutating func rotate(
        _ cups: [Int],
        from current: Int,
        to destination: Int
    ) {
        cupRing[current] = cupRing[cups.last!]
        cupRing[cups.last!] = cupRing[destination]
        cupRing[destination] = cups.first!
    }

    private static func getNextAddresses(for cups: [Int]) -> [Int] {
        var next = Array(repeating: 0, count: cups.count + 1)
        for i in 0 ..< cups.count {
            next[cups[i]] = cups[(i + 1) % cups.count]
        }
        return next
    }
}
