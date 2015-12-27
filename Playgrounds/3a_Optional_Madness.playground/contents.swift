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
//: make **Person** *CustomStringConvertible*
extension Person: CustomStringConvertible {
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
print("People who own pets, younger than 4 years old:\n\n\(p)")

/*:
## What Just Happened!?

Both *Jane* and *Eric* appear in the results, despite the fact that *Eric* doesn't own a **Pet**!
The reason this happens is due to Swift's use of *automatic Optional wrapping*.

**Question:** What are the types in the *filter* closure?

On first glance, it would appear that the expression is comparing two **Ints** 
(*age* returns an **Int** and it's compared to the **Int** *4*).

    Int < Int

However, this is not the case. The *pet* property is **Optional**, therefore the *age* property must also be **Optional**.
The consequence of this is that the right-hand-side of the expression **(4)** must be *auto-wrapped* into an **Optional**.
Otherwise the types won't match; Swift *helpfully* wraps the **4** in an **Optional**. The types of the expression are actually:

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
print(p2)

/*:
**Another Alternative**

The **maybe** function is taken from *Haskell*. The *first parameter* to the function is the default value
which is used in case the value of the *second parameter* is **Optional.None**. The *third parameter* is the function to be applied.

It is similar to *map* for *Optionals*, but the *default parameter* allows the return value to be a non-optional value.
*/

func maybe<A,B>(@autoclosure defaultValue:() -> B, opt:A?, @noescape f:A -> B) -> B {
    switch opt {
    case .None : return defaultValue()
    case .Some(let x) : return f(x)
    }
}

/*:
**Usage of the *maybe* function**

Call *filter*, then inside the closure, call *maybe* with a default of *false* and a 2nd arg *$0.pet* which is an **Optional**.
Finally, pass a closure as the final argument to **maybe**.
The return value of the expression is the expected value.
*/
let p3 = peeps.filter { maybe(false, opt: $0.pet) { $0.age < 4 } }
print(p3)

/*:
**There's more than one way to skin an *Optional***

The next approach uses both *monadic bind* on **Optional** and the *nil coalescing operator*.
It does exactly the same thing as the **maybe** function, however it's pretty difficult to read.
The return value of the bind operator is *Optional<Bool>.None* when the *Pet* is *.None*.
The *nil coalescing operator* **??** unwraps the **Optional** value and returns it –
if there's no associated value to unwrap, it returns the default value, in this case *'false'*.
*/
let p4 = peeps.filter { ($0.pet >>= { $0.age < 4 }) ?? false }
print(p4)

/*:
**Flatten the mapping**

Rather than use the custom bind operator **>>=**, it would probably be better in this instance to use Swift's built-in flatMap function.
*/
let p5 = peeps.filter { ($0.pet.flatMap { $0.age < 4 }) ?? false }
print(p5)

/*:
**What's flatMap?**

The flatMap function is a recent addition to Swift – its behaviour is the same as the custom bind operator **>>=**.

The next thrilling installment of 'Swift Adventures in Monad Land' will discuss flatMap.

* * *

## A brief look at the **Maybe** type

Out of interest, what would the implementation look like using the custom **Maybe** type instead of **Optionals**?
To find out, let's create a **Person** struct with a **Maybe<Pet>** property.
(What is certain is that the same bug won't occur, because unlike **Optionals**, 
the **Maybe** type does not support automatic wrapping of values).
*/
struct Person2 {
    let name:String
    let pet:Maybe<Pet> // pet property is Pet wrapped in a Maybe
}

extension Person2 : CustomStringConvertible {
    var description: String {
        switch pet {
        case .Some(let p) : return "\(name) has a Pet aged: \(p.age)"
        default : return "\(name) has no pet"
        }
    }
}
//: create an array of people, this time with **Maybe<Pet>** properties
let peeps2 = [Person2(name: "Fred", pet:Maybe(Pet(age: 10))),
              Person2(name: "Jane", pet:Maybe(Pet(age: 1))),
              Person2(name: "Eric", pet:.None)]
/*:
A first attempt at filtering the Array might be as follows:

    peeps2.filter { $0.pet >>= { pure($0.age < 4) } }

This seems like a reasonable approach, but it doesn't work. 
The reason is because the return type of the closure passed to filter is incorrect.
**filter** expects a closure with a return type of **Bool**.

    { $0.pet >>= { pure($0.age < 4) } }

The return type of the above closure is **Maybe<Bool>**. 
The **pure** function is responsible for *lifting* the return value of the closure into the **Maybe** type.
Well, that's easy to fix; just dispense with the **pure** function and return a plain **Bool**.
Not so fast, that won't work either, because the bind operator **>>=** expects a return type of **Maybe<T>**, not **Bool**.

**Argh**, looks like we're consigned to purgatory.

A desperate technique to escape from type-checking purgatory would look like this:

    peeps2.filter { switch $0.pet {
        case .Some(let pet) : return pet.age < 4
        case .None : return false
        }
    }

That would work, but it's ugly as hell – which is where we're destined for writing code like that. 
Thankfully, there's a way to avoid it and it requires the **maybe** function – this time implemented for the **Maybe** type.
*/
func maybe<A,B>(@autoclosure defaultValue:() -> B, opt:Maybe<A>, @noescape f:A -> B) -> B {
    switch opt {
    case .None : return defaultValue()
    case .Some(let x) : return f(x)
    }
}
//: By using the **maybe** function, the filter expression can be implemented in a reasonably sane fashion:
let p6 = peeps2.filter { maybe(false, opt: $0.pet) { $0.age < 4 } }

print("People who own pets, younger than 4 years old:\n\n\(p6)")

