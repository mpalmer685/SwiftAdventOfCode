public extension AdventOfCode {
    func run() {
        do {
            var command = try AOCCommand.parseAsRoot()

            if let command = command as? RunCommand {
                try command.run(event: self)
            } else {
                try command.run()
            }
        } catch {
            AOCCommand.exit(withError: error)
        }
    }
}
