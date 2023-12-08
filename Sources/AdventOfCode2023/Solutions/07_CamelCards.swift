import AOCKit

struct CamelCards: Puzzle {
    static let day = 7

    // static let rawInput: String? = """
    // 32T3K 765
    // T55J5 684
    // KK677 28
    // KTJJT 220
    // QQQJA 483
    // """

    func part1(input: Input) throws -> Int {
        score(for: input, using: JacksHand.init)
    }

    func part2(input: Input) throws -> Int {
        score(for: input, using: JokersHand.init)
    }

    private func score<T: Hand>(for input: Input, using buildHand: (Line) -> T) -> Int {
        input.lines
            .map(buildHand)
            .sorted()
            .enumerated()
            .sum(of: { index, hand in
                hand.bid * (index + 1)
            })
    }
}

private protocol Hand: Comparable {
    associatedtype Card: CamelCard

    var cards: [Card] { get }
    var bid: Int { get }
    var outcome: Outcome { get }

    init(cards: [Card], bid: Int, outcome: Outcome)

    static func calculateOutcome(for: [Card]) -> Outcome
}

private protocol CamelCard: CaseIterable, Comparable, Hashable {
    init?(rawValue: Character)

    var rawValue: Character { get }
    var strength: Int { get }
}

private enum Outcome: Int {
    case highCard = 1,
         onePair = 2,
         twoPair = 3,
         threeOfAKind = 4,
         fullHouse = 5,
         fourOfAKind = 6,
         fiveOfAKind = 7

    var value: Int { rawValue }
}

private extension Hand {
    init(_ line: Line) {
        let words = line.words
        guard words.count == 2 else {
            fatalError("Can't parse line \"\(line.raw)\"")
        }

        let cards = words[0].characters.compactMap(Card.init)
        guard cards.count == 5 else {
            fatalError("Error parsing cards in \(words[0].raw)")
        }

        guard let bid = words[1].integer else {
            fatalError("Error parsing bid from \(words[1].raw)")
        }

        self.init(cards: cards, bid: bid, outcome: Self.calculateOutcome(for: cards))
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.outcome != rhs.outcome {
            return lhs.outcome < rhs.outcome
        }
        for i in 0 ..< 5 where lhs.cards[i] != rhs.cards[i] {
            return lhs.cards[i] < rhs.cards[i]
        }
        return false
    }
}

private extension CamelCard {
    var strength: Int {
        let allCases = Self.allCases

        guard let index = allCases.firstIndex(of: self) else {
            fatalError()
        }

        return allCases.distance(from: allCases.startIndex, to: index) + 1
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.strength < rhs.strength
    }
}

extension Outcome: Comparable {
    fileprivate static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.value < rhs.value
    }
}

private struct JacksHand: Hand {
    let cards: [JacksHand.Card]
    let bid: Int
    let outcome: Outcome

    static func calculateOutcome<T: CamelCard>(for cards: [T]) -> Outcome {
        let counts: [T: Int] = cards.reduce(into: [:]) { counts, card in
            let count = counts[card] ?? 0
            counts[card] = count + 1
        }

        if counts.values.contains(5) {
            return .fiveOfAKind
        }
        if counts.values.contains(4) {
            return .fourOfAKind
        }
        if counts.values.contains(3) {
            return counts.values.contains(2) ? .fullHouse : .threeOfAKind
        }
        if counts.values.count(of: 2) == 2 {
            return .twoPair
        }
        if counts.values.contains(2) {
            return .onePair
        }
        return .highCard
    }

    enum Card: Character, CamelCard {
        case two = "2"
        case three = "3"
        case four = "4"
        case five = "5"
        case six = "6"
        case seven = "7"
        case eight = "8"
        case nine = "9"
        case ten = "T"
        case jack = "J"
        case queen = "Q"
        case king = "K"
        case ace = "A"
    }
}

private struct JokersHand: Hand {
    let cards: [JokersHand.Card]
    let bid: Int
    let outcome: Outcome

    static func calculateOutcome(for cards: [Card]) -> Outcome {
        guard cards.contains(.joker) else {
            return JacksHand.calculateOutcome(for: cards)
        }

        var c = cards
        let index = c.partition(by: { $0 == .joker })
        let notJokers = Array(c[0 ..< index])
        let jokers = Array(c[index...])

        let counts: [Card: Int] = notJokers.reduce(into: [:]) { counts, card in
            let count = counts[card] ?? 0
            counts[card] = count + 1
        }

        let maxCount = counts.max(of: \.value) ?? 0

        if maxCount + jokers.count == 5 {
            return .fiveOfAKind
        }
        if maxCount + jokers.count == 4 {
            return .fourOfAKind
        }
        if counts.values.count(of: 2) == 2, jokers.count == 1 {
            return .fullHouse
        }
        if maxCount + jokers.count == 3 {
            return .threeOfAKind
        }
        // No need to check for two pair. With at least one wildcard,
        // two pair will always become full house or better.
        if maxCount + jokers.count == 2 {
            return .onePair
        }
        return .highCard
    }

    enum Card: Character, CamelCard {
        case joker = "J"
        case two = "2"
        case three = "3"
        case four = "4"
        case five = "5"
        case six = "6"
        case seven = "7"
        case eight = "8"
        case nine = "9"
        case ten = "T"
        case queen = "Q"
        case king = "K"
        case ace = "A"
    }
}
