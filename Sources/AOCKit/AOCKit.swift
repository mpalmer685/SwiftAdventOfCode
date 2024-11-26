@_exported import Algorithms
@_exported import Foundation

public extension AdventOfCode {
    func run() async {
        do {
            var command = try AOCCommand.parseAsRoot()

            if let command = command as? RunCommand {
                try await command.run(event: self)
            } else {
                try command.run()
            }
        } catch {
            AOCCommand.exit(withError: error)
        }
    }
}
