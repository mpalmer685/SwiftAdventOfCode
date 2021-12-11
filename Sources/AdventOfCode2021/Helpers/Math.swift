func median(of values: [Int]) -> Int {
    values.sorted(by: <)[values.count / 2]
}

func mean(of values: [Int]) -> Int {
    values.reduce(0, +) / values.count
}
