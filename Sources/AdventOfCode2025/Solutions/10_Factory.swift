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
        return await machines.concurrentSum { JoltageSequence().minimumJoltagePresses($0) }
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
    var doubleValue: Double { Double(numerator) / Double(denominator) }
    var intValue: Int { numerator / denominator }

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

    static func * (lhs: Self, rhs: Int) -> Int {
        lhs.numerator * rhs / lhs.denominator
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
                    machine.buttons[col].contains(row) ? .one : .zero
                }
            }
        }

        // Gaussian Elimination to reduced row echelon form
        let (pivotCols, freeVars) = gaussianElimination(
            &matrix,
            numCounters: numCounters,
            numButtons: numButtons,
        )

        // If no free variables, unique solution - sum the pivot values
        if freeVars.isEmpty {
            return pivotCols.indices.sum { row in
                matrix[row][numButtons].intValue
            }
        }

        // Calculate "Net Cost" for each free variable and sort by most negative first
        let sortedFreeVars = freeVars
            .map { colIdx -> (colIndex: Int, netCost: Double) in
                let costSum = 1 - pivotCols.indices.sum { row in
                    matrix[row][colIdx].doubleValue
                }
                return (colIdx, costSum)
            }
            .sorted(using: \.netCost)

        // Convert to integer arithmetic via LCM scaling
        let commonDenom = lcm(
            of: matrix,
            numButtons: numButtons,
            pivotCols: pivotCols,
            freeVariables: freeVars,
        )

        // Pre-compute scaled integer coefficients for search
        let pivotRowsInt = (0 ..< pivotCols.count).map { i in
            let rhsScaled = matrix[i][numButtons] * commonDenom
            let scaledCoefficients = sortedFreeVars.map { fv in
                matrix[i][fv.colIndex] * commonDenom
            }
            return (rhsScaled: rhsScaled, scaledCoefficients: scaledCoefficients)
        }

        return bestTotal(
            pivotRows: pivotRowsInt,
            freeVariables: sortedFreeVars.map(\.netCost),
            target: target.max() ?? 100,
            commonDenominator: commonDenom,
        ) ?? 0
    }

    private func lcm(
        of matrix: [[Rational]],
        numButtons: Int,
        pivotCols: [Int],
        freeVariables: [Int],
    ) -> Int {
        // Convert to integer arithmetic via LCM scaling
        let denominators = pivotCols.indices.flatMap { row in
            [matrix[row][numButtons].denominator] + freeVariables
                .map { matrix[row][$0].denominator }
        }
        return AOCKit.lcm(of: denominators)
    }

    private typealias PivotRow = (rhsScaled: Int, scaledCoefficients: [Int])

    private func bestTotal(
        pivotRows: [PivotRow],
        freeVariables: [Double],
        target: Int,
        commonDenominator: Int,
    ) -> Int? {
        // Grid search with mutable backtracking (performance-critical)
        // let safeMax = target.max() ?? 100
        var bestTotal = Int.max
        var currentPivotTerms = [Int](repeating: 0, count: pivotRows.count)

        func search(_ idx: Int, _ currentFreeSum: Int) {
            guard idx < freeVariables.count else {
                // Evaluate pivot variables - all must be non-negative integers
                let pivotSum = pivotRows.enumerated().reduce(0) { sum, item in
                    guard sum != Int.max else { return Int.max }
                    let numerator = item.element.rhsScaled - currentPivotTerms[item.offset]
                    guard numerator % commonDenominator == 0 else { return Int.max }
                    let xP = numerator / commonDenominator
                    guard xP >= 0 else { return Int.max }
                    return sum + xP
                }

                if pivotSum != Int.max {
                    bestTotal = min(bestTotal, currentFreeSum + pivotSum)
                }
                return
            }

            let netCost = freeVariables[idx]
            let (start, end, step) = netCost < 0
                ? (target, 0, -1)
                : (0, target, 1)

            for val in stride(from: start, through: end, by: step) {
                if netCost > 0, currentFreeSum + val >= bestTotal { break }

                // Forward: accumulate terms
                for i in 0 ..< pivotRows.count {
                    currentPivotTerms[i] += pivotRows[i].scaledCoefficients[idx] * val
                }

                search(idx + 1, currentFreeSum + val)

                // Backtrack: restore terms
                for i in 0 ..< pivotRows.count {
                    currentPivotTerms[i] -= pivotRows[i].scaledCoefficients[idx] * val
                }
            }
        }

        search(0, 0)

        return bestTotal == Int.max ? nil : bestTotal
    }

    private func gaussianElimination(
        _ matrix: inout [[Rational]],
        numCounters: Int,
        numButtons: Int,
    ) -> (pivotCols: [Int], freeVars: [Int]) {
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

        // Identify free variables (columns without pivots)
        let pivotSet = Set(pivotCols)
        let freeVars = (0 ..< numButtons).filter { !pivotSet.contains($0) }

        return (pivotCols, freeVars)
    }
}

extension Factory: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.example).expects(part1: 7, part2: 33),
        ]
    }
}
