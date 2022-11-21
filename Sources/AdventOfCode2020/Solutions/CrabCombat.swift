import AOCKit

struct CrabCombat: Puzzle {
    static let day = 22

    func part1() throws -> Int {
        let (player1, player2) = parseInput()
        return getScoreForGame(player1, against: player2, using: playCombat)
    }

    func part2() throws -> Int {
        let (player1, player2) = parseInput()
        return getScoreForGame(player1, against: player2, using: playRecursiveCombat)
    }

    private func getScoreForGame(
        _ player1: [Int],
        against player2: [Int],
        using playCombat: CombatGame
    ) -> Int {
        let winner = playCombat(player1, player2)
        return calculateScore(for: winner.deck)
    }

    private func calculateScore(for hand: [Int]) -> Int {
        hand.enumerated().reduce(0) { $0 + (hand.count - $1.offset) * $1.element }
    }

    private func parseInput() -> (player1: [Int], player2: [Int]) {
        let players = input().lines.filter(\.isNotEmpty)
            .split { $0.raw.starts(with: "Player") }
            .map(\.integers)
        return (players[0], players[1])
    }
}

private enum GameResult {
    case playerOne([Int])
    case playerTwo([Int])

    var deck: [Int] {
        switch self {
            case let .playerOne(deck): return deck
            case let .playerTwo(deck): return deck
        }
    }
}

private typealias CombatGame = ([Int], [Int]) -> GameResult

private func playCombat(player1: [Int], player2: [Int]) -> GameResult {
    var player1 = player1,
        player2 = player2
    while !player1.isEmpty, !player2.isEmpty {
        let player1Card = player1.removeFirst()
        let player2Card = player2.removeFirst()

        if player1Card > player2Card {
            player1 += [player1Card, player2Card]
        } else if player2Card > player1Card {
            player2 += [player2Card, player1Card]
        }
    }

    return player1.isEmpty ? .playerTwo(player2) : .playerOne(player1)
}

private func playRecursiveCombat(player1: [Int], player2: [Int]) -> GameResult {
    var player1 = player1,
        player2 = player2
    var visitedStates: Set<[[Int]]> = []

    while !player1.isEmpty, !player2.isEmpty {
        let state = [player1, player2]
        if visitedStates.contains(state) { return .playerOne(player1) }
        visitedStates.insert(state)

        let player1Card = player1.removeFirst()
        let player2Card = player2.removeFirst()

        let result: GameResult
        if player1Card <= player1.count, player2Card <= player2.count {
            result = playRecursiveCombat(
                player1: Array(player1[..<player1Card]),
                player2: Array(player2[..<player2Card])
            )
        } else if player1Card > player2Card {
            result = .playerOne([])
        } else {
            result = .playerTwo([])
        }

        switch result {
            case .playerOne:
                player1 += [player1Card, player2Card]
            case .playerTwo:
                player2 += [player2Card, player1Card]
        }
    }

    return player1.isEmpty ? .playerTwo(player2) : .playerOne(player1)
}
