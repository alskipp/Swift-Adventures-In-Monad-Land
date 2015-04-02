
public func >>= <A,B>(x: A?, @noescape f: A -> B?) -> B? {
    switch x {
    case .None : return .None
    case .Some(let x) : return f(x)
    }
}