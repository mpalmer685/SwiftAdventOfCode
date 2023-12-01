import AOCKit

struct FullOfHotAir: Puzzle {
    static let day = 25

    func part1(input: Input) throws -> String {
        let numbers = input.lines.raw.map { Int(snafu: $0) }
        return numbers.sum.snafuValue
    }
}

private extension Int {
    private static var fromSnafuDigits: [Character: Int] {
        ["2": 2, "1": 1, "0": 0, "-": -1, "=": -2]
    }

    private static var toSnafuDigits: [Int: String] {
        [2: "2", 1: "1", 0: "0", -1: "-", -2: "="]
    }

    init(snafu: String) {
        self = snafu.reduce(0) { $0 * 5 + Self.fromSnafuDigits[$1]! }
    }

    var snafuValue: String {
        guard self != 0 else { return "" }
        let r = self % 5
        switch r {
            case 0 ... 2:
                return (self / 5).snafuValue + Self.toSnafuDigits[r]!
            case 3 ... 4:
                return (self / 5 + 1).snafuValue + Self.toSnafuDigits[r - 5]!
            default:
                fatalError()
        }
    }
}
