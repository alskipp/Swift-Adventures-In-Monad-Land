/*
nil/Optional is a difficult topic to cover because Xcode's display of Optional types is a big lie.
Xcode will display Optionals as plain values if they have an associated value 
and it will display the value as nil if the value of the Optional is .None.

Below is a function (optToString) that will convert Optionals to a sensible String value.

Due to the inescapeable weirdness of Optionals it's impossible to write a function that only accepts Optional values.
Therefore optToString will curiously accept non-optional values as input.
*/


// A thoroughly ugly function that produces a sensible String representation of an Optional value.
// Yes, it's a truly horrible hack - Do not use in the wild!

import Foundation

public func optToString<T>(v: T?) -> String {
/*
    "\(T.self)" gets the type of the parameter as a String. Examples:
    
    Swift.String
    Swift.Array<Swift.Int>
    
    Need to remove occurrences of 'Swift.' from the String
    
    ######################################################
    
    "\(v.self)" gets the value of the Optional. Examples:
    
    nil
    Optional("hi")
    Optional([1,2,3])
    
    Need to replace 'nil' with '.None'
    Need to remove '(' and ')' from the String
    
    ######################################################

    Desired String format examples:
    
    Optional<Int>.None
    Optional<Array<String>>.None
    Optional<String>.Some("hi")
    Optional<Array<Int>>.Some([1,2,3])
    
*/

    let type = "\(T.self)".stringByReplacingOccurrencesOfString("Swift.", withString:"")
    let value = "\(v.self)"

    if value != "nil" {
        let v = split(value) { $0 == "(" || $0 == ")" }
        return "<\(type)>.Some(".join(v) + ")"
    }
    return "Optional<\(type)>.None"
}