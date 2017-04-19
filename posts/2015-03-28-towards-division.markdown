---
title: Towards division
---

One of my pet projects is [cooper](https://github.com/forestbelton/cooper), a formally verified quantifier elimination procedure for formulas in [Presburger arithmetic](http://en.wikipedia.org/wiki/Presburger_arithmetic) written in [Idris](http://www.idris-lang.org/). It's nowhere near being done, but I've made some progress on it lately that I'd like to share.

Most of my recent work has been on constructing a decision procedure for the quantifier-free fragment of the theory. Once I've eliminated the quantifiers from formulae, I can then apply this procedure to construct the desired proof (or disproof).

The most difficult part of this fragment was constructing decision procedures for the divisibility predicates. The straightforward approach would be to perform division and inspect the remainder, so I set off with that goal. This post details the implementation of the division algorithm I came up with.

---

__NOTE__: I've omitted several proofs for the sake of brevity. Their code can either be implemented by the reader or found in the repo under `Internal/Division.idr`, depending on your personal level of masochism.

---

The division theorem states that given two integers $a$, $b$ there exist unique integers $q$, $r$, such that

$$
a = bq + r
$$

and $0 \leq r < \left|b\right|$. I'm going to assume that the inputs are nonnegative, which simplifies the inequality to $0 < r < b$.

First we define a type to support the result of the division. This includes the quotient, remainder, and the accompanying proofs.

```language-haskell
data Div : Nat -> Nat -> Type where
	mkDiv : (q, r : Nat)
    -> a = b * q + r
    -> LT r b
    -> Div a b
```

To compute a value of type `Div a b`, we start with the guess $q = 0, r = a$ (which trivially satisfies $a = bq + r$) and keep refining our guess until we have a proof that $r < b$. I got tired of passing all of this information around, so I made an extra type to wrap up one step of computation.

```language-haskell
data DivStep : Nat -> Nat -> Nat -> Type where
	mkDivStep : (q : Nat)
    -> a = b * q + r
    -> DivStep a b r
```

For our first guess, we need to construct a `DivStep a b a`. This means that we need a value `prf : a = b * 0 + a`, which is easy enough to write:

```language-haskell
firstGuess : (a, b : Nat) -> DivStep a b a
firstGuess a b = mkDivStep 0 prf
    where prf = rewrite (multZeroRightZero b) in Refl
```

At each step, there are two cases we have to handle. Either we have `LT r b` and we're done, or we have `GTE r b` and we need to compute a new guess. Focusing on the second case, we need a function with the following type:

```language-haskell
nextGuess : DivStep a b r
    -> GTE r b
    -> (r' : Nat ** DivStep a b r')
```

The result needs to be wrapped in a dependent sum, because otherwise we have no way of introducing the new remainder into the type signature.

We can refine our guess in the following way:
$$
\begin{align\*}
a &= bq + r \\\\
&= b(q + 1 - 1) + r \\\\
&= b(q + 1) - b + r \\\\
&= b(q + 1) + (r - b)
\end{align\*}
$$

Since we know that $b \leq r$, the expression $r - b$ will also be a natural number. Stated more conveniently, there exists a value $c : \text{Nat}$ such that $r = b + c$. In the language of type theory, that means we have a function of the following type:

```language-haskell
subtract : LTE b r -> (c : Nat ** r = b + c)
```

Thus the implementation of `nextGuess` ends up looking like this:

```language-haskell
nextGuess (mkDivStep q prf) gtePrf =
	let (r' ** addPrf) = subtract gtePrf in
    	(r' ** mkDivStep (S q) ?nextGuessPrf)
```

where `?nextGuessPrf` mimics the refinement argument given above. 

The only thing left at this point is to combine the two cases together, producing a recursive algorithm:

```language-haskell
divStep : DivStep a b r -> Div a b
divStep (mkDivStep q prf) {r} = case eitherLTorGTE r b of
	Left prf1  => mkDiv q r prf prf1
    Right prf2 =>
    	let (r' ** guess) = nextGuess prf2 (mkDivStep q prf) in
        	divStep guess
```

Which can then be wrapped up with a helper routine to kick off the recursion:

```language-haskell
divide : (a, b : Nat) -> Not (0 = b) -> Div a b
divide a Z contra     = void $ contra Refl
divide a (S k) contra = divStep $ firstGuess a (S k)
```

---

#### Final thoughts
Careful readers will note that `divStep` fails the totality check in Idris. This is because the checker can't determine that the argument in the recursive call is structurally smaller than the one passed in.

To get around this, I (ab)used the built-in `assert_smaller`. There are more reasonable techniques, such as [well-founded recursion](http://adam.chlipala.net/cpdt/html/GeneralRec.html), which are outside the scope of this article.

The uniqueness portion of the proof was also skipped, due to not being necessary for my purposes.
