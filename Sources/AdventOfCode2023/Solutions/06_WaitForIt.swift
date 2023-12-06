import AOCKit

struct WaitForIt: Puzzle {
    static let day = 6

    // static let rawInput: String? = """
    // Time:      7  15   30
    // Distance:  9  40  200
    // """

    func part1(input: Input) throws -> Int {
        let lines = input.lines
        let races = zip(lines[0].integers, lines[1].integers)
        return races.product { race in
            let (time, distance) = race
            let (min, max) = buttonPressInterval(time: time, distance: distance)
            return max - min + 1
        }
    }

    func part2(input: Input) throws -> Int {
        let lines = input.lines,
            timeDigits = lines[0].characters.integers,
            time = Int(digits: timeDigits),
            distanceDigits = lines[1].characters.integers,
            distance = Int(digits: distanceDigits)

        let (min, max) = buttonPressInterval(time: time, distance: distance)
        return max - min + 1
    }

    /*
     * let B = duration of button press,
     *     T = time available for race,
     *     D = current distance record
     *
     * using v = x / t -> x = vt, we can substitute
     * x = D, v = B, t = T - B:
     *
     *     D = B(T - B) or -B^2 + TB - D = 0
     *
     * using the quadratic equation, we get
     *
     *     B = (T +- sqrt(T^2 - 4D)) / 2
     *
     * to get whole-number milliseconds, this becomes
     *
     *     ceil( (T - sqrt(T^2 - 4D) / 2) ), floor( (T + sqrt(T^2 - 4D) / 2) )
     */
    private func buttonPressInterval(time t: Int, distance d: Int) -> (min: Int, max: Int) {
        let time = Double(t), distance = Double(d)

        var min = (time - sqrt(pow(time, 2) - 4 * distance)) / 2
        if min.isEqual(to: ceil(min)) {
            min += 1
        }

        var max = (time + sqrt(pow(time, 2) - 4 * distance)) / 2
        if max.isEqual(to: floor(max)) {
            max -= 1
        }

        return (Int(ceil(min)), Int(floor(max)))
    }
}
