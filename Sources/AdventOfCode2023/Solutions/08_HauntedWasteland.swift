import AOCKit

struct HauntedWasteland: Puzzle {
    static let day = 8

    // static let rawInput: String? = """
    // RL

    // AAA = (BBB, CCC)
    // BBB = (DDD, EEE)
    // CCC = (ZZZ, GGG)
    // DDD = (DDD, DDD)
    // EEE = (EEE, EEE)
    // GGG = (GGG, GGG)
    // ZZZ = (ZZZ, ZZZ)
    // """

    // static let rawInput: String? = """
    // LLR

    // AAA = (BBB, BBB)
    // BBB = (AAA, ZZZ)
    // ZZZ = (ZZZ, ZZZ)
    // """

    // static let rawInput: String? = """
    // LR

    // AAA = (AAB, XXX)
    // AAB = (XXX, AAZ)
    // AAZ = (AAB, XXX)
    // BBA = (BBB, XXX)
    // BBB = (BBC, BBC)
    // BBC = (BBZ, BBZ)
    // BBZ = (BBB, BBB)
    // XXX = (XXX, XXX)
    // """

    func part1(input: Input) throws -> Int {
        let (instructions, nodes) = parse(input)
        return follow(instructions, for: nodes, startingAt: "AAA", until: { $0.id == "ZZZ" })
    }

    func part2(input: Input) throws -> Int {
        let (instructions, nodes) = parse(input)
        let startingNodes = nodes.keys.filter { $0.ends(with: "A") }

        let cycleCounts = startingNodes.map { nodeId in
            let turns = follow(
                instructions,
                for: nodes,
                startingAt: nodeId,
                until: { $0.id.ends(with: "Z") },
            )
            return turns
        }

        return lcm(of: cycleCounts)
    }

    private func follow(
        _ instructions: [Turn],
        for nodes: [String: Node],
        startingAt startingNodeId: String,
        until isFinished: (Node) -> Bool,
    ) -> Int {
        var turns = instructions.cycled().makeIterator()
        var currentNodeId = startingNodeId
        var turnCount = 0

        while let current = nodes[currentNodeId], turnCount == 0 || !isFinished(current),
              let turn = turns.next()
        {
            currentNodeId = current[turn]
            turnCount += 1
        }

        return turnCount
    }

    private func parse(_ input: Input) -> (instructions: [Turn], nodes: [String: Node]) {
        let lines = input.lines
        let instructions = lines[0].characters.compactMap(Turn.init)
        let nodes: [String: Node] = lines[2...].map(Node.init).reduce(into: [:]) { nodes, node in
            nodes[node.id] = node
        }

        return (instructions, nodes)
    }
}

private enum Turn: Character {
    case left = "L"
    case right = "R"
}

private struct Node {
    let id: String

    let left: String
    let right: String

    init(_ line: Line) {
        var scanner = Scanner(line.raw)
        scanner.skip(while: { !$0.isLetter })
        id = String(scanner.scan(while: \.isLetter))
        scanner.skip(while: { !$0.isLetter })
        left = String(scanner.scan(while: \.isLetter))
        scanner.expect(", ")
        right = String(scanner.scan(while: \.isLetter))
    }

    subscript(turn: Turn) -> String {
        switch turn {
            case .left: left
            case .right: right
        }
    }
}

private extension String {
    func ends(with character: Character) -> Bool {
        last == character
    }
}
