public func sync<T: Sendable>(_ task: sending @escaping () async throws -> T) rethrows -> T {
    let semaphore = DispatchSemaphore(value: 0)
    var result: T!

    Task {
        result = try await task()
        semaphore.signal()
    }
    semaphore.wait()

    return result
}
