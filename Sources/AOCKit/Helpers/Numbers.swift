public extension FixedWidthInteger {
    var digits: [Self] {
        var digits = [Self]()
        var remainder = self
        if remainder < 0 { remainder *= -1 }

        while remainder > 0 {
            let m = remainder % 10
            digits.append(m)
            remainder /= 10
        }

        return digits.reversed()
    }
}

public extension Int {
    static func from(digit: Character) -> Self? {
        Self(String(digit))
    }

    static func from(bits: String) -> Self? {
        Self(bits, radix: 2)
    }

    init(bits: some Collection<Bool>) {
        self = bits.reduce(0) { $0 * 2 + ($1 ? 1 : 0) }
    }

    init(digits: some Collection<Int>) {
        var i = 0
        for (power, digit) in digits.reversed().enumerated() {
            i += abs(digit) * Int(pow(10, Double(power)))
        }
        self = i
    }

    var triangle: Self {
        (self * (self + 1)) / 2
    }
}

public func lcm<I: FixedWidthInteger>(_ values: I...) -> I {
    lcm(of: values)
}

public func lcm<C: Collection>(of values: C) -> C.Element where C.Element: FixedWidthInteger {
    let v = values.first!
    let r = values.dropFirst()
    guard r.isNotEmpty else { return v }

    let lcmR = lcm(of: r)
    return v / gcd(v, lcmR) * lcmR
}

public func gcd<I: FixedWidthInteger>(_ m: I, _ n: I) -> I {
    var a: I = 0
    var b: I = max(m, n)
    var r: I = min(m, n)

    while r != 0 {
        a = b
        b = r
        r = a % b
    }
    return b
}

public extension FixedWidthInteger {
    var isEven: Bool { self % 2 == 0 }
    var isOdd: Bool { self % 2 == 1 }
}

public extension BinaryFloatingPoint {
    var isWholeNumber: Bool {
        Int(exactly: self) != nil
    }
}
