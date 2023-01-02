import AOCKit

struct AllergenAssessment: Puzzle {
    static let day = 21

    func part1() throws -> Int {
        let (ingredients, allergens) = parseInput()
        let ingredientsByAllergen = mapAllergensToIngredients(
            ingredients: ingredients,
            allergens: allergens
        )
        let allergenicIngredients = Set(ingredientsByAllergen.values)
        return ingredients.values.sum {
            $0.count { !allergenicIngredients.contains($0) }
        }
    }

    func part2() throws -> String {
        let (ingredients, allergens) = parseInput()
        let ingredientsByAllergen = mapAllergensToIngredients(
            ingredients: ingredients,
            allergens: allergens
        )
        return ingredientsByAllergen.sorted(using: \.key)
            .map(\.value)
            .joined(separator: ",")
    }

    private func mapAllergensToIngredients(
        ingredients: [Int: [String]],
        allergens: [Int: [String]]
    ) -> [String: String] {
        let uniqueAllergens: Set<String> = allergens.reduce(into: Set()) { $0.formUnion($1.value) }
        var possibleIngredientsByAllergen: [String: Set<String>] = uniqueAllergens
            .reduce(into: [:]) { result, allergen in
                let foodsWithAllergen = allergens
                    .filter { $0.value.contains(allergen) }
                    .compactMap { ingredients[$0.key] }
                    .map(Set.init)
                result[allergen] = foodsWithAllergen
                    .reduce(into: foodsWithAllergen.first!) { $0.formIntersection($1) }
            }

        var allergenicIngredients: [String: String] = [:]
        while !possibleIngredientsByAllergen.isEmpty {
            let (allergen, ingredients) = possibleIngredientsByAllergen
                .first { $0.value.count == 1 }!
            let ingredient = ingredients.first!
            allergenicIngredients[allergen] = ingredient
            removeInstances(of: ingredient, from: &possibleIngredientsByAllergen)
        }

        return allergenicIngredients
    }

    private func removeInstances<Key, Element: Equatable>(
        of item: Element,
        from dict: inout [Key: Set<Element>]
    ) {
        for (key, var value) in dict {
            if value.count == 1, value.first! == item {
                dict[key] = nil
            } else {
                value.remove(item)
                dict[key] = value
            }
        }
    }

    private func parseInput() -> FoodList {
        var ingredients = [Int: [String]]()
        var allergens = [Int: [String]]()

        let lines = input().lines
        for (id, line) in lines.enumerated() {
            let parts = line.words(separatedBy: " (contains ")
            let ingredientsList = parts[0].words(separatedBy: .whitespaces).raw
            let allergenList = parts[1].trimmingCharacters(in: ["(", ")"]).raw
                .components(separatedBy: ", ")
            ingredients[id] = ingredientsList
            allergens[id] = allergenList
        }

        return (ingredients, allergens)
    }
}

private typealias FoodList = (ingredients: [Int: [String]], allergens: [Int: [String]])
