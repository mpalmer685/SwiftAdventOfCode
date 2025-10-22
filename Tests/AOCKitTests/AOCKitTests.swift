@testable import AOCKit
import Testing

@Test func event() {
    let event = AdventOfCodeEvent(year: 2024, puzzles: [])
    #expect(event.year == 2024)
    #expect(event.puzzles.isEmpty)
}
