import AOCKit

struct WizardSimulator: Puzzle {
    static let day = 22

    func part1(input: Input) async throws -> Int {
        let (bossHitPoints, bossDamage) = try parseBossStats(from: input)
        let game = Game(bossHitPoints: bossHitPoints, bossDamage: bossDamage)
        return game.minimumCostToWin
    }

    func part2(input: Input) async throws -> Int {
        let (bossHitPoints, bossDamage) = try parseBossStats(from: input)
        let game = Game(bossHitPoints: bossHitPoints, bossDamage: bossDamage, hardMode: true)
        return game.minimumCostToWin
    }

    private func parseBossStats(from input: Input) throws -> (hitPoints: Int, damage: Int) {
        let parser = Parse(input: Substring.self) {
            "Hit Points: "
            Int.parser()
            "\n"
            "Damage: "
            Int.parser()
        }
        return try parser.parse(input.raw)
    }
}

private struct Game: WeightedGraph {
    let initialState: GameState
    let hardMode: Bool

    init(bossHitPoints: Int, bossDamage: Int, hardMode: Bool = false) {
        self.hardMode = hardMode
        initialState = GameState(
            player: Player(hitPoints: 50, mana: 500, damage: 0, armor: 0),
            boss: Player(hitPoints: bossHitPoints, mana: 0, damage: bossDamage, armor: 0),
            playersTurn: true,
        )
    }

    var minimumCostToWin: Int {
        costOfPath(from: initialState) { $0.boss.hitPoints <= 0 }
    }

    func neighbors(of currentState: GameState) -> [(GameState, Int)] {
        var newState = currentState
        newState.playersTurn.toggle()

        if hardMode, currentState.playersTurn {
            newState.player.hitPoints -= 1
        }

        guard !newState.hasLost else {
            return []
        }

        newState.applyActiveEffects()

        if newState.hasWon {
            return [(newState, 0)]
        }

        guard currentState.playersTurn else {
            newState.player.hitPoints -= max(1, newState.boss.damage - newState.player.armor)
            return [(newState, 0)]
        }

        return Spell.spells
            .filter { $0.canBeCast(on: newState) }
            .map { spell -> (GameState, Int) in
                var stateAfterSpell = newState
                spell.cast(on: &stateAfterSpell)
                return (stateAfterSpell, spell.cost)
            }
    }
}

private struct Player: Hashable {
    var hitPoints: Int
    var mana: Int
    var damage: Int
    var armor: Int
}

private struct GameState: Hashable {
    var player: Player
    var boss: Player
    var playersTurn: Bool

    var activeEffects: [Effect.Name: Effect] = [:]

    var hasWon: Bool { boss.hitPoints <= 0 }
    var hasLost: Bool { player.hitPoints <= 0 || (playersTurn && player.mana <= 53) }

    mutating func applyActiveEffects() {
        for var effect in activeEffects.values {
            effect.tick(&self)
        }
    }
}

private struct Spell: Sendable {
    let name: String
    let cost: Int
    private let apply: @Sendable (inout GameState) -> Void
    private let canApply: (@Sendable (GameState) -> Bool)?

    private init(
        name: String,
        cost: Int,
        apply: @escaping @Sendable (inout GameState) -> Void,
        canApply: (@Sendable (GameState) -> Bool)? = nil,
    ) {
        self.name = name
        self.cost = cost
        self.apply = apply
        self.canApply = canApply
    }

    func canBeCast(on state: GameState) -> Bool {
        guard state.player.mana >= cost else { return false }
        guard let canApply else { return true }
        return canApply(state)
    }

    func cast(on state: inout GameState) {
        apply(&state)
        state.player.mana -= cost
    }

    static let spells: [Self] = [
        .magicMissile,
        .drain,
        .shield,
        .poison,
        .recharge,
    ]

    static let magicMissile = Self(
        name: "Magic Missile",
        cost: 53,
        apply: { state in
            state.boss.hitPoints -= 4
        },
    )
    static let drain = Self(
        name: "Drain",
        cost: 73,
        apply: { state in
            state.boss.hitPoints -= 2
            state.player.hitPoints += 2
        },
    )
    static let shield = Self(
        name: "Shield",
        cost: 113,
        apply: { state in
            state.activeEffects[.shield] = .shield()
            state.player.armor = 7
        },
        canApply: { state in
            state.activeEffects[.shield] == nil
        },
    )
    static let poison = Self(
        name: "Poison",
        cost: 173,
        apply: { state in
            state.activeEffects[.poison] = .poison()
        },
        canApply: { state in
            state.activeEffects[.poison] == nil
        },
    )
    static let recharge = Self(
        name: "Recharge",
        cost: 229,
        apply: { state in
            state.activeEffects[.recharge] = .recharge()
        },
        canApply: { state in
            state.activeEffects[.recharge] == nil
        },
    )
}

private struct Effect: Sendable {
    let name: Name
    let duration: Int
    let onTick: @Sendable (inout GameState) -> Void
    let onRemove: @Sendable (inout GameState) -> Void

    var ticksRemaining = 0

    private init(
        name: Name,
        duration: Int,
        onTick: (@escaping @Sendable (inout GameState) -> Void) = { _ in },
        onRemove: (@escaping @Sendable (inout GameState) -> Void) = { _ in },
    ) {
        self.name = name
        self.duration = duration
        self.onTick = onTick
        self.onRemove = onRemove
        ticksRemaining = duration
    }

    static func shield() -> Self {
        .init(
            name: .shield,
            duration: 6,
            onRemove: { state in
                state.player.armor = 0
            },
        )
    }

    static func poison() -> Self {
        .init(
            name: .poison,
            duration: 6,
            onTick: { state in
                state.boss.hitPoints -= 3
            },
        )
    }

    static func recharge() -> Self {
        .init(
            name: .recharge,
            duration: 5,
            onTick: { state in
                state.player.mana += 101
            },
        )
    }

    mutating func tick(_ state: inout GameState) {
        onTick(&state)
        ticksRemaining -= 1

        if ticksRemaining <= 0 {
            onRemove(&state)
            state.activeEffects.removeValue(forKey: name)
        } else {
            state.activeEffects[name] = self
        }
    }

    enum Name {
        case shield
        case poison
        case recharge
    }
}

extension Effect: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(ticksRemaining)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name && lhs.ticksRemaining == rhs.ticksRemaining
    }
}
