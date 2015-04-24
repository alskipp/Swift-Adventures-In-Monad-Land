/*:
## Three binds are better than one

You don't need to have a black belt in *category theory* to get mixed up with monadic binding in Swift.
The chances are that you're already using monadic bind in your code.

* * *

It was previously shown that if we create a custom Dictionary which returns **Maybe** values when subscripting
(instead of *Optionals*), then subscripting into nested Dictionaries becomes an onerous task.
That's because each returned value needs to be pattern matched with a switch statement to check if the **Maybe** has a value.
If you're feeling masochistic, it's perfectly possible to use this approach with **Optionals**.
here's an example (Not recommended!):
*/
let dict = [1:[2:[3:[4:[5:"Hello!"]]]]]

let a:String?

switch dict[1] {
case .None : a = .None
case .Some(let d) :
    switch d[2] {
    case .None : a = .None
    case .Some(let d) :
        switch d[3] {
        case .None : a = .None
        case .Some(let d) :
            switch d[4] {
            case .None : a = .None
            case .Some(let d) :
                switch d[5] {
                case .None : a = .None
                case .Some(let x) : a = x
                }
            }
        }
    }
}
a

/*:
## Monadic bind #1 – Optional chaining

If the use of **Optionals** entailed that kind of code, Swift would be a much loathed language.
The correct approach is to use *Optional chaining*, as follows:
*/
dict[1]?[2]?[3]?[4]?[5]

/*:
The pattern matching boiler plate code has been abstracted away inside the magical **?s**.
It turns out that *Optional chaining* with **?** is monadic bind that is restricted to methods and subscript operations.
If we define the bind operator **>>=** for **Optionals**, it's easy to see the similarity.
*/
infix operator >>= {associativity left}

func >>= <A,B>(x: A?, f: A -> B?) -> B? {
    switch x {
    case .None : return .None
    case .Some(let x) : return f(x)
    }
}
//: The monadic nature of *Optional chaining*
let v = dict[1] >>= { $0[2] } >>= { $0[3] } >>= { $0[4] } >>= { $0[5] }
v
/*:
If you imagine **>>=** replaced by **?** the similarity to *Optional chaining* should be more apparent.
In practice, you'd never use the bind operator to subscript into a nested **Dictionary**.
The purpose of showing it, is to demonstrate what *Optional chaining* with **?** is doing behind the scenes.

* * *

## Monadic bind #2 – ‘if let’ syntax

With the introduction of Swift 1.2 it became possible to use ‘if let’ syntax for monadic bind.
To escape from the pyramid of doom (nested ‘if let’ statements), Swift 1.2 made it possible to bind
multiple **Optionals** in one statement. An interesting aspect of this new ability is that
bindings can reference earlier bindings in the statement. The consequence of this is that it is now
feasible to use ‘if let’ syntax for monadic binding.

Which means that it is possible (although painfully verbose) to subscript into a nested *Dictionary* using **if let** syntax.
As **if let** is a statement, not an expression, a variable must be declared first, then assigned to in the **if let** statement:
*/
let ifLetBind:String?

if let a = dict[1], b = a[2], c = b[3], d = c[4], e = d[5] {
    ifLetBind = e
} else {
    ifLetBind = .None
}

ifLetBind

/*:
The code above, I think you'll agree is dreadful, but it does reveal that the **binding** of values in **if let** syntax 
can express the same functionality as *Optional chaining*.

The monadic nature of **if let** syntax is only revealed when bindings depend upon previous bindings in the statement.
For example, the following is **not** the equivalent of monadic bind, because the bindings are independent from each other:
*/
let x = Optional(1)
let y = Optional(2)

if let a = x, b = y {
    a + b
}
/*:
## Monadic bind #3 – flatMap

The third monadic bind for **Optionals** is **flatMap** – it was added in Swift 1.2.
(it's not restricted to **Optionals**, but Optionals will be the focus for now).

If we compare the declaration of the **flatMap** method on **optionals** to the bind operator,
the similarity should be obvious. The difference is that in the flatMap method **self** is an implicit parameter

    func flatMap<U>      (f: T -> U?) -> U?
    func >>= <T,U>(x: T?, f: T -> U?) -> U?

*/
dict[1].flatMap { $0[2] }
       .flatMap { $0[3] }
       .flatMap { $0[4] }
       .flatMap { $0[5] }

/*:
### *Optional chaining* is *usually* the right choice

But here's a contrived example where *Optional chaining* is unable to work.

* * *

Given a **String** take the first character and convert it to an **Int**.
(Taking the first character and converting to an **Int** are both operations that return an **Optional**.)

* * *

The reason why *Optional chaining* will fail to work in this instance is because taking the first element of a **String** 
returns an **Optional<Character>** and **Character** does not have a **toInt()** method.
Therefore the **Character** must be converted to a **String** before calling the **toInt()** method.

    first(str)?.toInt() // will not work

Below are examples of how to solve the task:
*/
let str = "7-X-Y-Z"

first(str).flatMap { String($0).toInt() }

first(str) >>= { String($0).toInt() }

if let c = first(str), i = String(c).toInt() {
    i
}
/*:
To be able to use *Optional chaining* syntax, the conversion from **Character** to **String**
would have to be implemented as a method on **Character**.
It's possible to achieve this with an **extension** to the **Character** type.
*/
extension Character {
    func toString() -> String {
        return String(self)
    }
}

first(str)?.toString().toInt()

/*:
* * *

That was a brief exploration of how monadic bind for **Optionals** manifests itself in various forms in Swift.

Next time: **flatMap** with **Array**.
*/
