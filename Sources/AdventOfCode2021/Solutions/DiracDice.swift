import AOCKit
import Foundation

struct DiracDice: Puzzle {
    static let day = 21

    func part1() throws -> Int {
        let (p1, p2) = parseInput()
        var die = DeterministicDie()
        var game: GameState = .starting(player1Position: p1, player2Position: p2)
        while !game.hasWinner(forScore: 1000) {
            let roll = die.roll()
            game = game.nextState(forRoll: roll)
        }
        return game.losingScore * die.rolls
    }

    func part2() throws -> Int {
        let rollMultipliers = [0, 0, 0, 1, 3, 6, 7, 6, 3, 1]

        let (p1, p2) = parseInput()
        var wins: [Player: Int] = [:]

        func play(_ game: GameState, winMultiplier: Int = 1) {
            for roll in 3 ... 9 {
                let nextState = game.nextState(forRoll: roll)
                if nextState.winner(forScore: 21) == game.currentPlayer {
                    wins[game.currentPlayer, default: 0] += winMultiplier * rollMultipliers[roll]
                } else {
                    play(nextState, winMultiplier: winMultiplier * rollMultipliers[roll])
                }
            }
        }
        play(.starting(player1Position: p1, player2Position: p2))

        guard let winner = wins.max(by: \.value) else { fatalError() }
        return winner.value
    }

    private func parseInput() -> (Int, Int) {
        let lines = input().lines.raw
        let pattern = NSRegularExpression("(\\d+)$")
        guard let m1 = pattern.match(lines[0]), let m2 = pattern.match(lines[1]) else {
            fatalError()
        }
        guard let p1Position = Int(m1[1]), let p2Position = Int(m2[1]) else { fatalError() }
        return (p1Position, p2Position)
    }
}

private enum Player: CustomStringConvertible {
    case one, two

    var opponent: Self {
        switch self {
            case .one: return .two
            case .two: return .one
        }
    }

    var description: String {
        switch self {
            case .one: return "Player 1"
            case .two: return "Player 2"
        }
    }
}

private struct GameState: Hashable {
    static func starting(player1Position: Int, player2Position: Int) -> Self {
        GameState(
            currentPlayer: .one,
            scores: [.one: 0, .two: 0],
            positions: [.one: player1Position, .two: player2Position]
        )
    }

    private(set) var currentPlayer: Player
    private(set) var scores: [Player: Int]
    private(set) var positions: [Player: Int]

    func nextState(forRoll roll: Int) -> GameState {
        guard let currentPosition = positions[currentPlayer],
              let currentScore = scores[currentPlayer]
        else {
            fatalError()
        }
        let nextPosition = (currentPosition + roll) % 10
        let scoreAtPosition = nextPosition == 0 ? 10 : nextPosition

        var nextState = self
        nextState.currentPlayer = currentPlayer.opponent
        nextState.positions[currentPlayer] = nextPosition
        nextState.scores[currentPlayer] = currentScore + scoreAtPosition
        return nextState
    }

    func hasWinner(forScore score: Int) -> Bool {
        winner(forScore: score) != nil
    }

    func winner(forScore score: Int) -> Player? {
        scores.first(where: { $0.value >= score })?.key
    }

    var winningScore: Int { scores.max(by: \.value)!.value }
    var losingScore: Int { scores.min(by: \.value)!.value }
}

private struct DeterministicDie {
    private(set) var rolls: Int = 0
    private var next = 1

    private mutating func rollOnce() -> Int {
        let roll = next
        next += 1
        rolls += 1
        return roll
    }

    mutating func roll() -> Int {
        rollOnce() + rollOnce() + rollOnce()
    }
}

private let testInput = """
Player 1 starting position: 4
Player 2 starting position: 8
"""
