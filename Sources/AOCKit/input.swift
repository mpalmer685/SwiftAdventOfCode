import Files

enum InputType {
    case file(path: String)
    case string(value: String)
}

func getInput(for type: InputType) throws -> String {
    switch (type) {
        case .string(let value):
            return value
        case .file(let path):
            return try File(path: path).readAsString()
    }
}
