import AOCKit
import Foundation

class NotEnoughMinerals: Puzzle {
    static let day = 19

    func part1() throws -> Int {
        func quality(of blueprint: Blueprint) -> Int {
            let factory = Factory(blueprint, minutesToRun: 24)
            let geodes = findMaxGeodes(for: factory)
            return blueprint.id * geodes
        }

        let blueprints = input().lines.map(Blueprint.init)
        return blueprints.map { quality(of: $0) }.sum
    }

    func part2() throws -> Int {
        func geodesCollected(by blueprint: Blueprint) -> Int {
            let factory = Factory(blueprint, minutesToRun: 32)
            return findMaxGeodes(for: factory)
        }

        let blueprints = input().lines[0 ..< 3].map(Blueprint.init)
        return blueprints.map { geodesCollected(by: $0) }.product
    }

    private func findMaxGeodes(for factory: Factory) -> Int {
        if factory.finished {
            return factory.geodes
        }

        var maxGeodes = 0
        for type in Mineral.allCases where factory.canBuild(type) && factory.shouldBuild(type) {
            let nextFactory = factory.buildNext(type)
            let geodes = findMaxGeodes(for: nextFactory)
            maxGeodes = max(geodes, maxGeodes)
        }
        return maxGeodes
    }
}

private enum Mineral: String, CaseIterable {
    case ore, clay, obsidian, geode
}

private struct Factory {
    let blueprint: Blueprint

    private var robots: [Mineral: Int]
    private var materials: [Mineral: Int]

    private let maxTime: Int
    private var currentTime: Int

    var finished: Bool { currentTime > maxTime }
    var timeRemaining: Int { maxTime - currentTime + 1 }

    var geodes: Int { materials[.geode] ?? 0 }

    init(_ blueprint: Blueprint, minutesToRun: Int) {
        self.blueprint = blueprint
        robots = [.ore: 1]
        materials = [:]
        maxTime = minutesToRun
        currentTime = 1
    }

    private(set) subscript(robot type: Mineral) -> Int {
        get { robots[type] ?? 0 }
        set { robots[type] = newValue }
    }

    private(set) subscript(material type: Mineral) -> Int {
        get { materials[type] ?? 0 }
        set { materials[type] = newValue }
    }

    func buildNext(_ type: Mineral) -> Self {
        assert(!finished)

        var next = self
        var robotBuilt = false
        while !next.finished, !robotBuilt {
            robotBuilt = next.runOnce(building: type)
        }
        return next
    }

    private mutating func runOnce(building type: Mineral) -> Bool {
        guard !finished else { return false }

        let willBuild = canBuildNow(type)
        gatherMaterials()

        if willBuild {
            build(type)
        }

        currentTime += 1
        return willBuild
    }

    // Returns true if we have a robot to collect each required mineral
    func canBuild(_ type: Mineral) -> Bool {
        blueprint[type].allSatisfy { _, mineral in self[robot: mineral] > 0 }
    }

    private func canBuildNow(_ type: Mineral) -> Bool {
        blueprint[type].allSatisfy { required, mineral -> Bool in
            self[material: mineral] >= required
        }
    }

    func shouldBuild(_ type: Mineral) -> Bool {
        if type == .geode { return true }

        let robotCount = self[robot: type]
        let gathered = self[material: type]
        let maxNeeded = blueprint.recipes.values.max(of: { r -> Int in
            (r.first { $0.1 == type }?.0) ?? 0
        })!

        return robotCount * timeRemaining + gathered < timeRemaining * maxNeeded
    }

    private mutating func build(_ type: Mineral) {
        assert(canBuildNow(type))
        let requirements = blueprint[type]
        for (required, mineral) in requirements {
            self[material: mineral] -= required
        }
        self[robot: type] += 1
    }

    private mutating func gatherMaterials() {
        for (mineral, count) in robots {
            self[material: mineral] += count
        }
    }
}

private struct Blueprint {
    typealias Costs = [(Int, Mineral)]
    typealias Recipes = [Mineral: Costs]

    let id: Int
    let recipes: Recipes

    subscript(_ mineral: Mineral) -> Costs {
        recipes[mineral]!
    }

    init(_ line: Line) {
        let chunks = line.trimmingCharacters(in: .period).words(separatedBy: .periodOrColon)

        id = chunks[0].words(separatedBy: .whitespaces).integers.first!
        recipes = chunks.dropFirst().reduce(into: Recipes()) { recipes, word in
            let words = word.words(separatedBy: .whitespaces)
            let mineral = Mineral(rawValue: words[1].raw)!
            var recipe = Costs()
            for i in stride(from: 4, to: words.count, by: 3) {
                guard let count = words[i].integer else {
                    fatalError()
                }
                guard let mineral = Mineral(rawValue: words[i + 1].raw) else {
                    fatalError()
                }
                recipe.append((count, mineral))
            }
            recipes[mineral] = recipe
        }
    }
}

extension Blueprint: CustomStringConvertible {
    public var description: String {
        "Blueprint \(id): " + Mineral.allCases.map { mineral -> String in
            let recipe = recipes[mineral]!
            return "Each \(mineral) robot costs \(describe(recipe))."
        }.joined(separator: " ")
    }
}

private func describe(_ recipe: Blueprint.Costs) -> String {
    recipe.map { "\($1) \($0)" }.joined(separator: " and ")
}

private extension CharacterSet {
    static let period = CharacterSet(charactersIn: ".")
    static let periodOrColon = CharacterSet(charactersIn: ".:")
}
