/*:
## When Optionals go Bad!

Presented below is an edge case where Optionals behave in such a way as to produce unexpected results.

To demonstrate this, we'll use a **Pet** struct that has one property *age*.
**Pets** usually have owners, so we'll also create a **Person** struct with two properties *name* and *pet*.
The *pet* property is **Optional**, as not all people will own a **Pet**.
*/

struct Pet { let age:Int }

struct Person {
    let name:String
    let pet:Pet? // pet property is Optional
}
//: make **Person** *Printable*
extension Person :Printable {
    var description: String {
        if let p = pet {
            return "\(name) has a Pet aged: \(p.age)"
        }
            return "\(name) has no pet"
        }
}
/*: 
**Create a *Person Array***

All people have a name and they may, or may not own a **Pet**
*/
let peeps = [Person(name: "Fred", pet:Pet(age: 10)),
             Person(name: "Jane", pet:Pet(age: 1)),
             Person(name: "Eric", pet:.None)]

/*:
**The Problem**

Suppose we wanted to filter the *Array* of *people* to include only those who own a **Pet** younger than 4 years old.
We would expect our *Array* to contain only *Jane* as the *age* of her **Pet** is 1.
*Fred’s* **Pet** is too old and *Eric* doesn't own a **Pet** so he shouldn't be included in the return results.
*/
let p = peeps.filter { $0.pet?.age < 4 }
println("People who own pets, younger than 4 years old:\n\n\(p)")

/*:
## What Just Happened!?

Both *Jane* and *Eric* appear in the results, despite the fact that *Eric* doesn't own a **Pet**!
The reason this happens is due to Swift's use of *automatic Optional wrapping*.

**Question:** What are the types in the *filter* closure?

On first glance, it would appear that the expression is comparing two **Ints** 
(*age* returns an **Int** and it's compared to the **Int** *4*).

    Int < Int

However, this is not the case. The *pet* property is **Optional**, therefore the *age* property must also be **Optional**.
The consequence of this is that right-hand-side of the expression **(4)** must be *auto-wrapped* into an **Optional**.
Otherwise the types won't match; Swift *helpfully* wraps the **4** in an **Optional**. The types are actually:

    Optional<Int> < <Optional<Int>

When *Eric* is filtered, the *types* and *values* of the expression are as follows:

    Optional<Int>.None < Optional<Int>.Some(4)

**.None** is always less than **.Some**, therefore the expression returns *true*.

* * *

**Possible Fixes**

One possibilty is to use the new *if let syntax* with a *where* clause.
The return value is only *true* if the **Person** has a **Pet** and it is younger than *4*.
The code isn't as succinct, or as clear as the previous version, but, it does return the expected result!
*/

let p2 = peeps.filter {
    if let p = $0.pet where p.age < 4 {
        return true
    }
    return false
}
println(p2)

/*:
**Another Alternative**

The **maybe** function is taken from *Haskell*. The *first parameter* to the function is the default value
which is used in case the value of the *second parameter* is **Optional.None**. The *third parameter* is the function to be applied.

It is similar to *map* for *Optionals*, but the *default parameter* allows the return value to be a non-optional value.
*/

func maybe<A,B>(@autoclosure fallback:() -> B, opt:A?, @noescape f:A -> B) -> B {
    switch opt {
    case .None : return fallback()
    case .Some(let x) : return f(x)
    }
}

/*:
**Usage of the *maybe* function**

Call *filter*, then inside the closure, call *maybe* with a default of *false* and a 2nd arg *$0.pet* which is an **Optional**.
Finally, pass a closure as the final argument to **maybe**.
The return value of the expression is the expected value.
*/
let p3 = peeps.filter { maybe(false, $0.pet) { $0.age < 4 } }
println(p3)

/*:
**One more for *bad* measure**

The final alternative uses both *monadic bind* on **Optional** and the *nil coalescing operator*.
It does exactly the same thing as the **maybe** function, but with less clarity.
The return value of the bind operator is *Optional<Bool>.None* when the *Pet* is *.None*.
The *nil coalescing operator* **??** unwraps the **Optional** value, or replaces it with the default value *false*.
*/
let p4 = peeps.filter { ($0.pet >>= { $0.age < 4 }) ?? false }
println(p4)

