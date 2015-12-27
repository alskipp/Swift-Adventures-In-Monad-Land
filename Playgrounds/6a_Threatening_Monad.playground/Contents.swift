/*: 
## Threatening Monad

Previous installments have focussed on **nil**, **NilLiteralConvertible**, **Optionals** and custom **Maybe** types.
This time let's step away from the tentative world of **Optionals** and take a look at a different beast.

The **Threat** monad!

Inspiration was taken from this [Haskell blog](http://blog.sigfpe.com/2007/04/homeland-security-threat-level-monad.html).
The ideas have been adapted and extended – hopefully it'll be educational and entertaining.
The purpose of this Playground is to demonstrate a novel way of representing **tainted** values with various threat levels.

* * *

### **ThreatLevel** enum

An **enum** that represents the various threat levels.
It has an **Int** rawValue to make it easy to implement the **Comparable** protocol.
*/
enum ThreatLevel : Int, CustomStringConvertible {
    case Low = 0, Guarded, Elevated, High, Severe
    
    var description: String {
        switch self {
        case Low :      return "Low"
        case Guarded :  return "Guarded"
        case Elevated : return "Elevated"
        case High :     return "High"
        case Severe :   return "Severe"
        }
    }
}
/*:
### **Equatable** & **Comparable** protocols

Enums without associated values are **Hashable** by default, which means they are also **Equatable** by default.
To make the **ThreatLevel** enum **Comparable**, all that is required is to implement the **<** operator
and declare protocol conformance with an **extension**. As a result, the other comparison operators 
(such as **>, <=**, etc) will be available to use along with the **min** and **max** functions.
*/
func <(lhs:ThreatLevel, rhs:ThreatLevel) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

extension ThreatLevel : Comparable {}
/*:
### **Threat** struct (Monad)

The **Threat** struct below, is just a normal struct. 
It holds two values, a **ThreatLevel** and an arbitrary value of any type.
The purpose of the **Threat** struct is to associate a **ThreatLevel** with a value.

The monadic functionality can be added by implementing a **flatMap** method,
or by implementing the bind operator **>>=**. The bind operator will add less noise when chaining functions together,
so that's the route which will be taken here.
*/
struct Threat<T> : CustomStringConvertible {
    let threat:ThreatLevel
    let value: T
    
    init(_ t:ThreatLevel, _ x:T) {
        threat = t
        value = x
    }
    
    var description: String {
        return "{Threat: \(threat)} \(value)"
    }
}
//: **map** - makes it possible to apply functions to the value inside the **Threat** struct
func map<A,B>(x:Threat<A>, f: A -> B) -> Threat<B> {
    return Threat(x.threat, f(x.value))
}
//: **Monadic 'return'** - default level is **Low**
func pure<T>(x:T) -> Threat<T> {
    return Threat(.Low, x)
}
/*:
### **Bind operator for Threat struct**

We've previously seen how to implement monadic bind for the **Optional** type.
The question is: how is the **Threat** struct remotely like an **Optional**?

Well, it isn't, but the implementation of bind will be structurally the same.
Here's an example (the **M**s represent the monad type, the **A**s are the ‘wrapped’ type).

    M<A> -> (A -> M<B>) -> M<B>

If the **M**s are replaced with **Optional**, we get the function signature for **Optional bind**

    Optional<A> -> (A -> Optional<B>) -> Optional<B>

If we do the same for **Threat**, the structural similarity should be obvious

    Threat<A> -> (A -> Threat<B>) -> Threat<B>

That's what the type signature of the bind operator function will look like. Now for the implementation.
The logic of the implementation is as follows:

Bind takes two parameters, a **Threat<A>** struct and a function. The function takes a type **A**
and transforms it into a value of type **Threat<B>**. Therefore:
Extract the wrapped **value** of the **Threat<A>** parameter and pass it to the function.
The function will take the extracted **value** of type **A** and return a **Threat<B>**.

Both the first parameter **Threat<A>** and the return type of the function parameter have a
**ThreatLevel** property. The only logic that needs to be implemented is to ensure that the
highest **ThreatLevel** is attached to the return value of the bind function.
*/
infix operator >>= {associativity left}
func >>= <A,B> (t: Threat<A>, @noescape f: A -> Threat<B>) -> Threat<B> {
    let t2 = f(t.value) // apply function f – the type of t2 is Threat<B>
    
    // return a new Threat with the value from t2
    // the ThreatLevel should be the max of t & t2
    return Threat(max(t.threat, t2.threat), t2.value)
}
/*:
**A simple example of Threat struct** – Make a dangerous number
*/
let n = Threat(.High, 666)
print(n)

