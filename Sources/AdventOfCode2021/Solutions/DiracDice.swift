import AOCKit

struct DiracDice: Puzzle {
    static let day = 21

    func part1(input: Input) throws -> Int {
        let (p1Start, p2Start) = parse(input)
        var die = DeterministicDie()
        var game = GameState(player1Position: p1Start, player2Position: p2Start)
        while !game.hasWinner(forScore: 1000) {
            game = game.nextState(for: die.roll())
        }
        return game.losingScore * die.rolls
    }

    func part2(input: Input) throws -> Int {
        /*
         If you roll a 3-sided die 3 times, the minimum you can roll is 3 and the max is 9.
         The distribution of (score, number of combinations that add to score) is:
           3: 1 (1,1,1)
           4: 3
           5: 6
           6: 7
           7: 6
           8: 3
           9: 1 (3,3,3)
         */
        let rolls = [
            3: 1,
            4: 3,
            5: 6,
            6: 7,
            7: 6,
            8: 3,
            9: 1,
        ]

        var outcomeCounts: [GameState: (Int, Int)] = [:]

        func countWins(from state: GameState) -> (Int, Int) {
            if let wins = state.wins(forScore: 21) {
                return wins
            }
            if let seen = outcomeCounts[state] {
                return seen
            }

            var answer = (p1: 0, p2: 0)
            for (roll, multiplier) in rolls {
                let nextState = state.nextState(for: roll)
                // in next state, p1 and p2 have swapped
                let (p2wins, p1wins) = countWins(from: nextState)
                answer.p1 += p1wins * multiplier
                answer.p2 += p2wins * multiplier
            }

            outcomeCounts[state] = answer
            return answer
        }

        let (p1Start, p2Start) = parse(input)
        let start = GameState(player1Position: p1Start, player2Position: p2Start)
        let (p1wins, p2wins) = countWins(from: start)
        return max(p1wins, p2wins)
    }

    private func parse(_ input: Input) -> (Int, Int) {
        let numbers = input.lines.compactMap { $0.integers.last! }
        guard numbers.count == 2 else { fatalError() }
        return (numbers[0], numbers[1])
    }
}

private struct GameState: Hashable {
    let player1Position: Int
    let player2Position: Int

    let player1Score: Int
    let player2Score: Int

    init(player1Position: Int, player2Position: Int, player1Score: Int = 0, player2Score: Int = 0) {
        self.player1Position = player1Position
        self.player2Position = player2Position
        self.player1Score = player1Score
        self.player2Score = player2Score
    }

    func nextState(for roll: Int) -> Self {
        let nextPosition = (player1Position + roll) % 10
        let scoreAtPosition = nextPosition == 0 ? 10 : nextPosition

        // switch player 1 and player 2 so that player 1 is always the "current" player
        return GameState(
            player1Position: player2Position,
            player2Position: nextPosition,
            player1Score: player2Score,
            player2Score: player1Score + scoreAtPosition
        )
    }

    func hasWinner(forScore score: Int) -> Bool {
        wins(forScore: score) != nil
    }

    func wins(forScore score: Int) -> (Int, Int)? {
        if player1Score >= score { return (1, 0) }
        if player2Score >= score { return (0, 1) }
        return nil
    }

    var winningScore: Int { max(player1Score, player2Score) }
    var losingScore: Int { min(player1Score, player2Score) }
}

private struct DeterministicDie {
    private(set) var rolls: Int = 0

    private mutating func rollOnce() -> Int {
        defer { rolls += 1 }
        return rolls + 1
    }

    mutating func roll() -> Int {
        rollOnce() + rollOnce() + rollOnce()
    }
}

private let testInput = """
Player 1 starting position: 4
Player 2 starting position: 8
"""
