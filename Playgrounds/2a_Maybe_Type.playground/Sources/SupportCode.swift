
// Declare The Maybe type to use with MaybeDictionary
public enum Maybe<T> : NilLiteralConvertible {
    case None, Some(T)
    
    public init() { self = None }
    public init(_ some: T) { self = Some(some) }
    public init(nilLiteral: ()) { self = None }
}


/*
The implementation of MaybeDictionary is adapted from http://airspeedvelocity.net
*/

public struct MaybeDictionary<Key: Hashable, Value>: DictionaryLiteralConvertible {
    public typealias Element = (Key, Value)
    private typealias Storage = [Element]
    private var _store: Storage = []
    
    private func _indexForKey(key: Key) -> Storage.Index? {
        for (idx, (k, _)) in zip(_store.indices,_store) {
            if key == k { return idx }
        }
        return nil
    }
    
    public subscript(key: Key) -> Maybe<Value> {
        get {
            if let idx = _indexForKey(key) {
                return Maybe(_store[idx].1)
            }
            return .None
        }
        
        set(newValue) {
            switch (_indexForKey(key), newValue) {
                
            case let (.Some(idx), .Some(value)):
                _store[idx].1 = value
                
            case let (.Some(idx), .None):
                _store.removeAtIndex(idx)
                
            case let (.None, .Some(value)):
                _store.append((key, value))
                
            case (.None,.None): break
            }
        }
    }

	public init(dictionaryLiteral elements: (Key, Value)...) {
        for (k,v) in elements {
            self[k] = Maybe(v)
        }
    }
}