//:**Apply a function to the dangerous number** – the **ThreatLevel** is preserved
let n2 = map(n) { $0 * 2 }
print(n2)

/*:
That example was instructive, but not too interesting.
If an **Int** is wrapped in a **Threat** struct, it is no longer possible to treat it like a normal **Int**.
This is useful, as it prevents 'dangerous' values being inadvertantly passed around to other functions.
To apply transformations to the value, the map function must be used, which ensures the **ThreatLevel** is preserved.

To make things more interesting, let's create a new struct to work with…

* * *

### **Person** struct

A simple struct that holds values for **name**, **occupation** and **ThreatLevel**.
The default value for **ThreatLevel** is **Low**. If we're dealing with a dubious individual
they can be given an appropriate **ThreatLevel** when initialized.

To be clear, **ThreatLevel** is just a simple *enum*, it is not a monad
(the monad is the **Threat** struct – it is not used within the **Person** struct).
*/
struct Person : CustomStringConvertible {
    let name:String
    let occupation:String
    let threat:ThreatLevel
    
    init(name:String, occupation:String, threat:ThreatLevel = .Low) {
        self.name = name
        self.occupation = occupation
        self.threat = threat
    }
    
    // ThreatLevel will be displayed as a single letter abbreviation to reduce clutter
    var description: String { return "\(name) (\(occupation)) : \(threat.description.characters.first!)" }
}
/*:
## Risk Assessment

Given a **Person** struct containing a **ThreatLevel** property, what use can be made of it?
Well, we can set-up an insidious surveillance state that tracks the **ThreatLevel** of groups of people.

There's a very simple rule that applies: 
the **ThreatLevel** of a group of people is equal to the **ThreatLevel** of the most dangerous individual within the group.

If a benign, low-risk group receives a new member whose **ThreatLevel** is **Severe**, the risk level of the group become **Severe**.
If a group with a **ThreatLevel** of **Elevated** receives a new member with a **ThreatLevel** of **Low**, 
the group level retains its **Elevated** rating.

#### **How to represent a group of people?**

One option would be to create a custom *class* or *struct* that would represent a group of people with a mutable **Array** property
and keep track of the **ThreatLevel** with a mutable property which is implicitly updated when the people Array is mutated.

But as we've went through the palaver of defining a **Threat** struct with a monadic bind operation, let's use it.

#### **State & Immutability?!**

By utilising the **Threat** struct, it will be possible to keep track of groups of people and their **ThreatLevel**
without the use of mutable state and implicit side effects. How will this work? Our groups of people will be
represented simply as arrays **[Person]** and the **ThreatLevel** tracking will be achieved by wrapping the Array
in a **Threat** monad.

We'll need one function responsible for adding a **Person** to an array and returning a **Threat<[Person]>**.

* * * 

The implementation is very simple: given a **Person** and an **Array**, return a **Threat<[Person]>**.
A **Threat<[Person]>** struct needs to be intialized with two parameters, a **ThreatLevel** and a **Person Array**.
The first parameter is taken directly from the supplied **Person** by accessing their **threat** property 
and the second parameter is the result of adding the **Person** to the supplied **Array**.
*/
func addPerson(person:Person)(_ list:[Person]) -> Threat<[Person]> {
    return Threat(person.threat, list + [person])
}
/*:
The only unusual thing about the above function is that it is defined to be explicitly **curried**.
The reason for this will become clear when we chain function calls together.
The two parameters to the function require two function applications to return the final result:

    addPerson(person, array) // WON'T work
    addPerson(person)(array) // WILL work – curried function application

**What's the use of currying?**

We'll be using the **addPerson** function in conjunction with the bind operator **>>=**.
In fact we'll be passing the **addPerson** function as a parameter to **>>=**.
The function type must match the type expected by the bind operator, which is:

    A -> Threat<T>

If the **addPerson** function was defined normally, it's type would be as follows:

    (B, A) -> Threat<T>

That doesn't match the required type, so it can't be used with the bind operator.
But if the function is curried, we can supply the first parameter and get a new function back in return.
The returned function matches the type we need (A -> Threat<T>):

    B -> (A -> Threat<T>)

If that all seems like gibberish, don't worry, examples will be presented shortly.
First of all, let's add a **person** to a list to get started.

* * *

#### **Adding a *Person* to an empty list**

Quite simply call the function with the first parameter (**Person**), 
(the return value will be a new function expecting an **Array**). Pass an empty **Array**.
The return value of the expression will be **Threat<[Person]>**.
*/
let mediumRisk = addPerson(Person(name: "Bob", occupation: "Wrestler", threat: .Elevated))([])
print(mediumRisk)

