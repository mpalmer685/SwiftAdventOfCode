import AOCKit

let testInput = "389125467"

struct CrabCups: Puzzle {
    func part1Solution(for input: String) throws -> String {
        let (result, _) = play(100, roundsWith: parse(input))
        return result
    }

    func part2Solution(for input: String) throws -> Int {
        let cups = parse(input)
        let (_, result) = play(10_000_000, roundsWith: cups + Array(cups.max()! + 1 ... 1_000_000))
        return result
    }

    private func parse(_ input: String) -> [Int] {
        input.compactMap { Int(String($0)) }
    }
}

private func play(_ moveCount: Int, roundsWith cups: [Int]) -> (String, Int) {
    let maxValue = cups.max()!
    var cupRing = getNextAddresses(for: cups)

    func removedCups(_ currentCup: Int) -> [Int] {
        var removed: [Int] = []
        var current = currentCup
        while removed.count < 3 {
            current = cupRing[current]
            removed.append(current)
        }
        return removed
    }

    func stringResult() -> String {
        var label = cupRing[1]
        var result = ""
        while label != 1 {
            result += label.description
            label = cupRing[label]
        }
        return result
    }

    func intResult() -> Int {
        let first = cupRing[1]
        let second = cupRing[first]
        return first * second
    }

    var currentCup = cups[0]
    for _ in 0 ..< moveCount {
        let removed = removedCups(currentCup)

        var destination = currentCup
        repeat {
            destination -= 1
            if destination == 0 {
                destination = maxValue
            }
        } while removed.contains(destination)

        rotate(removed, in: &cupRing, from: currentCup, to: destination)

        currentCup = cupRing[currentCup]
    }

    return (stringResult(), intResult())
}

private func getNextAddresses(for cups: [Int]) -> [Int] {
    var next = Array(repeating: 0, count: cups.count + 1)
    for i in 0 ..< cups.count {
        next[cups[i]] = cups[(i + 1) % cups.count]
    }
    return next
}

private func rotate(
    _ cups: [Int],
    in cupRing: inout [Int],
    from current: Int,
    to destination: Int
) {
    cupRing[current] = cupRing[cups.last!]
    cupRing[cups.last!] = cupRing[destination]
    cupRing[destination] = cups.first!
}
