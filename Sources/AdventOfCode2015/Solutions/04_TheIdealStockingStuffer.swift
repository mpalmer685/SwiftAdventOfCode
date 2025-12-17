import AOCKit
import CryptoKit

struct TheIdealStockingStuffer: Puzzle {
    static let day = 4

    func part1(input: Input) async throws -> Int {
        lowestNumber(for: input.raw, leadingZeros: 5)
    }

    func part2(input: Input) async throws -> Int {
        lowestNumber(for: input.raw, leadingZeros: 6)
    }

    private func lowestNumber(for secretKey: String, leadingZeros: Int) -> Int {
        let prefix = String(repeating: "0", count: leadingZeros)
        let lowestNumber = (1 ... 100_000_000).first { number in
            let hash = md5Hash(of: "\(secretKey)\(number)")
            return hash.hasPrefix(prefix)
        }
        guard let lowestNumber else {
            fatalError("No solution found")
        }
        return lowestNumber
    }
}

private func md5Hash(of string: String) -> String {
    let digest = Insecure.MD5.hash(data: Data(string.utf8))
    return digest.map { String(format: "%02x", $0) }.joined()
}

extension TheIdealStockingStuffer: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.raw("abcdef")).expects(part1: 609_043),
            .given(.raw("pqrstuv")).expects(part1: 1_048_970),
        ]
    }
}
