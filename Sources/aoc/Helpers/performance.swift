private let secondsFormatter = Duration.UnitsFormatStyle(
    allowedUnits: [.seconds],
    width: .narrow,
    fractionalPart: .show(length: 3),
)
private let millisecondsFormatter = Duration.UnitsFormatStyle(
    allowedUnits: [.milliseconds],
    width: .narrow,
    fractionalPart: .show(length: 3),
)
private let secondsOnlyFormatter = Duration.UnitsFormatStyle(
    allowedUnits: [.minutes, .seconds],
    width: .narrow,
    zeroValueUnits: .hide,
    fractionalPart: .hide(rounded: .down),
)

extension Duration {
    func formattedForDisplay() -> String {
        let formatter = components.seconds > 0 ? secondsFormatter : millisecondsFormatter
        return formatted(formatter)
    }

    func formattedForComparison() -> String {
        let seconds = components.seconds
        guard seconds > 0 else {
            return formatted(millisecondsFormatter)
        }

        let formattedSeconds = formatted(secondsOnlyFormatter)
        let formattedMilliseconds = (self - .seconds(seconds)).formatted(millisecondsFormatter)
        let paddingLength = " 000.000ms".count - formattedMilliseconds.count
        let padding = String(repeating: " ", count: paddingLength)

        return formattedSeconds + padding + formattedMilliseconds
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
                case .faster, .muchFaster: true
                default: false
            }
        }

        var description: String {
            switch self {
                case let .faster(percent):
                    "\(format(percent))% faster".green
                case let .slower(percent):
                    "\(format(percent))% slower".red
                case .muchFaster:
                    "significantly faster".green.bold
                case .muchSlower:
                    "significantly slower".red.bold
                case .same:
                    "no change".blue
            }
        }

        private func format(_ percent: Double) -> String {
            String(format: "%0.1f", percent * 100)
        }
    }

    func compared(to other: Duration) -> ComparisonResult {
        if components.seconds > 0, other.components.seconds == 0 {
            return .muchSlower
        }
        if components.seconds == 0, other.components.seconds > 0 {
            return .muchFaster
        }

        let percentDifference = abs((self - other) / self)
        if percentDifference < 0.05 {
            return .same
        } else if self < other {
            return .faster(percentDifference)
        } else {
            return .slower(percentDifference)
        }
    }
}
