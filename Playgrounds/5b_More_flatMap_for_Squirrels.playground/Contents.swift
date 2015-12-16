/*:
## flatMap for Array – part 2

The previous Playground introduced **flatMap** for **Array** using calculations involving **Squirrels**.
We're not finished with the **Squirrels**, **Nuts** and **Caches** just yet, so here they are:
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
//: Some calorie info will be very useful
func calories(nut:Nut) -> Int {
    switch nut {
    case .Acorn :    return 15
    case .Hazel :    return 10
    case .Chestnut : return 25
    case .Cashew :   return 10
    }
}
/*:
* * *
*/
typealias Position = (x:Float, y:Float)

struct Cache {
    let location:Position, nuts:[Nut]
}
/*:
* * *
*/
struct Squirrel {
    let name:String, caches:[Cache]
    
    var nuts: [Nut] {
        return self.caches.flatMap { cache in cache.nuts }
    }
    
    func nutsOfType(nut:Nut) -> [Nut] {
        return self.nuts.filter { n in n == nut }
    }
}

func nuts(squirrel:Squirrel) -> [Nut] {
    return squirrel.caches.flatMap { cache in cache.nuts }
}

func nutsOfType(nut:Nut)(squirrel:Squirrel) -> [Nut] {
    return nuts(squirrel).filter { $0 == nut }
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
## **Nut stock taking** – recap

Last time we managed to create a few functions that could be used with **flatMap** to perform calculations on our data (Squirrels).
The use of top-level curried functions enabled us to write succinct and elegant code.
Here are a couple of examples from last time:
*/
let allChestnuts = squirrels.flatMap(nutsOfType(.Chestnut))
print(allChestnuts)

let acornCount = squirrels.flatMap(nutsOfType(.Acorn)).count
print("Number of acorns: \(acornCount)")

/*:
**More stocktaking calculations with Squirrels**

This time we'll expand the number of calculations we can perform, using **flatMap** with top-level functions.
The pipe forward operator **|>** will also be introduced, along with the **minBy** & **maxBy** functions.
But first, Swift doesn't have built-in functions for **sum** and **average**, so let's create them.
They'll be very useful.
*/
func sum(x:[Int]) -> Int {
    return x.reduce(0, combine: +)
}

func average(x:[Int]) -> Float {
    return Float(sum(x)) / Float(x.count)
}
/*:
## **Cache Statistics**

So far the focus has been on acquiring information about the number and types of nuts that our group of squirrels have accumulated.
Equally important is the ability to gather statistics about the nut caches:

* Calculate the distance to caches
* Which is the nearest, or furthest?
* Which is the most bountiful in nutty provisions?
* Where can the nearest Acorns be found?

All of the above questions will require the use of **flatMap**.

* * *

Let's extend the **Cache** type to conform to the *CustomStringConvertible* protocol.
*/
extension Cache: CustomStringConvertible {
    func countNutsOfType(nut:Nut) -> Int {
        return self.nuts.filter { $0 == nut }.count
    }
    
    var description: String {
        let acorns = countNutsOfType(.Acorn)
        let hazels = countNutsOfType(.Hazel)
        let chestnuts = countNutsOfType(.Chestnut)
        let cashews = countNutsOfType(.Cashew)
        
        return "location: \(location) { acorns: \(acorns), hazels: \(hazels), chestnuts: \(chestnuts), cashews: \(cashews) }"
    }
}
/*:
A top-level curried function **nutsOfType** that takes a **Cache** as an argument will be needed.
This is an overloaded function (meaning that there is already a function with this name,
however, the other version takes a **Squirrel** as an argument, not a **Cache**).
*/
func nutsOfType(nut:Nut)(cache:Cache) -> [Nut] {
    return cache.nuts.filter { $0 == nut }
}
/*:
A top-level function to calculate the distance to a **Cache**
*/
import Foundation // needed for sqrt function
func distance(cache:Cache) -> Float {
    return sqrt(cache.location.x * cache.location.x + cache.location.y * cache.location.y)
}
/*:
It should now be an easy task to take an **Array** of **Squirrels** and calculate the distance to the closest **Cache**.
*/
let closestCacheDistance = squirrels.flatMap { $0.caches }.map(distance).minElement()
print("Distance to closest Cache: \(closestCacheDistance)m")

/*:
There's a distinct problem here. The answer is correct, but the code is lacking clarity.
The problem is that although much of the expression reads nicely from left to right, the final function **minElement**
needs to wrap the entire expression and ruins the flow of the code.
It would be much better if **minElement** could be placed at the end of the whole expression.

* * *

## **pipe forward operator** (‘beaky’ operator?)

With the introduction of a new *infix operator* the flow of the code will be a lot easier to follow.
The left-hand side of the operator takes a value of type **A**, the right-hand side takes a function of type **A -> B**.
The *pipe forward operator* simply applies the function to the value:
*/
infix operator |> {associativity left precedence 95}
func |> <A,B>(x:A, f:A -> B) -> B {
    return f(x)
}
/*:
***pipe forward operator* in action**

The **minElement** function can now be applied at the end of the expresssion.
*/
let closestCacheDistance2 = squirrels
                           .flatMap { $0.caches }
                           .map(distance)
                           |> { $0.minElement() }

print("Distance to closest Cache: \(closestCacheDistance2)m")

let mostNuts = squirrels
              .flatMap { $0.caches }
              .map {$0.nuts.count}
              |> { $0.maxElement() }

print("Number of nuts in biggest cache: \(mostNuts)")

let avgNuts = squirrels
             .flatMap { $0.caches }
             .map {$0.nuts.count}
             |> average

print("Average number of nuts in cache: \(avgNuts)")

let allCals = squirrels
             .flatMap { $0.caches }
             .flatMap {$0.nuts}
             .map(calories)
             |> sum

print("Total calories in caches: \(allCals)")

let hazelWithin50m = squirrels
                    .flatMap { $0.caches }
                    .filter { distance($0) < 50 && $0.nuts.contains(.Hazel) }

print("Hazel nuts within 50m: \n\(hazelWithin50m)")

let noChestnuts = squirrels
                 .flatMap { $0.caches }
                 .filter { ($0 |> nutsOfType(.Chestnut)).count == 0 }

print("Caches containing no Chestnuts: \n\(noChestnuts)")

/*:
### **reduce1** function

This function is inspired by Haskell's **foldl1**.
It is similar to the normal **reduce** function, accept that an initial value is not required.
The return type is also dictated by the contents of the **Array** that is being reduced.
The Haskell version of this function is unsafe to use on an empty list, this is not the case
for the Swift version below, as the return type is an **Optional**. 
If an empty **Array** is passed to the function the return value will be **.None**.

* * *

Use **first** to take the first element of the supplied **Array**. The return value of **first** is an **Optional**.
Therefore use **map** on the return value of **first** - if the **Array** is empty the whole expression will return **.None**.
If the **Array** isn't empty the normal **reduce** function will be called using the first element as the initial value.
*/
func reduce1<A>(f:(A,A) -> A)(_ xs:[A]) -> A? {
    return xs.first.map { x in
        xs[1..<xs.endIndex].reduce(x, combine: f)
    }
}

[1,2,3,4] |> reduce1(*) // yay, it works

/*:
### **minBy** & **maxBy** functions

Using **reduce1** it is now possible to implement **minBy** & **maxBy**.
The idea is to be able to select the min or max element from an **Array** based upon any property of the elements.
*/
func minBy<A,B:Comparable>(f:A -> B)(xs:[A]) -> A? {
    return xs |> reduce1 { x,y in f(x) < f(y) ? x : y }
}

func maxBy<A,B:Comparable>(f:A -> B)(xs:[A]) -> A? {
    return xs |> reduce1 { x,y in f(x) > f(y) ? x : y }
}
/*:
### **minBy** & **maxBy** in action
*/
let closestCache = squirrels
                  .flatMap { $0.caches }
                  |> minBy(distance)

print("Closest Cache: \n\(closestCache)")

let paltryCache = squirrels
                 .flatMap { $0.caches }
                 |> minBy { $0.nuts.count }

print("Cache containing fewest nuts: \n\(paltryCache)")

let mostCals = squirrels
              .flatMap { $0.caches }
              |> maxBy { $0.nuts.map(calories) |> sum }

print("Cache with most calories: \n\(mostCals)")

let abundantHazels = squirrels
                    .flatMap { $0.caches }
                    |> maxBy { $0 |> nutsOfType(.Hazel) |> { $0.count } }

print("Cache containing most Hazels: \n\(abundantHazels)")

let closestAcorns = squirrels
                   .flatMap { $0.caches }
                   .filter { ($0 |> nutsOfType(.Acorn)).count > 0 }
                   |> minBy(distance)

print("Nearest cache containing Acorns: \n\(closestAcorns)")

/*:
## **Squirrel Ranking**

It's a harsh life being a squirrel. If you spend too much time eating discarded chips by the boating lake
and not enough time foraging for nuts, you'll get in trouble with the squirrel boss - whoever that is?

What does this harsh taskmaster demand to know? How about the following:

* Who is the most avid collector of acorns? 
* Who has collected the fewest nuts?
* Who has the most nut caches? 
* Who has the most distant cache?

All these questions and more can be answered by combining the functions we've created.

* * *

First, let's extend **Squirrel** to be **CustomStringConvertible**.
The **curry** function below is used to curry the **joinWithSeparator** function when constructing a *description* **String**.
*/
func curry<A,B,C>(f:(A,B) -> C) -> A -> B -> C {
    return { a in { b in f(a,b) } }
}

extension Squirrel: CustomStringConvertible {
    var description: String {
		let cachesString = caches.map { $0.description } |> curry({ $1.joinWithSeparator($0) })("\n")
        
        return "\(name)\n\(cachesString)"
    }
}
/*:
Now we can finally interrogate some squirrels to see who is pulling their weight.
*/
let topSquirrel = squirrels |> maxBy { $0.nuts |> { $0.count } }

print("Top nut gatherer: \n\(topSquirrel)")

let lazySquirrel = squirrels |> minBy { $0.nuts |> { $0.count } }

print("Laziest squirrel: \n\(lazySquirrel)")

let acornHunter = squirrels |> maxBy { $0 |> nutsOfType(.Acorn) |> { $0.count } }

print("Squirrel with most acorns: \n\(acornHunter)")

let mostCaches = squirrels |> maxBy { $0.caches.count }

print("Squirrel with most Caches: \n\(mostCaches)")
/*:
### **Next time:**

If you're fed up with **Squirrels**, it's my unfortunate duty to inform you that there'll be one more outing for this preposterous example.
Next time, we'll take it up another level, completely off-piste with function composition, it'll be great, honest.
*/
