import AOCKit

struct InfiniteElvesAndInfiniteHouses: Puzzle {
    static let day = 20

    func part1(input: Input) async throws -> Int {
        guard let target = input.integer else {
            fatalError("Invalid input")
        }

        var houses = Array(repeating: 10, count: (target / 10) + 1)
        for elf in 2 ..< (houses.count) {
            for house in stride(from: elf, to: houses.count, by: elf) {
                houses[house] += elf * 10
            }
        }

        return houses.firstIndex(where: { $0 >= target })!
    }

    func part2(input: Input) async throws -> Int {
        guard let target = input.integer else {
            fatalError("Invalid input")
        }

        var houses = Array(repeating: 0, count: (target / 11) + 1)
        for elf in 1 ..< (houses.count) {
            for house in stride(from: elf, to: houses.count, by: elf).prefix(50) {
                houses[house] += elf * 11
            }
        }

        return houses.firstIndex(where: { $0 >= target })!
    }
}
