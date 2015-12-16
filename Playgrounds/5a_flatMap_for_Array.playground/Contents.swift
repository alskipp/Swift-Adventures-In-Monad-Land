/*:
## flatMap for Array

If you've explored the previous Playgrounds, you should now have a reasonable understanding of monadic bind **>>=**
as it relates to **Optionals**. The bind operator is simply one way of performing a monadic computation,
there's also the **flatMap** method which can achieve the same result.

This exploration of monadic bind for **Array** will make extensive use of the **flatMap** method,
but it's still important to understand how the function works as an infix operator.
If we take a look at the function signature for **Optional** monadic bind, it is easy to see what the version for **Array** should look like.

    (Optional<A>, (A -> Optional<B>)) -> Optional<B>

Simply replace **Optional** with **Array**:
    
    (Array<A>, (A -> Array<B>)) -> Array<B>

The types of the function reveal how the function should be implemented.
Given an **Array<A>** and a function type of **A -> Array<B>** return a value of **Array<B>**.
There's really only one sensible way to implement this:

We can not simply apply the function **A -> Array<B>** to every element of **Array<A>**, as a nested **Array<Array<B>>** will be produced.
The return type needs to be **Array<B>**. If we use the **map** function, we'd need to somehow flatten the **Array** before returning the result,
alternatively, we could use a mutable **Array** and update it within a loop, or we could use the **reduce** function, as follows.
*/
infix operator >>= {associativity left}
func >>= <A,B>(x: [A], f: A -> [B]) -> [B] {
    return x.reduce([]) { result, item in result + f(item) }
}
/*:
Here's a simple test to show that the function works as expected.
For every **Int** in an **Array**, return an **Array** containing the **Int** and its successor.
*/
let successors = [1,10,50,100] >>= { [$0, $0+1] }
print(successors)

/*:
**The flatMap method**

Swift 1.2 added the **flatMap** method to the **Array** type.
The only difference between the **flatMap** method and bind is that the method only needs one parameter (a function from **A -> [B]**),
which is applied to **self**. The bind operator requires an explicit first parameter of **[A]**.

    >>= (x: [A], f: A -> [B]) -> [B]
    flatMap     (f: A -> [B]) -> [B]

* * *

Rather than focus on the abstract qualities of **flatMap** for **Array**, it'll be more interesting to tackle a ’real‘ coding challenge.
A problem involving performing calculations on **Arrays**, what better way than…

## **Monadic stocktaking for Squirrels**

This particular problem will obviousy require nuts. Here we go:
*/
enum Nut: CustomStringConvertible {
    case Acorn, Hazel, Chestnut, Cashew
    
    var description: String { // boring boilerplate
        switch self {
        case .Acorn :    return "Acorn"
        case .Hazel :    return "Hazel"
        case .Chestnut : return "Chestnut"
        case .Cashew :   return "Cashew"
        }
    }
}
/*:
Cashews are a little unusual for a squirrel, but a typical London squirrel does not restrict its diet to things growing
in local trees - discarded packets can be bountiful.

Squirrels need to stash their nuts somewhere to keep them safe, so we'll also need a **Cache** struct that contains a **Position**
and an **Array** of **Nuts**. The **Position** measures the distance in metres (using x,y coordinates) from the squirrels’ house
(or drey, if you insist on using correct squirrel nomenclature).
*/
typealias Position = (x:Float, y:Float)

struct Cache {
    let location:Position, nuts:[Nut]
}
/*:
Finally the beast itself – a **Squirrel**. Each **Squirrel** has a name and an **Array** of **Caches**
*/
struct Squirrel {
    let name:String, caches:[Cache]
}
/*:
## Create a gang of **Squirrels**
*/
let fred = Squirrel(name: "Fred", caches: [
    Cache(location: (104, -20),
        nuts: [.Acorn, .Acorn, .Chestnut, .Cashew]),
    Cache(location: (87, 45),
        nuts: [.Hazel, .Chestnut])])

