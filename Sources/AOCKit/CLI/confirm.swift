import Rainbow

func confirm(_ text: String, default defaultAnswer: Bool = true) -> Bool {
    let options = defaultAnswer ? "[Y/n]" : "[y/N]"
    while true {
        print(text, options.lightBlack, terminator: " ")
        if let input = readLine() {
            if input.count == 0 {
                return defaultAnswer
            } else if isAffirmative(response: input) {
                return true
            } else if isNegative(response: input) {
                return false
            }
        }
    }
}

private func isAffirmative(response: String) -> Bool {
    response.lowercased() == "y" || response.lowercased() == "yes"
}

private func isNegative(response: String) -> Bool {
    response.lowercased() == "n" || response.lowercased() == "no"
}
