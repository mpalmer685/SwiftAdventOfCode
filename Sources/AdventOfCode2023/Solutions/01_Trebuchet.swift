import AOCKit

struct Trebuchet: Puzzle {
    static let day = 1

    func part1(input: Input) throws -> Int {
        input.lines.map { line in
            let digits = line.digits
            let first = digits.first!
            let last = digits.last!
            return first * 10 + last
        }.sum
    }

    func part2(input: Input) throws -> Int {
        let numbers = [
            "one": 1,
            "two": 2,
            "three": 3,
            "four": 4,
            "five": 5,
            "six": 6,
            "seven": 7,
            "eight": 8,
            "nine": 9,
        ]
        let values = input.lines.map { line in
            var scanner = Scanner(line.raw)
            var digits = [Int]()
            scanning: while scanner.hasMore {
                if let digit = scanner.tryScanDigit() {
                    digits.append(digit)
                    continue scanning
                }

                for (number, digit) in numbers where scanner.starts(with: number) {
                    digits.append(digit)
                    scanner.next()
                    continue scanning
                }

                scanner.next()
            }
            return digits.first! * 10 + digits.last!
        }
        return values.sum
    }
}
