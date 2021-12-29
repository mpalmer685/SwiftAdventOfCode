import AOCKit
import Foundation

struct ArithmeticLogicUnit: Puzzle {
    func part1Solution(for input: String) throws -> Int {
        let parameters = parse(input)
        return findModelNumber(using: parameters, choosingNextValueWith: max)
    }

    func part2Solution(for input: String) throws -> Int {
        let parameters = parse(input)
        return findModelNumber(using: parameters, choosingNextValueWith: min)
    }

    private func parse(_ input: String) -> [(Int, Int, Int)] {
        let operations = getLines(from: input).map(Operation.init)

        var parameters = [(Int, Int, Int)]()
        for i in stride(from: 0, to: 18 * 14, by: 18) {
            guard let p1 = operations[i + 4].value,
                  let p2 = operations[i + 5].value,
                  let p3 = operations[i + 15].value else { fatalError() }
            parameters.append((p1, p2, p3))
        }
        return parameters
    }
}

private func findModelNumber(
    using parameters: [(Int, Int, Int)],
    choosingNextValueWith chooseNextValue: (Int, Int) -> Int
) -> Int {
    func nextValue(_ params: (Int, Int, Int), z: Int, w: Int) -> Int {
        (z % 26 + params.1 == w) ? z / params.0 : 26 * z / params.0 + w + params.2
    }

    var valuesForZ: [Int: Int] = [0: 0]
    for params in parameters {
        var newValuesForZ: [Int: Int] = [:]
        for z in valuesForZ.keys {
            for digit in 1 ... 9 {
                let newZ = nextValue(params, z: z, w: digit)
                if params.0 == 1 || (params.0 == 26 && newZ < z) {
                    let newValue = valuesForZ[z, default: 0] * 10 + digit
                    if let oldValue = newValuesForZ[newZ] {
                        newValuesForZ[newZ] = chooseNextValue(oldValue, newValue)
                    } else {
                        newValuesForZ[newZ] = newValue
                    }
                }
            }
        }
        valuesForZ = newValuesForZ
    }

    guard let result = valuesForZ[0] else { fatalError() }
    return result
}

private struct Operation {
    let instruction: String
    let destination: String
    let value: Int?

    init(line: String) {
        let parts = line.components(separatedBy: " ")
        instruction = parts[0]
        destination = parts[1]
        value = parts.count > 2 ? Int(parts[2]) : nil
    }
}
