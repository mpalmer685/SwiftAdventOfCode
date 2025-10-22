import ArgumentParser

struct EventOptions: ParsableArguments {
    @Option(name: .long)
    var year: Int
}
