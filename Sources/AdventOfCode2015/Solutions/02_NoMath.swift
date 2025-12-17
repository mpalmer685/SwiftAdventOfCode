import AOCKit

struct NoMath: Puzzle {
    static let day = 2

    func part1(input: Input) async throws -> Int {
        let boxes = input.lines.map { line in
            line.words(separatedBy: "x").integers.sorted()
        }

        return boxes.sum { dimensions in
            let (l, w, h) = (dimensions[0], dimensions[1], dimensions[2])
            let surfaceArea = 2 * l * w + 2 * w * h + 2 * h * l
            let overlap = l * w
            return surfaceArea + overlap
        }
    }

    func part2(input: Input) async throws -> Int {
        let boxes = input.lines.map { line in
            line.words(separatedBy: "x").integers.sorted()
        }

        return boxes.sum { dimensions in
            let (l, w, h) = (dimensions[0], dimensions[1], dimensions[2])
            let ribbon = 2 * l + 2 * w
            let bow = l * w * h
            return ribbon + bow
        }
    }
}

extension NoMath: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.raw("2x3x4")).expects(part1: 58, part2: 34),
            .given(.raw("1x1x10")).expects(part1: 43, part2: 14),
            .given(.raw("2x3x4\n1x1x10\n")).expects(part1: 101, part2: 48),
        ]
    }
}
