
public func >>= <A,B>(x: A?, @noescape f: A -> B?) -> B? {
    switch x {
    case .None : return .None
    case .Some(let x) : return f(x)
    }
}

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

extension Maybe : Printable {
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


public func map<A,B>(m: Maybe<A>, f: A -> B) -> Maybe<B> {
    switch m {
    case .None : return .None
    case .Some(let x) : return .Some(f(x))
    }
}

public func pure<A>(x:A) -> Maybe<A> {
    return Maybe(x)
}

//infix operator >>= {associativity left}
public func >>= <A,B> (m: Maybe<A>, f: A -> Maybe<B>) -> Maybe<B> {
    switch m {
    case .None : return .None
    case .Some(let m) : return f(m)
    }
}