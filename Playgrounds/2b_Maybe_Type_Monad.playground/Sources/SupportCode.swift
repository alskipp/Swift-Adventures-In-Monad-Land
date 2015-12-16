public enum Maybe<T> : NilLiteralConvertible {
    case None, Some(T)
    
    public init() { self = None }
    public init(_ some: T) { self = Some(some) }
    public init(nilLiteral: ()) { self = None }
    
    func map<U>(f: T -> U) -> Maybe<U> {
        switch self {
        case .None : return .None
        case .Some(let x) : return .Some(f(x))
        }
    }
}

extension Maybe : CustomStringConvertible {
    public var description: String {
        switch self {
        case .None : return "{None}"
        case .Some(let x) : return "{Some \(x)}"
        }
    }
}

public func == <T: Equatable>(lhs: Maybe<T>, rhs: Maybe<T>) -> Bool {
    switch (lhs, rhs) {
    case (.None, .None) : return true
    case let (.Some(x), .Some(y)) : return x == y
    default : return false
    }
}

public func < <T: Comparable>(lhs: Maybe<T>, rhs: Maybe<T>) -> Bool {
    switch (lhs, rhs) {
    case (.None, .Some) : return true
    case let (.Some(x), .Some(y)) : return x < y
    default : return false
    }
}

public func > <T: Comparable>(lhs: Maybe<T>, rhs: Maybe<T>) -> Bool {
    return rhs < lhs
}