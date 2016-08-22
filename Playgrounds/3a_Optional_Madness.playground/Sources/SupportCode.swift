
public func >>= <A,B>(x: A?, f: (A) -> B?) -> B? {
    switch x {
    case .none : return .none
    case .some(let x) : return f(x)
    }
}

public enum Maybe<T> : ExpressibleByNilLiteral {
    case none, some(T)
    
    public init() { self = .none }
    public init(_ s: T) { self = .some(s) }
    public init(nilLiteral: ()) { self = .none }
    
    public func map<U>(_ f: (T) -> U) -> Maybe<U> {
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


public func map<A,B>(_ m: Maybe<A>, f: (A) -> B) -> Maybe<B> {
    switch m {
    case .none : return .none
    case .some(let x) : return .some(f(x))
    }
}

public func pure<A>(_ x:A) -> Maybe<A> {
    return Maybe(x)
}

//infix operator >>= {associativity left}
public func >>= <A,B> (m: Maybe<A>, f: (A) -> Maybe<B>) -> Maybe<B> {
    switch m {
    case .none : return .none
    case .some(let m) : return f(m)
    }
}
