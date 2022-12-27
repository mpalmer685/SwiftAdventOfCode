import Foundation

extension AdventOfCode {
    func measure<T>(_ work: () throws -> T) rethrows -> (T, Duration) {
        if #available(macOS 13.0, *) {
            return try measureWithClock(work)
        } else {
            return try measureWithDispatch(work)
        }
    }

    @available(macOS 13.0, *)
    private func measureWithClock<T>(_ work: () throws -> T) rethrows -> (T, Duration) {
        let clock = ContinuousClock()
        var result: T?
        let duration = try clock.measure {
            result = try work()
        }
        return (result!, Duration(duration))
    }

    private func measureWithDispatch<T>(_ work: () throws -> T) rethrows -> (T, Duration) {
        guard #available(macOS 10.15, *) else {
            fatalError("Platform not supported")
        }

        let start = DispatchTime.now()
        let result = try work()
        let end = DispatchTime.now()
        let duration = start.distance(to: end)
        return (result, Duration(duration))
    }
}

struct Duration: Codable {
    let seconds: Int64
    let nanoseconds: Int64

    init(_ duration: DispatchTimeInterval) {
        switch duration {
            case let .seconds(seconds):
                self.seconds = Int64(seconds)
                nanoseconds = 0
            case let .milliseconds(milliseconds):
                seconds = Int64(milliseconds / 1000)
                nanoseconds = Int64(milliseconds % 1000) * 1_000_000
            case let .microseconds(microseconds):
                seconds = Int64(microseconds / 1_000_000)
                nanoseconds = Int64(microseconds % 1_000_000) * 1000
            case let .nanoseconds(nanoseconds):
                seconds = Int64(nanoseconds / 1_000_000_000)
                self.nanoseconds = Int64(nanoseconds % 1_000_000_000)
            case .never:
                seconds = 0
                nanoseconds = 0
            default:
                fatalError()
        }
    }

    init(_ duration: TimeInterval) {
        let seconds = Int64(duration)
        let nanoseconds = Int64((duration - Double(seconds)) * 1_000_000_000)
        self.seconds = seconds
        self.nanoseconds = nanoseconds
    }

    @available(macOS 13.0, *)
    init(_ duration: Swift.Duration) {
        seconds = duration.components.seconds
        nanoseconds = duration.components.attoseconds / 1_000_000_000
    }
}

extension Duration: CustomStringConvertible {
    var description: String {
        if seconds > 0 || (nanoseconds / 1_000_000) > 10 {
            let seconds = Double(seconds) + Double(nanoseconds) / 1_000_000_000
            return String(format: "%0.3f", seconds) + "s"
        } else if (nanoseconds / 1000) > 10 {
            let milliseconds = Double(nanoseconds) / 1_000_000
            return String(format: "%0.3f", milliseconds) + "ms"
        } else {
            return "\(nanoseconds)ns"
        }
    }
}

extension Duration {
    enum ComparisonResult: CustomStringConvertible {
        case faster(Double)
        case muchFaster
        case slower(Double)
        case muchSlower
        case same

        var isImprovement: Bool {
            switch self {
                case .faster, .muchFaster: return true
                default: return false
            }
        }

        var description: String {
            switch self {
                case let .faster(percent):
                    return "\(format(percent))% faster".green
                case let .slower(percent):
                    return "\(format(percent))% slower".red
                case .muchFaster:
                    return "significantly faster".green.bold
                case .muchSlower:
                    return "significantly slower".red.bold
                case .same:
                    return "no change".blue
            }
        }

        private func format(_ percent: Double) -> String {
            String(format: "%0.1f", percent * 100)
        }
    }

    func compared(to other: Duration) -> ComparisonResult {
        let selfDuration: Float64, otherDuration: Double

        if seconds > 0 {
            guard other.seconds > 0 else { return .muchSlower }
            selfDuration = Double(seconds) + Double(nanoseconds) / 1_000_000_000
            otherDuration = Double(other.seconds) + Double(other.nanoseconds) / 1_000_000_000
        } else {
            guard other.seconds == 0 else { return .muchFaster }
            selfDuration = Double(nanoseconds)
            otherDuration = Double(other.nanoseconds)
        }

        let difference = abs(selfDuration - otherDuration)
        let percentDifference = difference / selfDuration
        if percentDifference < 0.05 {
            return .same
        } else if selfDuration < otherDuration {
            return .faster(percentDifference)
        } else {
            return .slower(percentDifference)
        }
    }
}
