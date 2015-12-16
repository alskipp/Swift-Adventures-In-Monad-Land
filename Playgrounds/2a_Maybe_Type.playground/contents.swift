/*:
## How to implement the *Optional* type in Swift

The purpose of implementing our own **Optional** type is to demonstrate that **Optionals** are simple **enum values**.

As the **Optional** type already exists, we'll need a new name.
The name **Maybe** is taken from Haskell, but the two cases *None* & *Some*
are the same as Swift's **Optional** type (Haskell uses *Nothing* & *Just*).
The **Maybe** type conforms to *NilLiteralConvertible*, as does Swift's **Optional** type.
This allows a **Maybe** value to be constructed from *nil*.

### What can't be implemented?
One aspect of Swift's **Optional** type which can't be reproduced is
*implicit Optional wrapping*. Here's an example:

    .None < 0

Such a comparison should not be possible as the types don't match.
However, Swift will automatically convert the expression to:

    .None < .Some(0)

It's impossible to reproduce the recipe for this secret sauce – it's an
**Optional** only capability which is often convenient, sometimes bizarre.
*Implicit Optional wrapping* also comes into play when returning **Optional**
values from functions. When reimplementing **Optionals**, values must always
be explicity wrapped using *Maybe(x)*, or by using the *.Some(x)* constructor.
*/

enum Maybe<T> : NilLiteralConvertible {
    case None
    case Some(T)
    
    init() { self = None } // init with no args defaults to 'None'
    init(_ some: T) { self = Some(some) }
    init(nilLiteral: ()) { self = None } // init with 'nil' defaults to 'None'
/*:
*map* takes a normal function from *T -> U* and runs it inside the **Maybe**.
* If the value of **self** is *.None* the function is not applied and *.None* is returned.
* If *self* matches the *.Some* case, then the function is applied to the *Associated Value* and wrapped in a **Maybe**
*/
    func map<U>(f: T -> U) -> Maybe<U> {
        switch self {
        case .None : return .None
        case .Some(let x) : return .Some(f(x))
        }
    }
}
//: Extend **Maybe** with the *CustomStringConvertible* protocol
extension Maybe : CustomStringConvertible {
    var description: String {
        switch self {
        case .None : return "{None}"
        case .Some(let x) : return "{Some \(x)}"
        }
    }
}
/*:
### *Equatable* & *Comparable* protocols

The built in **Optional** type does not conform to the *Equatable* or *Comparable* protocols.
Conforming to these protocols would prevent non-comparable values from being declared **Optional**.
This is what the type restriction would look like:

    enum Optional<T:Comparable> {}

There are however overloaded operators for equality and comparison that accept **Optionals**.
Below are a few overloaded operators for the **Maybe** type. As we can't conform to *Comparable*
we don't get any operators for free :(
*/

func == <T: Equatable>(lhs: Maybe<T>, rhs: Maybe<T>) -> Bool {
    switch (lhs, rhs) {
    case (.None, .None) : return true
    case let (.Some(x), .Some(y)) : return x == y
    default : return false
    }
}

func < <T: Comparable>(lhs: Maybe<T>, rhs: Maybe<T>) -> Bool {
    switch (lhs, rhs) {
    case (.None, .Some) : return true
    case let (.Some(x), .Some(y)) : return x < y
    default : return false
    }
}

func > <T: Comparable>(lhs: Maybe<T>, rhs: Maybe<T>) -> Bool {
    return rhs < lhs
}
/*:
### Usage of Custom *Maybe* Type

initializing **Maybe** without an arg requires a type declaration
*/
let m = Maybe<Int>()
print(m)
//: initializing Maybe with an arg – the type is inferred from the arg
let m1 = Maybe(1)
print(m1)
//: map func returns a new **Maybe**
let m2 = m1.map { $0 + 1 }
print(m2)
//: Comparing **Maybe** types
m1 == m2 // Maybe(1) == Maybe(2)
m1 < m2 // Maybe(1) < Maybe(2)
m1 > m2 // Maybe(1) > Maybe(2)
//: *NilLiteralConvertible* in action on custom **Maybe** type
nil < m1 // NilLiteralConvertible is invoked to contruct a Maybe value from 'nil'
//: Example of, *implicit Optional wrapping* with **Optionals**
Optional(1) < 2
/*:
the equivalent code using **Maybe** will not compile

    Maybe(1) < 2 // **Error**

* * *

Compared to the built in **Optional** type, the lack of syntax sugar will make the
**Maybe** type a bitter pill to swallow. *Optional chaining* with '?', nope.
Unwrapping multiple **Maybes** with *if let* syntax? No chance.
And, as just demonstrated, *implicit Optional wrapping*, is not possible either.

* * *

## *Optionals* contrasted with *Maybes* using nested Dictionaries

Given a nested **Dictionary**, how can we *subscript* through the *keys* to get to the final *value*?
Here's an example:

    let dict = [1:[2:[3:"Hello!"]]]
    dict[1][2][3] // This will not work

Subscripting operations can not just be chained together one after the other. That is because the return value
of subscripting into a **Dictionary** is an **Optional<Value>**.

    struct Dictionary<Key : Hashable, Value> {
        subscript (key: Key) -> Value?
    }

The problem is easily solved by using *Optional chaining syntax* **?**. See below.
*/
let dict = [1:[2:[3:"Hello!"]]]
let val = dict[1]?[2]?[3]

/*:
The type of *val* is not a plain **String**, it is an **Optional** (*.Some("Hello!")*) - Xcode lies a little!

* * *

## What if Dictionary subscripting returned **Maybe<Value>**

Let's give it a try. Below is an incredibly rudimentary Dictionary that does return **Maybe<Value>**
when *subscripting* is used. **Warning: *MaybeDictionary* is for demonstration purposes only.**

Here we have an example of a nested **MaybeDictionary**.
*/

let mDict:MaybeDictionary = [1:[2:[3:"Hello!"]]]
/*:
Now the difficulty arises: how do we subscript into the nested *Dictionary* to retrieve the final value?

*Optional chaining syntax* only works for **Optionals**, so we must resort to a more brute force approach.
*/
let v:Maybe<String>

switch mDict[1] {
case .None : v = .None
case .Some(let d) :
    switch d[2] {
    case .None : v = .None
    case .Some(let d) :
        switch d[3] {
        case .None : v = .None
        case .Some(let x) : v = .Some(x)
        }
    }
}

print(v)

/*:
## **Ouch!**

Next time you ask yourself – **‘What has *Optional chaining* ever done for us?’**, think about the code above.

This is not simply a failing of the custom **Maybe** type,
it demonstrates how to deal with Optionals in their raw, unadorned form.
It is perfectly evident that when chaining functions that return **Optionals** or **Maybes**,
some kind of abstraction is required to remove the need for explicit nested switch statements.
The next Playground file will tackle this problem – and it will involve the **M-Word!**
*/