/*:
#### **Adding a *Person* to a pre-populated list – *the wrong way***

We have created a *mediumRisk* **Threat<[Person]>** struct by adding a **Person** 
(Bob, Wrestler, ThreatLevel=Elevated) to an empty **Array**.

A new **Person** can be added to the **Array** by using the *addPerson* function again. 
We can add to the current **Array** by extracting it from the **Threat<[Person]>** struct
and passing it as the second argument to the **addPerson** function.

This time we'll add a less dangerous **Person** to the list, an Artist with a **Low ThreatLevel**.
*/
let mellow = addPerson(Person(name: "Jeff", occupation: "Artist", threat: .Low))(mediumRisk.value)
print(mellow)

/*:
The return value is another **Threat<[Person]>** struct. As the last person added was deemed low risk,
the **ThreatLevel** of the **Threat** struct is also **Low**. However, this is undesirable. The previous **ThreatLevel**
was **Elevated** because the list contained a potentially dangerous wrestler. It's not out of the question that the artist
may have mellowed the wrestler and made him less agitated. But the safe approach is to assume the artist has become dangerous 
and learnt a few wrestling moves, so the **ThreatLevel** should remain **Elevated**.

The correct way to achieve this is to use the monadic bind operator **>>=** to add new people to the list.
The bind operator for **Threat** structs takes two parameters, a **Threat<A>** and a function
(the return value of the function is **Threat<B>**). The bind operator ensures that the highest **ThreatLevel**
is preserved when returning the new value.

#### **Adding a *Person* to a pre-populated list – *the correct way***
*/
let correct = mediumRisk >>= addPerson(Person(name: "Jeff", occupation: "Artist", threat: .Low))
print(correct)

/*:
This time we get the correct response. How did that work?

The bind function **>>=** is an infix operator, which means that it takes two parameters,
the first is on the left-hand-side, the second is on the right-hand-side of the operator.

The first parameter is the **mediumRisk** variable, its type is **Threat<[Person]>**,
the second parameter is the function **addPerson**, it is partially applied with it's first argument **Person**.
The function type of **addPerson** after receiving it's first argument is:

    [Person] -> Threat<[Person]>

The bind operator **>>=** is responsible for applying the value, **Threat<[Person]>** to the function,
**[Person] -> Threat<[Person]>** and returning a new **Threat<[Person]>**.

The bind operator can be very easily chained together to add several people, one after the other.

* * *

### Create a safe group of people

It's possible to create a **Low ThreatLevel** group by chaining together several calls of 
the **addPerson** function using **>>=** with **Low ThreatLevel** individuals:
*/
let safeGroup = addPerson(Person(name: "Iris", occupation: "Author"))([])
            >>= addPerson(Person(name: "Mark", occupation: "Botanist"))
            >>= addPerson(Person(name: "Valentina", occupation: "Cosmonaut"))

