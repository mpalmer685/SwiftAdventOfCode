import AOCKit

struct CubeConundrum: Puzzle {
    static let day = 2

    func part1(input: Input) throws -> Int {
        let games = input.lines.map(Game.init)
        let maxRed = 12
        let maxGreen = 13
        let maxBlue = 14

        return games.filter { game in
            game.maxSeen(of: .red) <= maxRed && game.maxSeen(of: .green) <= maxGreen && game
                .maxSeen(of: .blue) <= maxBlue
        }.map(\.id).sum
    }

    func part2(input: Input) throws -> Int {
        let games = input.lines.map(Game.init)
        return games.map { game in
            game.maxSeen(of: .red) * game.maxSeen(of: .green) * game.maxSeen(of: .blue)
        }.sum
    }
}

private struct Game {
    enum Cube: String {
        case red, green, blue
    }

    let id: Int
    let rounds: [[(count: Int, color: Cube)]]

    init(_ line: Line) {
        guard let id = line.integers.first else {
            fatalError("Could not find ID in \(line.raw)")
        }
        self.id = id
        let game = line.words(separatedBy: ":")[1]
        rounds = game.words(separatedBy: ";").map { group in
            group.words(separatedBy: ",").map { draw in
                let words = draw.words(separatedBy: .whitespaces)
                guard let count = words[0].integer, let color = Cube(rawValue: words[1].raw) else {
                    fatalError("Couldn't parse \(draw.raw)")
                }
                return (count, color)
            }
        }
    }

    func maxSeen(of type: Cube) -> Int {
        let roundsSeen = rounds.flattened.filter { $0.color == type }
        guard let max = roundsSeen.max(of: \.count) else {
            return 0
        }
        return max
    }
}
