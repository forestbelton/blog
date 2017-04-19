---
title: Theorem proving in Haskell
---
After playing around with ATS for a bit, I switched to [Idris](http://www.idris-lang.org) as my dependently typed language of choice. Using dependent types is still a fairly new thing for me, so even writing basic code was very illuminating. How much of this knowledge can I bring back to Haskell?

```language-haskell
{-# LANGUAGE DataKinds #-}

data Nat = Z | S Nat
```

__Note:__ I'll be introducing language extensions as I use them instead of piling everything in at the beginning.

First, let's define the usual type for natural numbers. The presence of the `DataKinds` extensions means that `Nat` has been lifted to a kind and both `Z` and `S` have been lifted to value constructors. This will let us use `Z` and `S` in type signatures, which is where the meat of the code will end up.

```language-haskell
{-# LANGUAGE GADTs, KindSignatures #-}

data LTE (a :: Nat) (b :: Nat) where
  LteZero :: LTE Z b
  LteSucc :: LTE a b -> LTE (S a) (S b)

```

`LTE a b` is a type for the proposition $a \leq b$. An inhabitant of the type `LTE a b` is a proof that `a` is less than or equal to `b`. The type constructors for `LTE a b` define what it means to be less than or equal to. `a` and `b` are restricted to the `Nat` kind using the `KindSignatures` extension. This prevents people from saying nonsense like `LTE Int Char`.

We define `LTE a b` inductively:

* `LteZero` &mdash; 0 is less than or equal to all other numbers.
* `LteSucc` &mdash; If $a <= b$, then $a + 1 \leq b + 1$.

Now let's try to prove a simple theorem, such as $\forall n. n \leq n$. This is represented by the type `LTE n n`. This will require use of the induction hypothesis, so it's a little unclear in how to formulate it. We can't write a simple function to do it, because that would require pattern matching on values rather than types.

```language-haskell
class LteNN n where
  lteNN :: LTE n n
```

If a type `n` is an instance of `LteNN`, then there is a proof that $n \leq n$. We can now define an instance for the base case, `LteNN Z`:

```language-haskell
instance LteNN Z where
  lteNN = LteZero
```

Since `LteZero :: LTE Z b` unifies with `LTE Z Z`, this completes the base case.

```language-haskell
instance LteNN n => LteNN (S n) where
  lteNN = LteSucc lteNN
```

The constraint in this instance corresponds to the induction hypothesis. If we have a proof that $n \leq n$, we can produce a proof that $n + 1 \leq n + 1$ by simply applying `LteSucc`. The proof that $n \leq n$ is represented here by `lteNN :: LTE n n`.

We now have instances `LteNN Z, LteNN (S Z), LteNN (S (S Z)), ...` for all of the naturals, thus completing the proof.

As the complexity of the proposition increases, so does the complexity of the corresponding Haskell code. Since Haskell doesn't have dependent types, you quickly fall into extensions like `TypeFamilies` and wonder what all those injectivity errors mean. Using a language like Idris, Coq, Agda, Epigram, etc. makes these things far easier to state and prove.

For reference, here is the equivalent code in Idris. Note that typeclass resolution is replaced by dependent pattern matching.

```language-haskell
data LTE' : Nat -> Nat -> Type where
    LteZero : LTE' Z b
    LteSucc : LTE' a b -> LTE' (S a) (S b)

lteNN : (n : Nat) -> LTE' n n
lteNN Z     = LteZero
lteNN (S k) = LteSucc (lteNN k)
```
