
// Declare The Maybe type to use with MaybeDictionary
public enum Maybe<T> : NilLiteralConvertible {
    case none, some(T)
    
    public init() { self = none }
    public init(_ s: T) { self = some(s) }
    public init(nilLiteral: ()) { self = none }
}


/*
The implementation of MaybeDictionary is adapted from http://airspeedvelocity.net
*/

public struct MaybeDictionary<Key: Hashable, Value>: DictionaryLiteralConvertible {
    public typealias Element = (Key, Value)
    private typealias Storage = [Element]
    private var _store: Storage = []
    
    private func _indexForKey(_ key: Key) -> Storage.Index? {
        for (idx, (k, _)) in zip(_store.indices, _store) {
            if key == k { return idx }
        }
        return nil
    }
    
    public subscript(key: Key) -> Maybe<Value> {
        get {
            if let idx = _indexForKey(key) {
                return Maybe(_store[idx].1)
            }
            return .none
        }
        
        set(newValue) {
            switch (_indexForKey(key), newValue) {
                
            case let (.some(idx), .some(value)):
                _store[idx].1 = value
                
            case let (.some(idx), .none):
                _store.remove(at: idx)
                
            case let (.none, .some(value)):
                _store.append((key, value))
                
            case (.none,.none): break
            }
        }
    }

	public init(dictionaryLiteral elements: (Key, Value)...) {
        for (k,v) in elements {
            self[k] = Maybe(v)
        }
    }
}
