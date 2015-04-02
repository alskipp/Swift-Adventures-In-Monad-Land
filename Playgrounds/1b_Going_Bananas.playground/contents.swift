/*:
## Let's go bananas

*NilLiteralConvertible* is not just for **Optionals**.
However, having said that, you need a very good reason to adopt the protocol.
A fruity cautionary tale is presented below.

* * *

Let's define a **Banana** – it'll be an *enum* with one case.
A **Banana** *enum* with one case is neither useful nor dangerous.
*/
enum 🍌 {
    case 🍌
}
//: Make our **Banana** *Printable*
extension 🍌 : Printable {
    var description: String { return "🍌" } // these bananas are all identical
}
/*:
With a little help from *NilLiteralConvertible*, we can introduce some danger.
For convenience a plain *init()* method will also be added, enabling a **Banana** to be created with 🍌()
*/
extension 🍌 : NilLiteralConvertible {
    init() { self = 🍌 }
    init(nilLiteral: ()) { self = 🍌 }
}
//: Let's create a **Banana** – nothing too interesting yet
let b = 🍌()
println(b)
/*:
## We are now entering the *Twighlight Zone*

**Things start getting peculiar when we compare a *Banana* to *nil***
*/
🍌() == nil
/*:
## How can 🍌 be equal to *nil?*

**The answer:** It isn't!

Banana is not actually tested for equality with nil!
**nil** never exists after compilation. What actually happens is that the **nil** is replaced with a **Banana.**
This is what is evaluated:
    
    🍌() == 🍌()
    true // it has to be!
*/
🍌() == 🍌() // true (obviously)
/*:
**I can sense your scepticism!**

Maybe if a **Banana** is created from **nil** you'll be convinced?
*/
let banana:🍌 = nil
println(banana)
/*:
**That's nothing! Let's create a whole box of *Bananas* from thin air**

First, we need an empty box of **Bananas**
*/
var bananaBox:[🍌] = []
//: Now let's add nothing to the box 100 times
for b in 1...100 {
    bananaBox.append(nil)
}
println(bananaBox)

/*: 
## **Now that's magic!**

Well, it isn't actually. It's quite obvious when you think about it.
**Banana** is *NilLiteralConvertible*, therefore, Swift will happily replace all instances of **nil**
with a **Banana**, as long as the type checker is satisified. You can't, for example, assign **nil**
to a variable without type annotations and expect it to become a **Banana**:

    let b = nil // will not compile and will not become a Banana!
    let b:🍌 = nil // the type checker said, "let there be a Banana", and there was.

* * *

**A final word of caution: Don't try this at home!**

* * *

So, what was the point of this curious incident with *self-generating-Swift-Bananas?*
It was to show that **nil** and **Optionals** are not synonymous concepts.
**nil** can become any type of value (if the type is *NilLieralConvertible), in practice
the **nils** in your program will become **Optionals**, if they become **Bananas**, you're
doing something terribly wrong.

*/
