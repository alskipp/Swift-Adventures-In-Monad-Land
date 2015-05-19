import Foundation

public func JSONFromFile(file: String) -> AnyObject? {
  return NSBundle.mainBundle().pathForResource(file, ofType: "json").flatMap { p in
    NSData(contentsOfFile: p).flatMap { data in
      NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)
    }
  }
}



public struct Person: Printable {
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
extension Person {
  public static func create(name:String)(job:String)(birthYear:Int) -> Person {
    return Person(name:name, job:job, birthYear:birthYear)
  }
}

/*
Apply operator for Optionals:
Takes an Optional function and an Optional value,
If both function and value are not nil, then apply the function to the value
*/
infix operator <*> { associativity left precedence 130 }

public func <*> <A,B>(f:(A -> B)?, x:A?) -> B? {
  if let f = f, x = x {
    return f(x)
  }
  return .None
}