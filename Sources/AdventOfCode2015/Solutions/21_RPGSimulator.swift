import AOCKit

struct RPGSimulator: Puzzle {
    static let day = 21

    func part1(input: Input) async throws -> Int {
        let boss = parseBossStats(from: input)
        let options = equipmentCombinations().sorted(using: { $0.sum(of: \.cost) })
        let best = options.first { equipment in
            let playerStats: PlayerStats = (
                100,
                equipment.sum(of: \.damage),
                equipment.sum(of: \.armor),
            )
            return playerWins(withStats: playerStats, against: boss)
        }
        guard let best else {
            fatalError("No winning equipment combination found")
        }
        return best.sum(of: \.cost)
    }

    func part2(input: Input) async throws -> Int {
        let boss = parseBossStats(from: input)
        let options = equipmentCombinations().sorted(using: { $0.sum(of: \.cost) }).reversed()
        let worst = options.first { equipment in
            let playerStats: PlayerStats = (
                100,
                equipment.sum(of: \.damage),
                equipment.sum(of: \.armor),
            )
            return !playerWins(withStats: playerStats, against: boss)
        }
        guard let worst else {
            fatalError("No losing equipment combination found")
        }
        return worst.sum(of: \.cost)
    }

    private func equipmentCombinations() -> [[Store.Item]] {
        let weaponOptions = Store.weapons
        let armorOptions = Store.armors.combinations(ofCount: 0...)
        let ringOptions = Store.rings.combinations(ofCount: 0 ... 2)

        return weaponOptions.flatMap { weapon in
            armorOptions.flatMap { armors in
                ringOptions.map { rings in
                    [weapon] + armors + rings
                }
            }
        }
    }

    private typealias PlayerStats = (hitPoints: Int, damage: Int, armor: Int)

    private func playerWins(withStats player: PlayerStats, against boss: PlayerStats) -> Bool {
        let playerDamagePerTurn = max(1, player.damage - boss.armor)
        let bossDamagePerTurn = max(1, boss.damage - player.armor)

        let playerTurnsToWin = boss.hitPoints.isMultiple(of: playerDamagePerTurn)
            ? boss.hitPoints / playerDamagePerTurn
            : (boss.hitPoints / playerDamagePerTurn) + 1
        let bossTurnsToWin = player.hitPoints.isMultiple(of: bossDamagePerTurn)
            ? player.hitPoints / bossDamagePerTurn
            : (player.hitPoints / bossDamagePerTurn) + 1

        return playerTurnsToWin <= bossTurnsToWin
    }

    private func parseBossStats(from input: Input) -> PlayerStats {
        var hitPoints = 0
        var damage = 0
        var armor = 0

        for line in input.lines {
            let components = line.words(separatedBy: ": ")
            guard components.count == 2, let value = components[1].integer else {
                continue
            }

            switch components[0].raw {
                case "Hit Points":
                    hitPoints = value
                case "Damage":
                    damage = value
                case "Armor":
                    armor = value
                default:
                    continue
            }
        }

        return (hitPoints, damage, armor)
    }
}

private enum Store {
    static let weapons: [Item] = [
        Item(name: "Dagger", cost: 8, damage: 4, armor: 0),
        Item(name: "Shortsword", cost: 10, damage: 5, armor: 0),
        Item(name: "Warhammer", cost: 25, damage: 6, armor: 0),
        Item(name: "Longsword", cost: 40, damage: 7, armor: 0),
        Item(name: "Greataxe", cost: 74, damage: 8, armor: 0),
    ]

    static let armors: [Item] = [
        Item(name: "Leather", cost: 13, damage: 0, armor: 1),
        Item(name: "Chainmail", cost: 31, damage: 0, armor: 2),
        Item(name: "Splintmail", cost: 53, damage: 0, armor: 3),
        Item(name: "Bandedmail", cost: 75, damage: 0, armor: 4),
        Item(name: "Platemail", cost: 102, damage: 0, armor: 5),
    ]

    static let rings: [Item] = [
        Item(name: "Damage +1", cost: 25, damage: 1, armor: 0),
        Item(name: "Damage +2", cost: 50, damage: 2, armor: 0),
        Item(name: "Damage +3", cost: 100, damage: 3, armor: 0),
        Item(name: "Defense +1", cost: 20, damage: 0, armor: 1),
        Item(name: "Defense +2", cost: 40, damage: 0, armor: 2),
        Item(name: "Defense +3", cost: 80, damage: 0, armor: 3),
    ]

    struct Item {
        let name: String
        let cost: Int
        let damage: Int
        let armor: Int
    }
}
