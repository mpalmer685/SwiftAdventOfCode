// https://www.swiftbysundell.com/articles/encapsulating-configuration-code-in-swift/#configuration-closures
func configure<T>(_ object: T, using closure: (inout T) -> Void) -> T {
    var object = object
    closure(&object)
    return object
}
