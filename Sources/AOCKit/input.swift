import Files

enum InputType {
    case file(path: String)
    case string(value: String)
}

func getInput(for type: InputType) throws -> String {
    switch type {
        case let .string(value):
            return value
        case let .file(path):
            return try File(path: path).readAsString()
    }
}
