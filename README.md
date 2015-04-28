Swift Adventures In Monad Land
========

Question: Is it vital to understand the concept of Monads to program in Swift?

Answer: No.

* * *

But it's an interesting topic nonetheless and if you tinker with Swift enough you'll find yourself doing monadic things, perhaps without realising.

The purpose of this repository is to explore concepts relating to the 'M' word in Swift. The ideas are developed from talks I gave at [Swift London Meetup](http://www.meetup.com/swiftlondon/) and [Swift Summit](https://www.swiftsummit.com) and are presented as Xcode Playground files. The video of my Swift London talk (Swift and Nothingness) can be found [here.](https://skillsmatter.com/skillscasts/6203-swift-and-nothingness)

Playgrounds
---

NOTE: Xcode 6.3.1 or higher is recommended.

###### 1a ) I See No Nil

The weird world of nil in Swift.

###### 1b) Going Bananas

A cautionary tale about self-generating Swift bananas.

###### 2a) Maybe Type

How to implement the Optional type.

###### 2b) Maybe Type Monad

The monad is revealed.

###### 3a) Optional Madness

When Optionals go Bad!

###### 4a) Three Binds are Better than One

You're looking for one Optional bind, then three turn up at once.

###### 5a) flatMap for Array

**TODO:** Why should Optionals get all the fun?

###### 6a) Threatening Monad

Beginners guide to managing an oppressive surveillance state.

* * *

So, what is a ‘Monad’ anyway? (Don't expect a straight answer)
---

It's traditional to make an obscure analogy about what a monad is, but in a slight deviation from tradition, here's an analogy about why the question is difficult to answer. It's similar to asking, ‘What is a mammal?’. There are many instances of mammals in the world and there are also the ‘laws’ which define the attributes of a mammal. Here are some of the ‘laws’ according to wikipedia:

> Mammals are a clade of endothermic amniotes distinguished from reptiles and birds by the possession of hair, three middle ear bones, mammary glands, and a neocortex (a region of the brain).

Furnished with just this information, it is unlikely you'd be able to point at an actual instance of a mammal and would probably resort to the follow-up question, ‘So, what's a mammal?’

The equivalent, abstract answer to, ‘What is a monad?’, might be:

> A monad is a monoid in the category of endofunctors, what's the problem?
>
>> [A Brief, Incomplete, and Mostly Wrong History of Programming Languages](http://james-iry.blogspot.co.uk/2009/05/brief-incomplete-and-mostly-wrong.html)

An entertaining, yet enigmatic answer. In practice, it's not too complicated. At the heart of a monad there is the ‘bind’ operation, which is simply a higher order function. But, what's a higher order function?…

* * *

Rather than start from the abstract concept, an alternative approach is to sneak up on actual instances of mammals and monads in the wild and study how they behave. That's the approach which will be taken here.

In Swift, the monad you will first confront in the wilderness is the **Optional** type. That's why *Swift Adventures in Monad Land* will start with an investigation of **nil**, **NilLiteralConvertible** and **Optionals**. Despite the fact that there is no requirement to know that Optionals are monads to make use of them in Swift (just as it's not a requirement to know that a donkey is a mammal to get it to till your field), attaining knowledge of the true nature of your Optional or donkey can be both useful and rewarding.
