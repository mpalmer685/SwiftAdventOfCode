import AOCKit

struct PulsePropagation: Puzzle {
    static let day = 20

    // static let rawInput: String? = """
    // broadcaster -> a, b, c
    // %a -> b
    // %b -> c
    // %c -> inv
    // &inv -> a
    // """

    // static let rawInput: String? = """
    // broadcaster -> a
    // %a -> inv, con
    // &inv -> b
    // %b -> con
    // &con -> output
    // """

    func part1(input: Input) throws -> Int {
        let configuration = parse(input)
        return (0 ..< 1000).reduce(into: [Pulse: Int]()) { counts, _ in
            counts.merge(sendPulse(to: configuration), uniquingKeysWith: +)
        }.product(of: \.value)
    }

    func part2(input: Input) throws -> Int {
        let configuration = parse(input)

        /*
         * Some assumptions we're making:
         * - there is a single module sending pulses to rx
         * - that module is a conjunction module
         * - each input to the conjunction module represents the end of a
         *   chain that starts at one of the outputs from the broadcaster
         * - each chain creates a cycle whose length is the number of
         *   presses needed for the final module to send a high pulse to
         *   the conjunction module
         *
         * Based on those assumptions, we can determine the number of button
         * presses required to get each input to send a high pulse to the
         * conjunction module, and find the LCM of those cycle counts to
         * find the number of presses needed for all of them to send a high
         * pulse in the same cycle.
         */
        guard let (_, (module, _)) = configuration
            .first(where: { $0.value.1.contains("rx") })
        else {
            fatalError()
        }
        guard let module = module as? ConjunctionModule else {
            fatalError()
        }
        var cycleCounts = module.inputs.reduce(into: [String: Int]()) { $0[$1] = 0 }
        var cycle = 1
        // don't stop pressing the button until we've detected cycles for all
        // of the conjunction's inputs
        while cycleCounts.values.contains(0) {
            sendPulse(to: configuration) { pulse, _, sourceId in
                if let sourceId, cycleCounts[sourceId] == 0, pulse == .high {
                    cycleCounts[sourceId] = cycle
                }
            }
            cycle += 1
        }

        return lcm(of: cycleCounts.values)
    }

    @discardableResult
    private func sendPulse(
        to configuration: [String: (Module, [String])],
        onPulse: ((Pulse, String, String?) -> Void)? = nil
    ) -> [Pulse: Int] {
        var queue: Queue<(Pulse, String, String?)> = [(.low, "broadcaster", nil)]
        var counts: [Pulse: Int] = [:]

        while let (pulse, moduleId, sourceId) = queue.pop() {
            counts[pulse, default: 0] += 1
            onPulse?(pulse, moduleId, sourceId)
            guard let (module, destinations) = configuration[moduleId] else {
                continue
            }
            guard let nextPulse = module.handle(pulse, from: sourceId) else {
                continue
            }

            queue.push(contentsOf: destinations.map { (nextPulse, $0, moduleId) })
        }

        return counts
    }

    private func parse(_ input: Input) -> [String: (Module, [String])] {
        enum ModuleType {
            case flipFlop, conjunction, broadcast
        }

        func parse(_ line: Line) -> (ModuleType, String, [String]) {
            let parts = line.words(separatedBy: " -> ")

            let source = parts[0].raw
            let type: ModuleType
            let id: String
            if source == "broadcaster" {
                type = .broadcast
                id = source
            } else if source.hasPrefix("%") {
                type = .flipFlop
                id = String(source.suffix(from: source.index(after: source.startIndex)))
            } else if source.hasPrefix("&") {
                type = .conjunction
                id = String(source.suffix(from: source.index(after: source.startIndex)))
            } else {
                fatalError()
            }

            let destinationIds = parts[1].words(separatedBy: ", ").map(\.raw)

            return (type, id, destinationIds)
        }

        var moduleTypes: [String: ModuleType] = [:]
        var destinations: [String: [String]] = [:]
        var sources: [String: [String]] = [:]

        for line in input.lines {
            let (type, id, destinationIds) = parse(line)
            moduleTypes[id] = type
            destinations[id] = destinationIds
            for dest in destinationIds {
                var sourceIds = sources[dest] ?? []
                sourceIds.append(id)
                sources[dest] = sourceIds
            }
        }

        return moduleTypes.reduce(into: [:]) { config, pair in
            let (moduleId, moduleType) = pair
            let module: Module = switch moduleType {
                case .broadcast: BroadcastModule()
                case .flipFlop: FlipFlopModule()
                case .conjunction: ConjunctionModule(inputs: sources[moduleId]!)
            }

            config[moduleId] = (module, destinations[moduleId]!)
        }
    }
}

private enum Pulse {
    case high, low
}

private protocol Module {
    func handle(_: Pulse, from: String?) -> Pulse?
}

private class FlipFlopModule: Module {
    private var on = false

    func handle(_ pulse: Pulse, from _: String?) -> Pulse? {
        guard pulse == .low else { return nil }

        on.toggle()
        return on ? Pulse.high : .low
    }
}

private class ConjunctionModule: Module {
    private var received: [String: Pulse]

    var inputs: [String] { Array(received.keys) }

    init(inputs: [String]) {
        received = inputs.reduce(into: [:]) { received, input in
            received[input] = .low
        }
    }

    func handle(_ pulse: Pulse, from input: String?) -> Pulse? {
        guard let input else {
            fatalError("No source ID provided")
        }
        guard received[input] != nil else {
            fatalError("Got a pulse from an unknown module")
        }

        received[input] = pulse
        return received.values.all(equal: .high) ? .low : .high
    }
}

private struct BroadcastModule: Module {
    func handle(_ pulse: Pulse, from _: String?) -> Pulse? {
        pulse
    }
}

private extension Collection where Element: Equatable {
    func all(equal element: Element) -> Bool {
        allSatisfy { $0 == element }
    }
}
