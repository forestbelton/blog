---
title: Reflection in Idris
---
Instead of proving everything by hand, sometimes we would like to produce proofs of certain propositions automatically. It seems reasonable to think that we can do this for any class of propositions for which a decision procedure exists. However, we don't necessarily want to extend the language itself &mdash; errors in our extension could mess everything up.

Proof by reflection is one way to write a verified procedure within the language itself. Reflection lets us convert a piece of the program into a data structure in Idris itself; we can manipulate it like we would any other (this is very similar to Lisps in some regard). By analyzing the structure of the proof goal itself, we can automatically derive a term of the goal's type.

`LTE m n` is a relatively simple type which represents less-than-or-equal-to propositions. It would be great to be able to produce a value of, say, `LTE 10 15` at compile time! Traditionally, if the value is computed automatically, it will be wrapped in a type like `Dec` or `Maybe`, which you then have to do case analysis on. You can always write out the value manually, but who wants to write `LTESucc (LTESucc (LTESucc ...))`? Below, I'll detail two different methods for producing these proofs automatically.

Method 1
------

We already have a decision procedure `isLTE` for computing whether `LTE m n` is inhabited or not in the standard library, so we just need a way to safely unpack this value.

```language-haskell
data IsYes : Dec p -> Type where
  ItIsYes : IsYes (Yes prf)

getYes : (x : Dec p) -> IsYes x -> p
getYes (Yes prf) ItIsYes = prf
getYes (No _) ItIsYes impossible
```

By providing only a constructor for the `Yes` case, the `IsYes` type lets us pack up a proof that we indeed have a value of form `Yes x` for some x and `getYes` lets us extract x itself.

```language-haskell
%reflection
reflectLTE : (P : Type) -> Dec P
reflectLTE (LTE m n) = isLTE m n
```

The `%reflection` annotation tells Idris to treat the arguments to this function as syntax rather than as values. This lets us pattern match on the syntax itself. The actual meat of this function is rather simple! Note that this function is not total.

```language-haskell
syntax LTEProof = quoteGoal x by id in
	getYes (reflectLTE x) ItIsYes
```

`quoteGoal foo by f in bar` takes the quoted goal, applies `f` to it, and then introduces it as `foo` in the expression `bar`. Since we don't need to do anything special to the quoted form, we just apply `id`.

By calling `getYes` on our result and passing in `ItIsYes`, we are forcing the typechecker to try and figure out that our term is actually in the form we want. If the typechecker cannot figure it out, then this will fail at compile-time. We can use our new syntax as follows:

```language-haskell
lte5_10 : LTE 5 10
lte5_10 = LTEProof
```

And trying to construct a proof of proposition gives an error like so:

```language-haskell
When elaborating right hand side of lte10_5:
When elaborating an application of function Main.getYes:
        Can't unify
                IsYes (Yes prf)
        with
                IsYes (reflectLTE x)

        Specifically:
                Can't unify
                        Yes prf
                with
                        No (succNotLTEzero . fromLteSucc . fromLteSucc .
                            fromLteSucc .
                            fromLteSucc .
                            fromLteSucc)
```

Error messages with this approach are not very friendly! Maybe with David Christiansen's [Reflect on Your Mistakes!](http://www.itu.dk/people/drc/drafts/error-reflection-submission.pdf) this can be made better, but unfortunately I haven't investigated that yet.

Method 2
------

The second approach is inspired by section 4.1 in Paul van der Walt's [Reflection in Agda](http://dspace.library.uu.nl/handle/1874/256628). We construct an LTE predicate which is either the unit or empty type if the proposition is true or false, respectively.

```language-haskell
lte' : Nat -> Nat -> Type
lte' Z k         = ()      -- 0 ≤ k
lte' (S k) Z     = Void    -- ¬(k + 1 ≤ 0)
lte' (S k) (S l) = lte k l -- k ≤ l → k + 1 ≤ l + 1
```

If `lte' n o` maps to the empty type, then a value `x : lte' n o` can produce anything we want via false elimination. Using this allows us to write the approach with a normal function:

```language-haskell
LTEProof' : (m, n : Nat) -> lte' m n -> LTE m n
LTEProof' Z     k     ()  = LTEZero
LTEProof' (S k) Z     prf = absurd prf
LTEProof' (S k) (S l) prf = LTESucc $ LTEProof' k l prf
```

But this method is a little annoying as-is; we have to pass in all of our arguments, including the proof `lte' m n`, explicitly. This is where implicit arguments come in handy. By specifying the type signature as:

```language-haskell
LTEProof' : {m, n : Nat} -> {auto prf : lte' m n} -> LTE m n
```

We can force the type-checker to figure out these arguments for us. The `auto` keyword tells the compiler to try and produce a value using the `trivial` tactic. After the necessary modifications, our function ends up looking like this:

```language-haskell
LTEProof' : {m, n : Nat} -> {auto prf : lte' m n} -> LTE m n
LTEProof' {m=Z}   {n=k}         = LTEZero
LTEProof' {m=S k} {n=Z}   {prf} = absurd prf
LTEProof' {m=S k} {n=S l} {prf} = LTESucc $ LTEProof' {m=k} {n=l} {prf}
```

Using `LTEProof'` is identical to the first approach:

```language-haskell
lte5_10 : LTE 5 10
lte5_10 = LTEProof'
```

However, error messages look a little nicer this time around:

```
When elaborating argument prf to function Main.LTEProof':
        Can't solve goal
                lte' 10 5
```

Conclusion
-------

Both methods are effective at producing proofs automatically. The first approach takes more footwork to write and has unforgiving error messages upon failure. However, the ability to inspect the quoted syntax is far more powerful than the technique used in the second approach, and will likely come in handy for more complicated examples. Think about your problem domain before you decide which to use!
