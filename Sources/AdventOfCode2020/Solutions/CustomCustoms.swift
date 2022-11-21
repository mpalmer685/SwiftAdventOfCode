import AOCKit

private typealias GroupAnswers = Set<Character>
private typealias AnswersCombiner = (inout GroupAnswers, GroupAnswers) -> Void

struct CustomCustoms: Puzzle {
    static let day = 6

    func part1() throws -> Int {
        countAnswers { $0.formUnion($1) }
    }

    func part2() throws -> Int {
        countAnswers { $0.formIntersection($1) }
    }

    private func countAnswers(using combineAnswers: AnswersCombiner) -> Int {
        getGroupAnswers(using: combineAnswers).reduce(0) { $0 + $1.count }
    }

    private func getGroupAnswers(
        using combineAnswers: AnswersCombiner
    ) -> [GroupAnswers] {
        input().lines
            .split(whereSeparator: \.isEmpty)
            .map { Array($0).map { Set($0.raw) } }
            .map { $0.reduce(into: $0.first!, combineAnswers) }
    }
}
