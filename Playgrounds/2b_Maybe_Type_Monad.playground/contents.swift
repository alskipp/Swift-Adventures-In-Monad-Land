/*:
## The *Maybe* Type is an *Optional* Without the Syntax Sugar

What would it look like to use the **Maybe** type instead of the built in **Optional** type?
It might not be obvious, but the syntax sugar we use with **Optionals** (Optional chaining '?')
is in fact a monadic bind operation.

Consequently, we need to introduce **monadic bind** to the **Maybe** type (sugar free). Hold on!

* * *

It will be informative to first declare a top-level *map* function for **Maybe** types.
You may recall that *map* is already implemented as a method on the **Maybe** type.
The *map* method uses *self* as an implicit first parameter, whereas the function takes a **Maybe** as its first parameter.
Other than that, the functionality is identical. The reason for declaring *map* as a function is to show how
similar it is to *monadic bind* – declared below
*/
func map<A,B>(m: Maybe<A>, f: A -> B) -> Maybe<B> {
    switch m {
    case .None : return .None
    case .Some(let x) : return .Some(f(x))
    }
}
//: An example of using *map* with a *Maybe<Array>* and passing the *sorted* function as second parameter
let n = map(Maybe([3,2,5,1,4]), sorted)
println(n)
//: *Lift* plain values into the **Maybe** type. It's the explicit equivalent of *implicit Optional wrapping*.
func pure<A>(x:A) -> Maybe<A> {
    return Maybe(x)
}
/*:
**Monadic bind** operator for the **Maybe** type. This will be used instead of *Optional chaining syntax* (a?.b?.c)

The **>>=** (bind) operator is very similar to the *map* function, declared above:

    func map <A,B> (m: Maybe<A>, f: A -> B) -> Maybe<B>
    func >>= <A,B> (m: Maybe<A>, f: A -> Maybe<B>) -> Maybe<B>

The only difference between *map* and *monadic bind* is that the second parameter returns a *Maybe* for the *bind operator*.
This means that in the *.Some* case the function **f** will return the **Maybe** that is required.
The return value for *map* needs to be explicitly wrapped in a **Maybe** as the function **f** has the type *A -> B*.

Compare the implementation of **map** (above) to **>>=** to see how similar they are.
*/
infix operator >>= {associativity left}
func >>= <A,B> (m: Maybe<A>, f: A -> Maybe<B>) -> Maybe<B> {
    switch m {
    case .None : return .None
    case .Some(let m) : return f(m)
    }
}
/*:
## Why use an infix operator?

There are several techniques that could be used to implement *bind*:

* A method could be added to the **Optional** type (in fact such a method was added in Swift 1.2 – *flatMap*)
* A named top-level function (also added in Swift 1.2)
* An infix operator function

When programming in Swift, you're unlikely to use **>>=** that often in the wild, as the preference
is to use methods over top-level functions and custom operators.
**>>=** is used here for a couple of reasons. Firstly, both parameters are explicit,
so it's easier to follow the types of the function.
(The *flatMap* method on **Optionals** has *self* as an implicit first parameter,
which makes following the types a bit more difficult).

Secondly, the use of an infix operator is quite elegant when chaining functions together.
Below is a comparison of chaining several functions together using the different ways of implementing monadic bind:

    value >>= f >>= g >>= h                   // infix operator
    value.flatMap(f).flatMap(g).flatMap(h)    // flatMap method
    flatMap(flatMap(flatMap(value, f), g), h) // top-level flatMap function

In certain circumstances an enigmatic infix operator can actually be the easiest to read.

* * *

## An Example of *Monadic Bind*

To put our binding operator through its paces, let's create a few structs with properties to work on.
The idea is we have a **Room** struct with *width* & *length* properties.
We have a **Residence** struct with an *Array* of **Rooms**.
Finally we have a **Person** with a *name* and a *Maybe<Residence>*

So, a **Person**, may or may not have a **Residence**. A **Residence** has an *Array* of **Rooms**.
A **Room** has a *width* and *length*. Given these parameters we want to write a function
that calculates the livingspace of a **Person**. The return value of this function
will be *Maybe<Int>*, because a **Person** may not have a **Residence**.
*/

struct Room { let length:Int, width:Int }
struct Residence { let rooms:[Room] }
struct Person { let name:String, residence:Maybe<Residence>}
//:Create two people: one without a residence and one with a residence
let bob = Person(name: "Bob", residence: .None)
let jo = Person(name: "Jo",
    residence: .Some(
        Residence(rooms: [Room(length: 4, width: 3), Room(length: 2, width: 2)])
    )
)
/*:
To make things more interesting, we'll write a function that takes a *Maybe<Person>* and returns their 'livingspace' as a *Maybe<Int>*.

The bind operator **>>=** will be used to chain together functions that need to take *plain* values as input and return **Maybe** values.
Without the bind operator explicit *switch statements* would be required to chain the functions together.
The use of *switch statements* would add verbosity and remove clarity.

Notice that the *pure* function is used to lift the return value into the **Maybe** type.
*/
func livingSpace(person:Maybe<Person>) -> Maybe<Int> {
    return person >>= { $0.residence }
                  >>= { pure($0.rooms.map {$0.length * $0.width }.reduce(0, combine:+)) }
}
//: Call *livingSpace* function with a *Maybe<Person>*
let bob_space = livingSpace(Maybe(bob))
println(bob_space) // Bob has no residence, therefore the return value will be .None
//: Call *livingSpace* function with a *Maybe<Person>*
let jo_space = livingSpace(Maybe(jo))
println(jo_space)
/*:
## Using the *Optional* type

As a comparison, here's how it would look using the built in Optional type.
First, we need to declare a new version of the Person struct that has an Optional Residence.

The implementation should be much more familiar and easier to follow.
Just remember the *Monadic bind* operations you see above in the Maybe type version,
they're still happening, but concealed beneath the syntax sugar of Optional chaining.
*/

struct Person2 { let name:String, residence:Residence?}

let jed = Person2(name: "Jed", residence: .None)
let fi = Person2(name: "Fi", residence: Residence(rooms: [Room(length: 4, width: 3), Room(length: 2, width: 2)]))
/*:
A function that takes a *Optional<Person>* and returns their 'livingspace' as an *Optional<Int>*

Values passed to the function will be automatically *lifted* into the *Optional* type.
This differs from our custom *Maybe* type, where auto-lifting does not occur.
*/
func livingSpace(person:Person2?) -> Int? {
    return person?.residence?.rooms.map {$0.length * $0.width }.reduce(0, combine:+)
}
//: The parameter to *livingSpace* is declared *Optional*, but we can pass a non-Optional value
let jed_space = livingSpace(jed) // nil (Or to be precise .None)

let fi_space = livingSpace(fi) // Some(16) - but Xcode will just state 16, because it's mendacious.

