import AOCKit
import RegexBuilder

struct Factory: Puzzle {
    static let day = 10

    func part1(input: Input) async throws -> Int {
        let machines = parseMachines(from: input)
        return machines.map(StartupSequence.init).sum(of: \.shortestSequenceLength)
    }

    func part2(input: Input) async throws -> Int {
        let machines = parseMachines(from: input)
        return machines.sum { JoltageSequence().minimumJoltagePresses($0) }
    }

    private func parseMachines(from input: Input) -> [Machine] {
        let lights = Reference<[Bool]>()
        let buttons = Reference<[Set<Int>]>()
        let joltage = Reference<[Int]>()

        let commaSeparatedDigits = /\d+(?:,\d+)*/

        func transformCommaSeparatedDigits(_ raw: Substring) -> [Int] {
            raw.split(separator: ",").compactMap { Int($0) }
        }

        let linePattern = Regex {
            Anchor.startOfSubject
            "["
            Capture(as: lights) {
                OneOrMore(CharacterClass.anyOf("#."))
            } transform: { $0.map { $0 == "#" } }
            "] "
            Capture(as: buttons) {
                OneOrMore {
                    "("
                    commaSeparatedDigits
                    ")"
                    ZeroOrMore(.whitespace)
                }
            } transform: { raw in
                raw.matches(of: commaSeparatedDigits).map { match in
                    Set(transformCommaSeparatedDigits(match.0))
                }
            }
            "{"
            Capture(as: joltage) {
                commaSeparatedDigits
            } transform: { transformCommaSeparatedDigits($0) }
            "}"
            Anchor.endOfSubject
        }

        return input.lines.map { line in
            guard let match = line.raw.wholeMatch(of: linePattern) else {
                fatalError("Invalid input line: \(line.raw)")
            }
            return Machine(
                requiredLights: match[lights],
                requiredJoltage: match[joltage],
                buttons: match[buttons],
            )
        }
    }
}

private struct Machine {
    let requiredLights: [Bool]
    let requiredJoltage: [Int]
    let buttons: [Set<Int>]
}

private struct StartupSequence: Graph {
    let machine: Machine

    private let buttonMasks: [Int]

    let startingState = 0

    var targetState: Int { .init(bits: machine.requiredLights.reversed()) }

    init(machine: Machine) {
        self.machine = machine
        buttonMasks = machine.buttons.map { $0.reduce(0) { $0 | (1 << $1) } }
    }

    func neighbors(of state: Int) -> [Int] {
        buttonMasks.map { state ^ $0 }
    }

    var shortestSequenceLength: Int {
        shortestPath(from: startingState, to: targetState).count
    }
}

private struct Rational {
    static let zero = Rational(wholeNumber: 0)
    static let one = Rational(wholeNumber: 1)

    let numerator: Int
    let denominator: Int

    var isZero: Bool { numerator == 0 }

    init(wholeNumber numerator: Int) {
        self.numerator = numerator
        denominator = 1
    }

    private init(numerator: Int, denominator: Int) {
        self.numerator = numerator
        self.denominator = denominator
    }

    static func + (lhs: Self, rhs: Self) -> Self {
        reduce(
            lhs.numerator * rhs.denominator + rhs.numerator * lhs.denominator,
            lhs.denominator * rhs.denominator,
        )
    }

    static func - (lhs: Self, rhs: Self) -> Self {
        reduce(
            lhs.numerator * rhs.denominator - rhs.numerator * lhs.denominator,
            lhs.denominator * rhs.denominator,
        )
    }

    static func * (lhs: Self, rhs: Self) -> Self {
        reduce(lhs.numerator * rhs.numerator, lhs.denominator * rhs.denominator)
    }

    static func / (lhs: Self, rhs: Self) -> Self {
        reduce(lhs.numerator * rhs.denominator, lhs.denominator * rhs.numerator)
    }

    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }

    static func -= (lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }

    static func *= (lhs: inout Self, rhs: Self) {
        lhs = lhs * rhs
    }

    static func /= (lhs: inout Self, rhs: Self) {
        lhs = lhs / rhs
    }

    private static func reduce(_ numerator: Int, _ denominator: Int) -> Self {
        guard numerator != 0 else { return Self(numerator: 0, denominator: 1) }
        let g = gcd(numerator, denominator)
        let (num, den) = (numerator / g, denominator / g)
        return den < 0
            ? Self(numerator: -num, denominator: -den)
            : Self(numerator: num, denominator: den)
    }

    private static func gcd(_ a: Int, _ b: Int) -> Int {
        var x = a
        var y = b
        if x.magnitude < y.magnitude { swap(&x, &y) }
        // Avoid overflow when x = signed min, y = -1.
        if y.magnitude == 1 { return 1 }
        // Euclidean algorithm for GCD. It's worth using Lehmer instead for larger
        // integer types, but for now this is good and dead-simple and faster than
        // the other obvious choice, the binary algorithm.
        while y != 0 {
            (x, y) = (y, x % y)
        }
        // Try to convert result to T.
        if let result = Int(exactly: x.magnitude) { return result }
        // If that fails, produce a diagnostic.
        fatalError("GCD (\(x)) is not representable as \(Int.self).")
    }
}

