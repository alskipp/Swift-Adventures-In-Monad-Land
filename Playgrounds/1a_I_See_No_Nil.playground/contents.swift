/*:
## What is *nil* Anyway?

This is the beginnning of *Swift Adventures in Monad Land*. However, there won't be any monads here, not yet.

**nil**, or the absence of **nil**, is an important topic in Swift – and one that will lead ineluctably to the
land of the monad. If you're familiar with a language that has the concept of **nil** then prepare to be surprised,
**nil** is not what it seems in Swift.

#### Every *value* has a *type* in Swift.

**Question:** *what is the type of **nil**?*

**Answer:** ***nil** does not have a type, and therefore, can not have a value.*

**What!? Is *nil* less than nothing?** Thankfully not, it's actually quite simple –
during compilation all instances of **nil** are replaced with a valid value,
if the type checker is unable to infer the type that a **nil** should be replaced with, your program will fail to compile.

What value can **nil** become? Well, almost certainly, it will become an **Optional**, which is a simple **enum** type
that has two possible cases. Here it is:

    enum Optional<T> {
        case none
        case some(T)
    }

Instead of **nil** the potential non-existence of a value will be represented by the **Optional** type.
Typically in imperative languages, all reference types can potentially be **nil**. At runtime an unexpected **nil**
will likely cause a crash. In Swift this can't happen, **Optional** types are checked by the compiler and *must* be dealt with correctly.
If you miss the good old days of runtime **nil** crashes, then you can just throw in an exclamation mark **!** (*Don't do this!*).

* * *

Unfortunately, Xcode is really unhelpful when displaying **Optional** values –
*.none* is displayed as *nil* and wrapped values are displayed as plain values.
The function *optToString*, used in the code below is not a Swift library function,
it has been added to give useful **String** representations of **Optionals**.
Take a look in the *Sources* folder if you're interested in why and how it's implemented.

* * *

## Name that *nil* in one!


The following examples use explicit type declarations and an assignment of **nil**.
The question is, what is the type of **nil**?

Note: **Int?** is just short-hand for **Optional<Int>**.
*/
let a: Int? = nil
optToString(a)

let b: String? = nil
optToString(b)

let c: Bool? = nil
optToString(c)

/*:
## Where's the magic happening?
The examples above show an assigment of **nil**, yet the value of the variable is not **nil**, it's an **Optional**.
Is there some secret compiler shenanigans ocurring which is responsible for figuring out how to transform **nil**
into a normal, useable value? Well, not really. The mechanism responsible for transforming **nil** into something useful
is the protocol, **NilLiteralConvertible**. Here it is:

    protocol NilLiteralConvertible {
        init(nilLiteral: ())
    }

Nothing magical there. If a type conforms to the **NilLiteralConvertible** protocol, it must implement an *init* method
which can produce a default value of the type. The *init* method receives one argument containing no useful information 
(it is merely the *empty tuple*). It is therefore impossible to derive any information from the
argument (it's simply a stand-in for *nil*) and a *default* value must be returned from the method. 
Here's an example of how the **Optional** type can conform to the **NilLiteralConvertible** protocol:

    enum Optional<T> : NilLiteralConvertible {
        init(nilLiteral: ()) {
            self = none
        }
    }

The only sensible value for the **Optional** is the **none** case.

* * *

It's not possible to assign **nil** to any type of value,
the type must conform to the **NilLiteralConvertible** protocol. Example:

    let v:Int = nil // *Error* Type 'Int' does not conform to protocol 'NilLiteralConvertible'

* * *

Instead of assigning **nil** to a variable, it is perfectly valid to assign **.none**.
In fact, the result is exactly the same and it is also immediately clear that an **Optional** is being assigned – 
consequently, the expression does not need to be squeezed through the **NilLiteralConvertible** sausage machine.
*/

let a1: Int? = .none
optToString(a1)

let b1: String? = .none
optToString(b)

