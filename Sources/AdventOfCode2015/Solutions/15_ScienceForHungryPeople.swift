import AOCKit

struct ScienceForHungryPeople: Puzzle {
    static let day = 15

    func part1(input: Input) async throws -> Int {
        let ingredients = parseIngredients(from: input)
        return maxScore(for: ingredients)
    }

    func part2(input: Input) async throws -> Int {
        let ingredients = parseIngredients(from: input)
        return maxScore(for: ingredients, withCalorieTarget: 500)
    }

    private func maxScore(
        for ingredients: [Ingredient],
        withCalorieTarget calorieTarget: Int? = nil,
    ) -> Int {
        var maxScore = 0
        let ingredientCount = ingredients.count

        func backtrack(remainingTeaspoons: Int, recipe: Recipe) {
            if recipe.count == ingredientCount - 1 {
                let lastIngredient = ingredients[recipe.count]
                let finalRecipe = recipe + [(lastIngredient, remainingTeaspoons)]

                if let calorieTarget {
                    let totalCalories = finalRecipe.sum { $0.ingredient.calories * $0.teaspoons }
                    guard totalCalories == calorieTarget else { return }
                }

                let score = score(for: finalRecipe)
                maxScore = max(maxScore, score)
                return
            }

            let currentIngredient = ingredients[recipe.count]
            for teaspoons in 0 ... remainingTeaspoons {
                backtrack(
                    remainingTeaspoons: remainingTeaspoons - teaspoons,
                    recipe: recipe + [(currentIngredient, teaspoons)],
                )
            }
        }

        backtrack(remainingTeaspoons: 100, recipe: [])
        return maxScore
    }

    private typealias Recipe = [(ingredient: Ingredient, teaspoons: Int)]

    private func score(for recipe: Recipe) -> Int {
        var capacity = 0
        var durability = 0
        var flavor = 0
        var texture = 0

        for (ingredient, teaspoons) in recipe {
            capacity += ingredient.capacity * teaspoons
            durability += ingredient.durability * teaspoons
            flavor += ingredient.flavor * teaspoons
            texture += ingredient.texture * teaspoons
        }

        capacity = max(0, capacity)
        durability = max(0, durability)
        flavor = max(0, flavor)
        texture = max(0, texture)

        return capacity * durability * flavor * texture
    }

    private func parseIngredients(from input: Input) -> [Ingredient] {
        let parser = Parse(input: Substring.self, Ingredient.init) {
            Prefix { !$0.isWhitespace && $0 != ":" }.map(String.init)
            ": capacity "
            Int.parser()
            ", durability "
            Int.parser()
            ", flavor "
            Int.parser()
            ", texture "
            Int.parser()
            ", calories "
            Int.parser()
        }

        return input.lines.raw.compactMap { try? parser.parse($0) }
    }
}

private struct Ingredient {
    let name: String
    let capacity: Int
    let durability: Int
    let flavor: Int
    let texture: Int
    let calories: Int
}

extension ScienceForHungryPeople: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.example).expects(part1: 62_842_880, part2: 57_600_000),
        ]
    }
}
