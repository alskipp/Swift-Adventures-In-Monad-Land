import Foundation

public func JSONFromFile(_ file: String) -> Any? {
	return Bundle.main.path(forResource: file, ofType: "json").flatMap { (p: String) -> Any? in
		let data = try! Data(contentsOf: URL(fileURLWithPath: p))
		return try! JSONSerialization.jsonObject(with: data, options: [])
    }
}



public struct Person: CustomStringConvertible {
  let name: String, job: String, birthYear: Int
  
  public init(name:String, job:String, birthYear:Int) {
    self.name = name
    self.job = job
    self.birthYear = birthYear
  }
  
  public var description: String {
    return "Person: \(name)\nYear of birth: \(birthYear)\nJob: \(job)"
  }
}



/*
A curried constructor function to use with the <*> operator. See below.
*/
public typealias Name = String
public typealias Job = String
public typealias BirthYear = Int
extension Person {
  public static func create(_ name:Name) -> (Job) -> (BirthYear) -> Person {
	return { job in
		return { birthYear in
			return Person(name:name, job:job, birthYear:birthYear)
		}
	}
  }
}

/*
Apply operator for Optionals:
Takes an Optional function and an Optional value,
If both function and value are not nil, then apply the function to the value
*/
precedencegroup ApplyPrecedence {
	associativity: left
	higherThan: ComparisonPrecedence
}
infix operator <*> : ApplyPrecedence

public func <*> <A,B>(f:((A) -> B)?, x:A?) -> B? {
  if let f = f, let x = x {
    return f(x)
  }
  return .none
}