/*:
### Testing **Optionals** for equality with **‘nil’**

One way to query an **Optional** value to find out if it has an *associated value* is to test for equality with **‘nil’**.

**But, is equality really tested against *nil*? *No***, it will be transformed into a valid value with **NilLiteralConvertible**.

Just as in the examples above (where **nil** is assigned to a variable), the value of the variable is never **nil**, 
it is **Optional<T>.none** (where **T** is an actual type, such as *Int*, *String*, etc).

* * *

**Note:** *if let* syntax and the *map* function should be preferred over explicit **‘nil’** checking.
*/

let d: Int? = 1
d != nil

//: If the **Optional** init method is used, explicit type declarations are not required.
let e = Optional("Hello")
e != nil

let f: [Int]? = [1,2,3]
f != nil
/*:
If the types can be inferred, explicit type declarations are not required.
The **Int()** initializer with a String argument returns an **Optional<Int>**.
Also, just like assigning **.none** to a variable, it's perfectly valid (and arguably clearer) to test for equality with **.none**
*/
let g = Int("hello")
g != .none

let h: Int? = Int("42")
h != .none
/*:
When a variable is declared as an **Optional** it is possible to assign a *non-optional* value to the variable.
The *non-optional* value will be automatically wrapped in an **Optional**.
This may seem perfectly obvious, but it is actually a little unusual.
For example the same does not apply to other ‘containers’, such as **Array**.

    let x:[Int] = 8 // *Compiler Error - 'Int' is not convertible to '[Int]'

Whereas the following is acceptable:

    let x:Int? = 8 // result is: Optional<Int>.some(8)

* * *

## Is *nil* less than zero?

You might expect **nil** to be equal to zero. Well is it?
*/
nil < 0

/*:
**It turns out that *nil* is less than zero. How can this be?**

The first thing to recall is that **nil** isn't really **nil**, it's an **Optional**.
What we really have is:

    .none < 0
*/
(.none) < 0

/*:
The question is: What type of **.none** is it? It's an **Optional**, 
but an **Optional** must have an associated type. In this instance
the only sensible type is **Int**. Therefore **.none** can be expanded to:

    Optional<Int>.none < 0
*/
Optional<Int>.none < 0

/*:
We've fully expanded the type of **nil**, but there's another problem to address.
How can the **<** operator be used to compare *values* of different *types*?

The left hand side of the expression is an **Optional** and the right hand side is an **Int**.
The operator **<** for comparing **Optionals** has the following definition:

    func < <T:_Comparable>(lhs: T?, rhs: T?) -> Bool

Both values must be **Optionals** of the same type. 
There isn't another overload of the **<** operator that accepts **Optionals** and non-optionals.

## The final piece of the puzzle

As previously mentioned, it's possible (and normal practice) to declare an **Optional** type then assign
a normal value to it:

    let x:Int? = 8 // result is: Optional<Int>.some(8)

The same thing occurs when a parameter to a function is an **Optional** value -
a non-optional can be passed to the function and it will automatically become an **Optional** within the context of the function.

This implicit behaviour doesn't have an official name, but **automatic Optional wrapping**, or **automatic Optional lifting** will do.

Therefore in the expression:

    Optional<Int>.none < 0

The right hand side is automatically lifted into an **Optional**:

    Optional<Int>.none < .some(0)

To give the most explicit and verbose form:

    Optional<Int>.none < Optional<Int>.some(0)
*/
Optional<Int>.none < Optional<Int>.some(0)

/*:
The seemingly simple expression:

    nil < 0

Will, after compilation, become:

    Optional<Int>.none < Optional<Int>.some(0)

Here is an implementation of **<** for **Optional** types - 
**.none** is by default always less than **.some**. When both values are **.some**, 
their wrapped values are compared to give a result.

    func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
        switch (lhs, rhs) {
        case (.none, .some) : return true
        case let (.some(x), .some(y)) : return x < y
        default : return false
        }
    }

And that is why **nil < 0** is true.

* * *

The same logic applies to all **Comparable** types. Here's an example with **String**:
*/
"a" > nil

"a" > .none

Optional<String>.some("a") > Optional<String>.none

/*:
* * *

That's the end of this expedition into the heart of darkness of **nil**, **NilLiteralConvertible** and **Optional** values.
*/
