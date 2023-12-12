public func memoize<Input: Hashable, Output>(_ function: @escaping (Input) -> Output) -> (Input) -> Output {
    var memory: [Input: Output] = [:]

    return { arg in
        if let result = memory[arg] {
            return result
        }

        let result = function(arg)
        memory[arg] = result
        return result
    }
}

public func memoize<each Input: Hashable, Output>(_ function: @escaping (repeat each Input) -> Output) -> (repeat each Input) -> Output {
    var memory: [AnyHashable: Output] = [:]

    return { (argument: repeat each Input) in
        var key = [AnyHashable]()
        repeat key.append(AnyHashable(each argument))

        if let result = memory[key] {
            return result
        }

        let result = function(repeat each argument)
        memory[key] = result
        return result
    }
}

public func recursiveMemoize<Input: Hashable, Output>(_ function: @escaping ((Input) -> Output, Input) -> Output) -> (Input) -> Output {
    var memory: [Input: Output] = [:]
    var memoized: ((Input) -> Output)!

    memoized = { arg in
        if let result = memory[arg] {
            return result
        }

        let result = function(memoized, arg)
        memory[arg] = result
        return result
    }

    return memoized
}

public func recursiveMemoize<each Input: Hashable, Output>(_ function: @escaping ((repeat each Input) -> Output, repeat each Input) -> Output) -> (repeat each Input) -> Output {
    var memory: [AnyHashable: Output] = [:]
    var memoized: ((repeat each Input) -> Output)!

    memoized = { (argument: repeat each Input) in
        var key = [AnyHashable]()
        repeat key.append(AnyHashable(each argument))

        if let result = memory[key] {
            return result
        }

        let result = function(memoized, repeat each argument)
        memory[key] = result
        return result
    }

    return memoized
}
