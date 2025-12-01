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
    var inMilliseconds: Double {
        Double(components.seconds) * 1000 + Double(components.attoseconds) * 1e-15
    }
}

extension Duration {
    typealias SavedBenchmark = (mean: Duration, standardDeviation: Double?)

    enum ComparisonResult: CustomStringConvertible {
        case muchFaster
        case faster(Double)
        case same
        case slower(Double)
        case muchSlower

        var description: String {
            switch self {
                case .same:
                    "no change".blue
                case let .faster(percent):
                    "\(format(percent))% faster".green
                case let .slower(percent):
                    "\(format(percent))% slower".red
                case .muchFaster:
                    "significantly faster".green.bold
                case .muchSlower:
                    "significantly slower".red.bold
            }
        }

        private func format(_ percent: Double) -> String {
            String(format: "%0.1f", percent * 100)
        }
    }

    func compared(to savedBenchmarks: SavedBenchmark) -> ComparisonResult {
        let (meanDuration, standardDeviation) = savedBenchmarks

        if let standardDeviation {
            let percentDifference = abs(inMilliseconds - meanDuration.inMilliseconds) / meanDuration
                .inMilliseconds
            let zScore = (inMilliseconds - meanDuration.inMilliseconds) / standardDeviation

            switch zScore {
                case ...(-3):
                    return .muchFaster
                case -3 ..< -2:
                    return .faster(percentDifference)
                case -2 ... 2:
                    return .same
                case 2 ..< 3:
                    return .slower(percentDifference)
                default:
                    return .muchSlower
            }
        }

        let percentDifference = abs((self - meanDuration) / self)
        if percentDifference < 0.05 {
            return .same
        } else if self < meanDuration {
            return .faster(percentDifference)
        } else {
            return .slower(percentDifference)
        }
    }
}
