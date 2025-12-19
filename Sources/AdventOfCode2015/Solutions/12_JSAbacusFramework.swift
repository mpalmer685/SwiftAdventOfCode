import AOCKit

struct JSAbacusFramework: Puzzle {
    static let day = 12

    func part1(input: Input) async throws -> Int {
        let raw = try JSONSerialization.jsonObject(with: Data(input.raw.utf8))
        return sumNumbers(in: raw)
    }

    func part2(input: Input) async throws -> Int {
        let raw = try JSONSerialization.jsonObject(with: Data(input.raw.utf8))
        return sumNumbers(in: raw) { dict in
            dict.values.contains { value in
                if let str = value as? String, str == "red" {
                    return true
                }
                return false
            }
        }
    }

    private func sumNumbers(in value: Any, ignoreWhen: (([String: Any]) -> Bool)? = nil) -> Int {
        if let number = value as? Int {
            return number
        } else if let array = value as? [Any] {
            return array.sum { sumNumbers(in: $0, ignoreWhen: ignoreWhen) }
        } else if let dict = value as? [String: Any] {
            if let ignoreWhen, ignoreWhen(dict) {
                return 0
            }
            return dict.values.sum { sumNumbers(in: $0, ignoreWhen: ignoreWhen) }
        } else {
            return 0
        }
    }
}

extension JSAbacusFramework: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.raw("[1,2,3]")).expects(part1: 6, part2: 6),
            .given(.raw("{\"a\":2,\"b\":4}")).expects(part1: 6),
            .given(.raw("[[[3]]]")).expects(part1: 3),
            .given(.raw("{\"a\":{\"b\":4},\"c\":-1}")).expects(part1: 3),
            .given(.raw("{\"a\":[-1,1]}")).expects(part1: 0),
            .given(.raw("[-1,{\"a\":1}]")).expects(part1: 0),
            .given(.raw("[]")).expects(part1: 0),
            .given(.raw("{}")).expects(part1: 0),

            .given(.raw("[1,{\"c\":\"red\",\"b\":2},3]")).expects(part2: 4),
            .given(.raw("{\"d\":\"red\",\"e\":[1,2,3,4],\"f\":5}")).expects(part2: 0),
            .given(.raw("[1,\"red\",5]")).expects(part2: 6),
        ]
    }
}
