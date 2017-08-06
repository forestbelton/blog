---
title: The power of parametricity
---
[Parametric poymorphism](https://en.wikipedia.org/wiki/Parametric_polymorphism)
is a common theme in typed functional programming. It is sometimes shortened to
just "polymorphism", but we will refrain in this article due to [a conflicting definition](https://en.wikipedia.org/wiki/Subtyping)
in an object-oriented context.

In everyday programming, we often deal with concrete types like strings and
integers. Introducing parametric polymorphism allows us to write functions that
operate over any type, not just a specific one. This helps to promote code reuse,
allowing programmers to write a few generic functions instead of many specialized ones.

One way to view a generic function is that it takes in one or more types as parameters
along with the normal parameters. For instance, consider the [identity function](https://en.wikipedia.org/wiki/Identity_function):

```language-haskell
{-# LANGUAGE ExplicitForAll #-}

id :: forall a. a -> a
id x = x
```

`id` can be seen as a function in 2 arguments. The first argument is a type
named `a` and the second is a value of type `a`. There's just no reason to explicitly represent
the type as an argument to the function because we cannot manipulate types at the term level.

We are quite limited in the number of operations we can perform on values of
a generic type. Since the type is not constrained in any way, it is only possible
to use the value in one of the following ways:

* return the value as-is
* discard the value
* apply a generic function to the value

This seems very restricting, but it enables us to come to very strong conclusions
about what these generic values look like.

### What's in a type?

Let's play a game. In this game, I give you the type of an expression, and you
classify all the different values of that type. The goal is to be specific
as possible, with the best answer uniquely characterizing all of the values. We will ignore any
"tricky" values like `undefined` and only consider ground terms.

For example, suppose I gave you the type `Bool`. `Bool` has two possible values
which uniquely define it: `True` and `False`. If I gave you an arbitrary value
of type `Bool`, you would know that it must be one of these two. Any type that
is a regular [ADT](https://en.wikipedia.org/wiki/Algebraic_data_type) will be
easy to describe in a similar manner.

The situation gets a lot more complicated when function types become involved.
How do you classify the type `Int → Int`? This type contains "simple" values like
the [successor function](https://en.wikipedia.org/wiki/Successor_function), but also
functions which can be extraordinarily complex. As an example, consider the following
function:

```language-haskell
c :: Int → Int
c 1                  = 1
c n | n `mod` 2 == 0 = c $ n `div` 2
    | otherwise      = c $ 3 * n + 1
```

It is currently an [open problem](https://en.wikipedia.org/wiki/Collatz_conjecture)
whether this function even terminates at all. It seems our game quickly becomes
intractable as we start to make the types even slightly more complicated.

### Less is more

What if we try to classify `forall a. a → a`? Any implementation is limited
by the three available operations listed above, and must evaluate to a value
of type `a`. This leaves the identity function as the only possible implementation.
Paradoxically, by knowing less about our type, we can say more about what functions
over that type do.

What can we say about the following type?

```language-haskell
f :: forall a. a → a → a
```

Unlike before, there is more than one possible implementation. This corresponds
to the fact that we can now choose whether to evaluate to the first or second
argument of the function. Thus, the two implementations are `\x y → x`
and `\x y → y`.

By induction we can show that any function which accepts `n`
values of type `a` and evaluates to an `a` has `n` possible implementations.
The `i`th implementation corresponds to the function which evaluates to its
`i`th parameter. Since you can form an isomorphism between two types that have
the same number of inhabitants, this provides a way to [encode](/posts/2014-07-07-church-encoding.html)
values of finite types into a generic function.

A final example involves functions over tuples. Consider the type:

```language-haskell
f :: forall a. (a, a) → (a, a)
```

Functions of this type can either leave the tuple intact or flip the first and
second values. We can show that for a generic function over `n`-tuples, there
are `n!` possible implementations. Each implementation corresponds to a permutation
of the original tuple.

### Counting is hard

Generalizing further, we can show that a function from n-tuples to m-tuples
(where $m \leq n$) has [n choose m](https://en.wikipedia.org/wiki/Binomial_coefficient)
possible implementations. Other formulas exist involving generic functions in
more than one type parameter &mdash; try to figure some out!

While we have restricted our analysis to combinatoric methods, there are other
results that come from parametricity. In the paper [Theorems for free!](https://people.mpi-sws.org/~dreyer/tor/papers/wadler.pdf),
Philip Wadler describes even stronger "theorems" that every polymorphic type must satisfy.
This allows him to derive results about familiar functions such as [map](https://en.wikipedia.org/wiki/Map_%28higher-order_function%29) and [fold](https://en.wikipedia.org/wiki/Fold_%28higher-order_function%29).
