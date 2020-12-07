import AOCKit

private typealias GroupAnswers = Set<Character>
private typealias AnswersCombiner = (inout GroupAnswers, GroupAnswers) -> Void

struct CustomCustoms: Puzzle {
    func part1Solution(for input: String) throws -> Int {
        countAnswers(in: input) { $0.formUnion($1) }
    }

    func part2Solution(for input: String) throws -> Int {
        countAnswers(in: input) { $0.formIntersection($1) }
    }

    private func countAnswers(in input: String, using combineAnswers: AnswersCombiner) -> Int {
        getGroupAnswers(from: input, using: combineAnswers).reduce(0) { $0 + $1.count }
    }

    private func getGroupAnswers(
        from input: String,
        using combineAnswers: AnswersCombiner
    ) -> [GroupAnswers] {
        getLines(from: input, omittingEmptyLines: false)
            .split(whereSeparator: \.isEmpty)
            .map { Array($0).map { Set($0) } }
            .map { $0.reduce(into: $0.first!, combineAnswers) }
    }
}
