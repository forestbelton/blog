---
title: Refining types
---
In [dependently typed](https://en.wikipedia.org/wiki/Dependent_type) programming, I find it's common to start with some "imprecise" type and refine it to something that contains more information. For example, I might receive a `String` from user input and want to turn that into a `Vect n Char` (for some given `n`) when I write proofs about my code:

```language-haskell
fromString : String
    -> (n : Nat ** Vect n Char)
```

Generally this refinement is accompanied by proofs that the refinement was correct. For instance, we might want to show that length is preserved:

```language-haskell
lengthPreserved : (s : String)
    -> getWitness (fromString s) = length s
```

and use this to build a copy of the refined value with the [existential](https://en.wikipedia.org/wiki/Type_system#Existential_types) unpacked:

```language-haskell
fromString' : (s : String) -> Vect (length s) Char
fromString' s = let prf = lengthPreserved s in
    rewrite sym prf in
        getProof $ fromString s
```

**Exercise**: Implement `fromString` and `lengthPreserved`.

This factorization of `fromString'` into the simpler components of `lengthPreserved` and `fromString` makes you wonder if this process can be generalized. To start off this generalization, we are looking for a function that takes `length` and the two components and produces `fromString'`:

```language-haskell
fromString' : (length : String -> Nat)
    -> (fromString : String -> (n : Nat ** Vect n Char))
    -> (lengthPreserved : (s : String) -> getWitness (fromString s) = length s)
    -> (s : String)
    -> Vect (length s) Char 
```

Generalizing the dependent pair to the `Sigma` typeclass (and making the substitution `Vect' n = Vect n Char`), we get:

```language-haskell
fromString' : (length : String -> Nat)
    -> (fromString : String -> Sigma Nat Vect')
    -> (lengthPreserved : (s : String) -> getWitness (fromString s) = length s)
    -> (s : String)
    -> Vect' (length s)
```

and we're basically there. Now, all that's left is to parameterize on our unrefined type `String`, our refined type `Vect'`, and its index the `Nat` (along with some generous renaming and re-arranging):

```language-haskell
sko : {a b : Type}
    -> { pred : b -> Type }
    -> (iexists : a -> Sigma b pred)
    -> (f : a -> b)
    -> (witness : (s : a) -> getWitness (iexists s) = f s)
    -> (s : a)
    -> p (f s)
```

Now, to figure out what this thing really is, let's turn to the [Curry-Howard interpretation](https://en.wikipedia.org/wiki/Curry%E2%80%93Howard_correspondence) of it, going parameter by parameter:

```language-haskell
iexists : a -> Sigma b t
```

If we think of `a` as an index, this describes an indexed family of existence proofs on the predicate `pred`, with witnesses taking type `a`.

```language-haskell
f : a -> b
```

`f` tells us that `a` can be interpreted as something other than an index, by relating it to `b`.

```language-haskell
(witness : (s : a) -> getWitness (iexists s) = f s)
```

Now, `f` has been related to the existence proofs by being identical to the witness over `a`. This tells us that `f` perfectly describes the witnesses of the indexed family `iexists`.

```language-haskell
(s : a) -> p (f s)
```

Given all these conditions, we can think of this as a new family of indexed proofs, except the witness has been replaced with a transformation of `f`. The existential type has been eliminated and replaced with a universally quantified type instead.

Now, whenever we want to prove that a refinement into another type has a certain property, we don't have to do it all in one go. We also don't have to worry about unpacking existentials afterwards. Curiously, this process looks a lot like [skolemization](https://en.wikipedia.org/wiki/Skolem_normal_form).
