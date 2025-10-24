// MARK: - ForEach

public extension Sequence where Element: Sendable {
    func concurrentForEach(
        withPriority priority: TaskPriority? = nil,
        _ operation: @Sendable @escaping (Element) async -> Void,
    ) async {
        await withTaskGroup(of: Void.self) { group in
            for element in self {
                group.addTask(priority: priority) {
                    await operation(element)
                }
            }
        }
    }

    func concurrentForEach(
        withPriority priority: TaskPriority? = nil,
        _ operation: @Sendable @escaping (Element) async throws -> Void,
    ) async rethrows {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for element in self {
                group.addTask(priority: priority) {
                    try await operation(element)
                }
            }

            for try await _ in group {}
        }
    }
}

// MARK: - Map

public extension Sequence where Element: Sendable {
    func concurrentMap<T: Sendable>(
        withPriority priority: TaskPriority? = nil,
        _ transform: @Sendable @escaping (Element) async -> T,
    ) async -> [T] {
        await withTaskGroup(of: (offset: Int, value: T).self) { group in
            var c = 0
            for element in self {
                let idx = c
                c += 1
                group.addTask(priority: priority) {
                    await (idx, transform(element))
                }
            }

            var res = [T?](repeating: nil, count: c)
            while let next = await group.next() {
                res[next.offset] = next.value
            }
            // swiftlint:disable:next force_cast
            return res as! [T]
        }
    }

    func concurrentMap<T: Sendable>(
        withPriority priority: TaskPriority? = nil,
        _ transform: @Sendable @escaping (Element) async throws -> T,
    ) async rethrows -> [T] {
        try await withThrowingTaskGroup(of: (offset: Int, value: T).self) { group in
            var c = 0
            for element in self {
                let idx = c
                c += 1
                group.addTask(priority: priority) {
                    try await (idx, transform(element))
                }
            }

            var res = [T?](repeating: nil, count: c)
            while let next = try await group.next() {
                res[next.offset] = next.value
            }
            // swiftlint:disable:next force_cast
            return res as! [T]
        }
    }
}

// MARK: - CompactMap

public extension Sequence where Element: Sendable {
    func concurrentCompactMap<T: Sendable>(
        withPriority priority: TaskPriority? = nil,
        _ transform: @Sendable @escaping (Element) async -> T?,
    ) async -> [T] {
        await withTaskGroup(of: (offset: Int, value: T?).self) { group in
            var c = 0
            for element in self {
                let idx = c
                c += 1
                group.addTask(priority: priority) {
                    await (idx, transform(element))
                }
            }

            var res = [T??](repeating: nil, count: c)
            while let next = await group.next() {
                res[next.offset] = next.value
            }
            // swiftlint:disable:next force_cast
            return (res as! [T?]).compactMap(\.self)
        }
    }

    func concurrentCompactMap<T: Sendable>(
        withPriority priority: TaskPriority? = nil,
        _ transform: @Sendable @escaping (Element) async throws -> T?,
    ) async rethrows -> [T] {
        try await withThrowingTaskGroup(of: (offset: Int, value: T?).self) { group in
            var c = 0
            for element in self {
                let idx = c
                c += 1
                group.addTask(priority: priority) {
                    try await (idx, transform(element))
                }
            }

            var res = [T??](repeating: nil, count: c)
            while let next = try await group.next() {
                res[next.offset] = next.value
            }
            // swiftlint:disable:next force_cast
            return (res as! [T?]).compactMap(\.self)
        }
    }
}

// MARK: - FlatMap

public extension Sequence where Element: Sendable {
    func concurrentFlatMap<T: Sequence & Sendable>(
        withPriority priority: TaskPriority? = nil,
        _ transform: @Sendable @escaping (Element) async -> T,
    ) async -> [T.Element] {
        await withTaskGroup(of: (offset: Int, value: T).self) { group in
            var c = 0
            for element in self {
                let idx = c
                c += 1
                group.addTask(priority: priority) {
                    await (idx, transform(element))
                }
            }

            var res = [T?](repeating: nil, count: c)
            while let next = await group.next() {
                res[next.offset] = next.value
            }
            // swiftlint:disable:next force_cast
            return (res as! [T]).flatMap(\.self)
        }
    }

    func concurrentFlatMap<T: Sequence & Sendable>(
        withPriority priority: TaskPriority? = nil,
        _ transform: @Sendable @escaping (Element) async throws -> T,
    ) async rethrows -> [T.Element] {
        try await withThrowingTaskGroup(of: (offset: Int, value: T).self) { group in
            var c = 0
            for element in self {
                let idx = c
                c += 1
                group.addTask(priority: priority) {
                    try await (idx, transform(element))
                }
            }

            var res = [T?](repeating: nil, count: c)
            while let next = try await group.next() {
                res[next.offset] = next.value
            }
            // swiftlint:disable:next force_cast
            return (res as! [T]).flatMap(\.self)
        }
    }
}

// MARK: - Count

public extension Sequence where Element: Sendable {
    func concurrentCount(
        withPriority priority: TaskPriority? = nil,
        where isIncluded: @Sendable @escaping (Element) async -> Bool,
    ) async -> Int {
        await withTaskGroup(of: Int.self) { group in
            for element in self {
                group.addTask(priority: priority) {
                    await isIncluded(element) ? 1 : 0
                }
            }

            var count = 0
            for await partialCount in group {
                count += partialCount
            }

            return count
        }
    }

    func concurrentCount(
        withPriority priority: TaskPriority? = nil,
        where isIncluded: @Sendable @escaping (Element) async throws -> Bool,
    ) async rethrows -> Int {
        try await withThrowingTaskGroup(of: Int.self) { group in
            for element in self {
                group.addTask(priority: priority) {
                    try await isIncluded(element) ? 1 : 0
                }
            }

            var count = 0
            for try await partialCount in group {
                count += partialCount
            }

            return count
        }
    }
}