private struct JoltageSequence {
    private func gaussianElimination(
        _ matrix: inout [[Rational]],
        numCounters: Int,
        numButtons: Int,
    ) -> [Int] {
        var pivotRow = 0
        var pivotCol = 0
        var pivotCols: [Int] = []

        while pivotRow < numCounters, pivotCol < numButtons {
            guard let foundPivot = (pivotRow ..< numCounters)
                .first(where: { !matrix[$0][pivotCol].isZero })
            else {
                pivotCol += 1
                continue
            }

            if foundPivot != pivotRow {
                matrix.swapAt(pivotRow, foundPivot)
            }

            pivotCols.append(pivotCol)
            let scale = matrix[pivotRow][pivotCol]

            // Normalize pivot row
            for col in pivotCol ... numButtons {
                matrix[pivotRow][col] /= scale
            }

            // Eliminate column in other rows
            (0 ..< numCounters).filter { $0 != pivotRow }.forEach { row in
                let factor = matrix[row][pivotCol]
                guard !factor.isZero else { return }
                for col in pivotCol ... numButtons {
                    matrix[row][col] -= factor * matrix[pivotRow][col]
                }
            }
            pivotRow += 1
            pivotCol += 1
        }

        return pivotCols
    }

    /// Optimized: Rational Gaussian Elimination -> Integer Grid Search
    func minimumJoltagePresses(_ machine: Machine) -> Int {
        let target = machine.requiredJoltage
        let numCounters = target.count
        let numButtons = machine.buttons.count

        // Build augmented matrix [A | b] with rational arithmetic
        var matrix: [[Rational]] = (0 ..< numCounters).map { row in
            (0 ... numButtons).map { col in
                if col == numButtons {
                    Rational(wholeNumber: target[row])
                } else {
                    machine.buttons[col].contains(row)
                        ? .one
                        : .zero
                }
            }
        }

        // Gaussian Elimination to reduced row echelon form
        let pivotCols = gaussianElimination(
            &matrix,
            numCounters: numCounters,
            numButtons: numButtons,
        )

        // Identify free variables (columns without pivots)
        let pivotSet = Set(pivotCols)
        let freeVars = (0 ..< numButtons).filter { !pivotSet.contains($0) }

        // If no free variables, unique solution - sum the pivot values
        if freeVars.isEmpty {
            return (0 ..< pivotCols.count).reduce(0) { total, row in
                let val = matrix[row][numButtons]
                guard val.denominator != 0,
                      val.numerator % val.denominator == 0 else { return Int.max }
                let intVal = val.numerator / val.denominator
                guard intVal >= 0, total != Int.max else { return Int.max }
                return total + intVal
            }.clamped(to: Int.max, fallback: 0)
        }

        // Calculate "Net Cost" for each free variable and sort by most negative first
        let sortedFreeVars = freeVars
            .map { colIdx -> (colIndex: Int, netCost: Double) in
                let costSum = (0 ..< pivotCols.count).reduce(1.0) { sum, row in
                    sum - Double(matrix[row][colIdx].numerator) /
                        Double(matrix[row][colIdx].denominator)
                }
                return (colIdx, costSum)
            }
            .sorted { $0.netCost < $1.netCost }

        // Convert to integer arithmetic via LCM scaling
        let commonDenom = (0 ..< pivotCols.count).reduce(1) { denom, i in
            let rhsDenom = lcm(denom, matrix[i][numButtons].denominator)
            return freeVars.reduce(rhsDenom) { lcm($0, matrix[i][$1].denominator) }
        }

        // Pre-compute scaled integer coefficients for search
        let pivotRowsInt = (0 ..< pivotCols.count).map { i in
            let rhsScaled = (matrix[i][numButtons].numerator * commonDenom) / matrix[i][numButtons]
                .denominator
            let scaledCoefficients = sortedFreeVars.map { fv in
                (matrix[i][fv.colIndex].numerator * commonDenom) / matrix[i][fv.colIndex]
                    .denominator
            }
            return (rhsScaled: rhsScaled, scaledCoefficients: scaledCoefficients)
        }

        // Grid search with mutable backtracking (performance-critical)
        let safeMax = target.max() ?? 100
        var bestTotal = Int.max
        var currentPivotTerms = [Int](repeating: 0, count: pivotRowsInt.count)

        func search(_ idx: Int, _ currentFreeSum: Int) {
            if idx == sortedFreeVars.count {
                // Evaluate pivot variables - all must be non-negative integers
                let pivotSum = pivotRowsInt.enumerated().reduce(0) { sum, item in
                    guard sum != Int.max else { return Int.max }
                    let numerator = item.element.rhsScaled - currentPivotTerms[item.offset]
                    guard numerator % commonDenom == 0 else { return Int.max }
                    let xP = numerator / commonDenom
                    guard xP >= 0 else { return Int.max }
                    return sum + xP
                }

                if pivotSum != Int.max {
                    bestTotal = min(bestTotal, currentFreeSum + pivotSum)
                }
                return
            }

            let info = sortedFreeVars[idx]
            let (start, end, step) = info.netCost < 0
                ? (safeMax, 0, -1)
                : (0, safeMax, 1)

            var val = start
            while step > 0 ? val <= end : val >= end {
                if info.netCost > 0, currentFreeSum + val >= bestTotal { break }

                // Forward: accumulate terms
                for i in 0 ..< pivotRowsInt.count {
                    currentPivotTerms[i] += pivotRowsInt[i].scaledCoefficients[idx] * val
                }

                search(idx + 1, currentFreeSum + val)

                // Backtrack: restore terms
                for i in 0 ..< pivotRowsInt.count {
                    currentPivotTerms[i] -= pivotRowsInt[i].scaledCoefficients[idx] * val
                }

                val += step
            }
        }

        search(0, 0)

        return bestTotal == Int.max ? 0 : bestTotal
    }
}

private extension Int {
    func clamped(to maxValue: Int, fallback: Int) -> Int {
        self == maxValue ? fallback : self
    }
}

extension Factory: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.example).expects(part1: 7, part2: 33),
        ]
    }
}