print(safeGroup)

/*:
Now let's add a dubious character to the safeGroup to see what the result is:
*/
let dodgy = safeGroup >>= addPerson(Person(name: "Gideon", occupation: "MP", threat: .Elevated))
print(dodgy)

/*:
As expected by adding one dubious individual (with an **Elevated ThreatLevel**) to the group,
the **ThreatLevel** of the group also becomes **Elevated**.

* * *

Below, we create a mixed group of people with varying **ThreatLevels**, 
the **ThreatLevel** of the entire group matches the highest **ThreatLevel** of the individual people – 
it doesn't matter what order the people are added to the group.
*/
let dangerGroup = addPerson(Person(name: "Jean", occupation: "Thief", threat: .Guarded))([])
              >>= addPerson(Person(name: "Lucy", occupation: "Juggler", threat: .Severe))
              >>= addPerson(Person(name: "Beth", occupation: "PsychoKiller", threat: .High))
              >>= addPerson(Person(name: "Ada", occupation: "Programmer")) // threat: .Low

print(dangerGroup)

/*:
## Tracking group allegiances

Our happy surveillance state is running smoothly. We can track the activities of individuals joining groups
and keep the populace quiescent with collective punishment every time an undesirable individual joins a group.

But what happens when two groups of people join together? How do we ascertain their **ThreatLevel**?
Well the logic is simple, maintain the highest **ThreatLevel** when one group joins another.

* * * 

**Adding two groups of people – *the wrong way***
*/
let mergedGroupA = map(safeGroup) { s in s + dangerGroup.value }
print(mergedGroupA)

/*:
Well that's no use. Having merged a group of low risk people with a bunch of dangerous psychokillers and jugglers,
we've ended up with a **ThreatLevel** of **Low**; society will crumble. What went wrong?

Using the **map** function seems sensible, it allows us to perform a transformation function while maintaining the **ThreatLevel**.
The problem is that the transformation function is adding two groups together, the only way of doing so using **map** is to
extract the second group from its **Threat** struct (discarding its associated **ThreatLevel**) and adding the two **Arrays**.
The **ThreatLevel** of the first group is maintained and applied to the result of the merged groups, but the **ThreatLevel**
of the second group is not taken into consideration.

* * *

**Adding two groups of people – *the right way***
*/
let  mergedGroupB = safeGroup >>= { s in dangerGroup >>= { d in pure(s + d) } }
print(mergedGroupB)

/*:
That gave the correct result, but the code looks a little scary. What's happening?

The **map** function is inadequate to add two groups of people. The **ThreatLevel** of both groups needs to be preserved
to calculate the correct return value. The way of achieving this is to use the bind operator in a nested fashion.
We bind into one group, passing a function which in turn binds into the second group, the second bind operation
takes a function which then combines the two bound values. The return value of the whole expression needs to be **Threat<T>**,
the **pure** function is used to take the result of adding the two **Arrays** and returning a **Threat<[Person]>** value.

* * *

It's possible to simplify the code by introducing another top-level function for combining monadic values.
If we were using Haskell, this function would be available to use for any monadic type.
Unfortunately it is not (yet) possible to inform Swift's type system that a particular type is monadic,
which means that we need to manually create the following function for every monadic type : (
*/
func liftM<A,B>(m1:Threat<A>, m2:Threat<A>, @noescape f:(A,A) -> B) -> Threat<B> {
    return m1 >>= { x in m2 >>= { pure(f(x, $0)) } }
}
/*:
The **liftM** function allows us to apply a *normal* function to two monadic values and to get a monadic value back in return.
This means we can now add two groups of people wrapped up in **Threat** monads very simply:
*/
let mergedGroupC = liftM(safeGroup, m2: dangerGroup, f: +)
print(mergedGroupC)

/*:
### **Tea Time**

Every benevolent dictator deserves tea time after a hard day surveilling the populace.

What have we achieved with our **Threat** monad? We have the ability to track the changing **ThreatLevel**
of groups of people as new members join and as groups join together – all without the use of any mutable state. 
Pretty impressive.
*/