let bob = Squirrel(name: "Bob", caches: [
    Cache(location: (-12, 15),
        nuts: Array(count: 12, repeatedValue: .Cashew))])

let jane = Squirrel(name: "Jane", caches: [
    Cache(location: (-36, -96),
        nuts: Array(count: 10, repeatedValue: .Acorn)),
    Cache(location: (212, 4),
        nuts: [.Chestnut, .Chestnut, .Hazel])])

let bertha = Squirrel(name: "Bertha", caches: [
    Cache(location: (24, -164),
        nuts: Array(count: 8, repeatedValue: .Acorn)),
    Cache(location: (-129, 10),
        nuts: [.Acorn, .Hazel, .Hazel, .Hazel, .Chestnut]),
    Cache(location: (27, -16),
        nuts: [.Hazel, .Hazel, .Chestnut])])


let squirrels = [fred, bob, jane, bertha]

/*:
## **Nut stock taking**

To determine whether our intrepid **Squirrels** will make it through the harsh winter months we need to do some stocktaking.
How many **Nuts** does the whole gang have between them? Let's gather together all the **Nuts** to find out.
To do so, each **Squirrel** needs to consult its list of **Caches** and gather up the **Nuts** in each **Cache**.

* * *

An imperative approach: Create a mutable Array, iterate through the various structures, appending items to the **Array**.
*/
var nuts:[Nut] = []
for sqrl in squirrels {
    for cache in sqrl.caches {
        for nut in cache.nuts {
            nuts.append(nut)
        }
    }
}
print(nuts)

/*:
This works as expected, but the same result can be acheived without the need of a mutable **Array**.
The first tool to reach for when replacing loops and mutable vars with a functional approach is **map**.
*/
let nutsMap = squirrels.map { sqrl in sqrl.caches.map { cache in cache.nuts } }
print(nutsMap)

/*:
Using the **map** function doesn't give the most helpful result.
We end up with a nested **Array** for each **Squirrel** and a nested **Array** of **Nuts** for each **Cache**.
What's really required is a flattened **Array** containing all the **Nuts**.
A perfect use case for **flatMap**:
*/
let nuts1 = squirrels.flatMap { sqrl in sqrl.caches }.flatMap { cache in cache.nuts }
print(nuts1)

/*:
That's the result we wanted, though it would be better if some of the procedure was abstracted away to simplify the operation.
One way to do this is to extend the **Squirrel** type with a **computed property** that returns all the **Nuts** in its possession.
*/
extension Squirrel {
    var nuts: [Nut] {
        return self.caches.flatMap { cache in cache.nuts }
    }
}
/*:
Now we can gather all the **Nuts** from all the **Squirrels** a little easier:
*/
let nuts2 = squirrels.flatMap { sqrl in sqrl.nuts }
print(nuts2)

/*:
An alternative approach would be to add a top-level function that serves the same purpose.
*/
func nuts(squirrel:Squirrel) -> [Nut] {
    return squirrel.caches.flatMap { cache in cache.nuts }
}

let nuts3 = squirrels.flatMap(nuts)
print(nuts3)

/*:
That last example is a little simpler because a top-level function can be passed directly to **flatMap**.
Whereas, when using a method or a computed property with **flatMap**, the method/property needs to be called from inside a closure,
using either the anonymous argument **$0**, or by naming the parameter.

* * *

It has been mentioned on the Apple Developer forum, by Chris Lattner,
that methods should be preferred over top-level functions in Swift.
One advantage of methods is that they are easy to discover using code completion.
Top-level functions require users to have a more in-depth knowledge of the code base.

It might be preferable to use top-level functions in specific cases if your code makes
extensive use of higher order functions (map, flatMap, reduce, etc).

* * *

For our stocktaking purposes, it would be useful to know what types of **Nuts** and the quantity that the **Squirrels**
have been gathering. The **Squirrel** type can be extended to add the desired functionality:
*/
extension Squirrel {
    func nutsOfType(nut:Nut) -> [Nut] {
        return self.nuts.filter { n in n == nut }
    }
}
/*:
Let's put this new functionality through its paces.
We can now ask a **Squirrel** to return **Nuts** of a specific type:
*/
let chestnuts = jane.nutsOfType(.Chestnut)
print(chestnuts)

