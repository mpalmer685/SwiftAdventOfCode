import AOCKit

struct CorporatePolicy: Puzzle {
    static let day = 11

    func part1(input: Input) async throws -> String {
        func isValid(_ password: String) -> Bool {
            let chars = Array(password)

            // Rule 1: Increasing straight of at least three letters
            var hasStraight = false
            for i in 0 ..< (chars.count - 2) {
                if chars[i].asciiValue! + 1 == chars[i + 1].asciiValue!,
                   chars[i + 1].asciiValue! + 1 == chars[i + 2].asciiValue!
                {
                    hasStraight = true
                    break
                }
            }
            guard hasStraight else { return false }

            // Rule 2: No 'i', 'o', or 'l'
            guard !chars.contains(where: { $0 == "i" || $0 == "o" || $0 == "l" }) else {
                return false
            }

            // Rule 3: At least two different, non-overlapping pairs of letters
            var pairCount = 0
            var i = 0
            while i < chars.count - 1 {
                if chars[i] == chars[i + 1] {
                    pairCount += 1
                    i += 2 // Skip the next character to avoid overlapping pairs
                } else {
                    i += 1
                }
            }
            return pairCount >= 2
        }

        var password = input.raw
        repeat {
            password = password.incremented()
        } while !isValid(password)
        return password
    }

    func part2(input: Input) async throws -> String {
        let first = try await part1(input: input)
        return try await part1(input: Input(first))
    }
}

private extension String {
    func incremented() -> Self {
        let (carried, newChars) = reversed().reduce((true, "")) { partial, char in
            let (carried, next) = partial
            guard carried else {
                return (false, String(char) + next)
            }

            if char == "z" {
                return (true, "a" + next)
            } else {
                let nextChar = Character(UnicodeScalar(char.asciiValue! + 1))
                return (false, String(nextChar) + next)
            }
        }

        if carried {
            return "a" + newChars
        } else {
            return newChars
        }
    }
}

extension CorporatePolicy: TestablePuzzle {
    var testCases: [TestCase<String, String>] {
        [
            .given(.raw("abcdefgh")).expects(part1: "abcdffaa"),
            .given(.raw("ghijklmn")).expects(part1: "ghjaabcc"),
        ]
    }
}
