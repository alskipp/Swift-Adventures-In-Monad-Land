public enum Maybe<T> : NilLiteralConvertible {
    case none, some(T)
    
    public init() { self = none }
    public init(_ s: T) { self = some(s) }
    public init(nilLiteral: ()) { self = none }
    
    func map<U>(_ f: (T) -> U) -> Maybe<U> {
        switch self {
        case .none : return .none
        case .some(let x) : return .some(f(x))
        }
    }
}

extension Maybe : CustomStringConvertible {
    public var description: String {
        switch self {
        case .none : return "{none}"
        case .some(let x) : return "{some \(x)}"
        }
    }
}

public func == <T: Equatable>(lhs: Maybe<T>, rhs: Maybe<T>) -> Bool {
    switch (lhs, rhs) {
    case (.none, .none) : return true
    case let (.some(x), .some(y)) : return x == y
    default : return false
    }
}

public func < <T: Comparable>(lhs: Maybe<T>, rhs: Maybe<T>) -> Bool {
    switch (lhs, rhs) {
    case (.none, .some) : return true
    case let (.some(x), .some(y)) : return x < y
    default : return false
    }
}

public func > <T: Comparable>(lhs: Maybe<T>, rhs: Maybe<T>) -> Bool {
    return rhs < lhs
}
