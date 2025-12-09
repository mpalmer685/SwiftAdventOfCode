import AOCKit
import simd

struct ClawContraption: Puzzle {
    static let day = 13

    func part1(input: Input) throws -> Int {
        let clawMachines = parse(input)
        return clawMachines.sum { $0.costToWin() }
    }

    func part2(input: Input) throws -> Int {
        let offset = 10_000_000_000_000
        let clawMachines = parse(input).map { $0.scaled(by: offset) }
        return clawMachines.sum { $0.costToWin() }
    }

    private func parse(_ input: Input) -> [ClawMachine] {
        input.lines.split(whereSeparator: \.isEmpty)
            .lazy
            .map(Array.init)
            .map { lines in
                assert(lines.count == 3)
                let a = Point2D(lines[0].integers)
                let b = Point2D(lines[1].integers)
                let prize = Point2D(lines[2].integers)
                return ClawMachine(buttonA: a, buttonB: b, prize: prize)
            }
    }
}

private struct ClawMachine {
    let buttonA: Point2D
    let buttonB: Point2D
    let prize: Point2D

    func costToWin() -> Int {
        // https://developer.apple.com/documentation/accelerate/working_with_matrices#2960597
        let matrix = Matrix(
            (buttonA.x, buttonB.x),
            (buttonA.y, buttonB.y),
        )
        let vector = Vector(prize.x, prize.y)
        let result = (matrix.inverse * vector).rounded(.toNearestOrEven)
        guard result.x >= 0, result.y >= 0 else {
            return 0
        }

        // check that the solution is an integer solution
        let rxa = Int(result.x) * buttonA.x, rxb = Int(result.y) * buttonB.x
        let rya = Int(result.x) * buttonA.y, ryb = Int(result.y) * buttonB.y
        guard rxa + rxb == (prize.x), rya + ryb == (prize.y) else {
            return 0
        }
        return 3 * Int(result.x) + Int(result.y)
    }

    func scaled(by factor: Int) -> ClawMachine {
        ClawMachine(
            buttonA: buttonA,
            buttonB: buttonB,
            prize: Point2D(prize.x + factor, prize.y + factor),
        )
    }
}

private typealias Matrix = simd_double2x2
private typealias Vector = simd_double2

private extension Matrix {
    init(_ row1: (Int, Int), _ row2: (Int, Int)) {
        self.init(rows: [
            Vector(Double(row1.0), Double(row1.1)),
            Vector(Double(row2.0), Double(row2.1)),
        ])
    }
}

private extension Vector {
    init(_ x: Int, _ y: Int) {
        self.init(Double(x), Double(y))
    }
}

extension ClawContraption: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.example).expects(part1: 480),
        ]
    }
}