//: By using **flatMap**, it's easy to return all the **Nuts** of a specific type from every **Squirrel**:
let allChestnuts = squirrels.flatMap { $0.nutsOfType(.Chestnut) }
print(allChestnuts)

//: To return the number of **Nuts** rather than the **Nuts** themselves, simply **count** the return value:
let acornCount = squirrels.flatMap { $0.nutsOfType(.Acorn) }.count
print("Number of acorns: \(acornCount)")

/*:
Just as it was possible to define the **nuts** function as a top-level function as opposed to a method/computed value,
it is perfectly possible to do the same for the **nutsOfType** function:
*/
func nutsOfType(squirrel:Squirrel, nut:Nut) -> [Nut] {
    return nuts(squirrel).filter { $0 == nut }
}

let acornCount2 = squirrels.flatMap { nutsOfType($0, nut: .Acorn) }.count
print("Number of acorns: \(acornCount2)")

/*:
That worked, but it's actually more verbose and uglier than using a **computed property** on the **Squirrel** struct.

* * *

## Curried functions == happier higher order functions

There's another way of writing the top-level **nutsOfType** function which will make it far more pleasant to use with **flatMap**.
It will require switching the order of the parameters and currying the function.

A *normal* function requires that all arguments be supplied together in one operation,
the function is then evaluated and a value can be returned. A *curried* function takes its arguments one by one.
Upon receiving an argument, a function is returned that takes the remaining parameters as arguments.
A new function is returned for every argument, until the final argument is supplied,
then the whole expression will be evaluated and a value can be returned.

This is what the **curried** function looks like:
*/
func nutsOfType(nut:Nut)(squirrel:Squirrel) -> [Nut] {
    return nuts(squirrel).filter { $0 == nut }
}
//: By supplying the first argument, a new function is returned:
let acornsOnly = nutsOfType(.Acorn)
/*: 
The *acornsOnly* function is a **partially applied function**.
Which means that previously supplied arguments are captured within the context of the function.
When the final argument is received, the whole expression can be evaluated, as if all the arguments were given together.
*/
let fredsAcorns = acornsOnly(squirrel: fred)
print("Fred’s Acorns: \n\(fredsAcorns)")

/*:
It should now be clearer why the order of the parameters to the **nutsOfType** function were flipped.
It means we can create a partially applied function, then let **flatMap** supply values of type **Squirrel**.
For example, here's how to use **flatMap** with the **acornsOnly** function:
*/
let acornCount3 = squirrels.flatMap(acornsOnly).count
print("Number of acorns: \(acornCount3)")

/*:
It is not necessary to create a new named function for use with **flatMap**, the curried function can simply be partially applied in place.
*/
let acornCount4 = squirrels.flatMap(nutsOfType(.Acorn)).count
print("Number of acorns: \(acornCount4)")

/*:
### **method/function comparison**

Ultimately, you need to decide when it's best to use methods or top-level functions.
My personal preference is for top-level functions when using **flatMap** and other higher order functions.
It's a subtle difference, but the top-level, curried function is arguably the more elegant.
Using a method with **flatMap** isn't any easier to read, it simply adds extra syntactic noise.
*/
//: Using a method call
let hazels1 = squirrels.flatMap { $0.nutsOfType(.Hazel) }.count
//: Using a top-level function
let hazels2 = squirrels.flatMap(nutsOfType(.Hazel)).count

/*:
### Until next time…

There are far more monadic/flatmappy things that can be done with our gang of **Squirrels**.
More will be revealed in the next instalment.
*/
