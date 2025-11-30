import ArgumentParser

struct EventOptions: ParsableArguments {
    @Option(name: .long, transform: EventYear.init)
    var year: EventYear
}

enum EventYear {
    case all
    case specific(Int)

    init(_ input: String) throws {
        if input.lowercased() == "all" {
            self = .all
        } else if let year = Int(input) {
            self = .specific(year)
        } else {
            throw ValidationError(
                "Invalid year input: \(input). Use 'all' or a specific year (e.g., 2023).",
            )
        }
    }
}
