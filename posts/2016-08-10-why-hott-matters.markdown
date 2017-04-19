---
title: Why HoTT matters
---
Equality is one of the most fundamental concepts in mathematics. But what is it? This one rule:

```
for all x, x = x.
```

If you are familiar with the concept of [relations](https://en.wikipedia.org/wiki/Binary_relation): for any given set S, the equality relation (let's call it S₌) is the least [reflexive](https://en.wikipedia.org/wiki/Reflexive_relation) relation on the set. That means for all reflexive relations R on S, S₌ ⊂ R. S₌ is also the least [symmetric](https://en.wikipedia.org/wiki/Symmetric_relation) and [transitive](https://en.wikipedia.org/wiki/Transitive_relation) relations as well, which allows equality to be generalized to [equivalence relations](https://en.wikipedia.org/wiki/Equivalence_relation).

Topics in mathematics usually play out like this:

1. Define the underlying mathematical structure.
2. Define what it means for two of these structures to be equivalent.
3. Come up with a way of deciding whether any given two structures are equivalent or not.

When conducting arguments during this process, this local concept of equivalence is often treated as if it were equality, with equivalent things being substituted with each other. How is this justified?

That's where [homotopy type theory](https://en.wikipedia.org/wiki/Homotopy_type_theory) (or HoTT) comes in. In HoTT, you are able to convert an equivalence proof into an equality proof with the so-called ["univalence axiom"](https://ncatlab.org/nlab/show/univalence+axiom), which fills in the gaps during reasoning.

But HoTT doesn't stop at logical niceties. Through a [famous isomorphism](https://en.wikipedia.org/wiki/Curry%E2%80%93Howard_correspondence), type theories are known to describe certain logics. A [dependent type](https://en.wikipedia.org/wiki/Dependent_type) theory corresponds to ["normal"](https://en.wikipedia.org/wiki/Intuitionistic_logic) [first-order logic](https://en.wikipedia.org/wiki/First-order_logic). HoTT is an extension of dependent type theory, so the logic it describes is more expressive. Given all this, it remains a possibility that mathematics itself could be encoded in this logic. If so, HoTT stands as a potential new foundation to mathematics.

With type history being [computational](https://en.wikipedia.org/wiki/Simply_typed_lambda_calculus) in nature, it's also natural to seek for HoTT to be computational as well. "The" open problem is to determine a computational meaning for the univalence axiom. Initial attempts of encoding the axiom quickly ran into issues of decidability and computational complexity. As much as I can understand it, it seems like [cubical type theory](https://www.math.ias.edu/~amortberg/papers/cubicaltt.pdf) may solve these problems.

As the relationship between type theory and logic runs deep, it's natural to build automated proof checkers using type theory. The computational nature of types provides all the necessary rules for building up a proof of a certain logical proposition. There is some excitement that formulating these proof checkers using HoTT may improve the reasoning power available. Traditionally, if you have wanted to reason about equivalent structures, you have had to use awkward structures like [setoids](https://en.wikipedia.org/wiki/Setoid).

Finally, HoTT may have an impact on programming languages as well. Some of the known consequences of HoTT include things like [quotient types](https://en.wikipedia.org/wiki/Quotient_type), which would let us construct much more fine-grained types into our program. Imagine if you have a type which represents some piece of state. Many times, multiple values in this type can represent the same equivalent piece of state. "Quotienting" this type would allow us to only focus on the truly distinct pieces when writing functions over those types.
