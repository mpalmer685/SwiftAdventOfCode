import Foundation

public struct RegexMatch {
    private var target: String
    private var match: NSTextCheckingResult

    init?(string: String, result: NSTextCheckingResult?) {
        guard let result = result else { return nil }
        target = string
        match = result
    }

    public subscript(idx: Int) -> String {
        guard let range = range(from: match.range(at: idx)) else {
            return ""
        }
        return String(target[range])
    }

    @available(macOS 10.13, *)
    public subscript(name: String) -> String {
        guard let range = range(from: match.range(withName: name)) else {
            return ""
        }
        return String(target[range])
    }

    private func range(from range: NSRange) -> Range<String.Index>? {
        Range(range, in: target)
    }
}

public extension NSRegularExpression {
    convenience init(_ pattern: String, options: Options = []) {
        do {
            try self.init(pattern: pattern, options: options)
        } catch {
            preconditionFailure("Invalid regular expression: \(pattern)")
        }
    }

    func match(_ string: String) -> RegexMatch? {
        let range = NSRange(location: 0, length: string.utf16.count)
        let match = firstMatch(in: string, options: [], range: range)
        return RegexMatch(string: string, result: match)
    }

    func matches(_ string: String) -> Bool {
        match(string) != nil
    }
}

public func ~= (regex: NSRegularExpression, source: String) -> Bool {
    regex.matches(source)
}
