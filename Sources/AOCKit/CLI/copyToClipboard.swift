import AppKit

func copyToClipboard(_ value: String) {
    let pasteboard = NSPasteboard.general
    pasteboard.declareTypes([.string], owner: nil)
    pasteboard.setString(value, forType: .string)
}
