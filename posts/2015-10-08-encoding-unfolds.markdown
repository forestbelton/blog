---
title: Encoding unfolds
---
Folds are a pretty big deal. I've [written](http://homolo.gy/in-search-of-a-generalized-fold/) a [lot](http://homolo.gy/church-encoding/) about them in the past. One thing I haven't covered, however, is their sister: the [unfold](https://en.wikipedia.org/wiki/Anamorphism), or anamorphism.

In [Data.List](https://hackage.haskell.org/package/base-4.8.1.0/docs/Data-List.html#v:unfoldr) there is the unfoldr function, which has the following type:

```language-haskell
unfoldr :: (b -> Maybe (a, b)) -> b -> [a]
```

This function can be thought of as a very simple state machine. You pass in the initial `b` state, and for each iteration you feed the current state into the supplied function. If the result is `Nothing`, we're done. Otherwise, we have an `a` along with a new state `b`. It should be clear how repeated application can generate a list.

**Exercise:** Implement `unfoldr`.

However, viewed under the lens of fixed points, the type signature of `unfoldr` is a bit deceptive. Recall the definition of `ListF`:

```language-haskell
data ListF a b = NilF | ConsF a b
```

But this type is actually isomorphic to `Maybe (a, b)`! This is given by the following isomorphism:

```language-haskell
to :: ListF a b -> Maybe (a, b)
to NilF        = Nothing
to (ConsF a b) = Just (a, b)

from :: Maybe (a, b) -> ListF a b
from Nothing = NilF
from (Just (a, b)) = ConsF a b
```

This means that we can rewrite the type of `unfoldr` to use `ListF a b` instead of `Maybe (a, b)`.

```language-haskell
unfoldr :: (b -> ListF a b) -> b -> [a]
```

Now, recalling that `[a] ~ Fix (ListF a)`, we can start to see the true generality of the unfold come out:

```language-haskell
unfoldr :: (b -> ListF a b) -> b -> Fix (ListF a)
```

Of course, as with `cata`, the only thing we truly need to assume about `ListF a` is that it is a `Functor`. So we end up with this new function:

```language-haskell
ana :: Functor f => (b -> f b) -> b -> Fix f
ana h = Fix . fmap (ana h) . h
```

The type signature of `ana` is different from `cata` in two ways:
 
 * The `f b -> b` has been flipped to `b -> f b`
 * `b` and `Fix f` have been flipped
 
This corresponds to the fact that `ana` and `cata` are duals in a precise categorical sense that I won't go into.

Encoding
------

`ana` is a very handy function to use any time a list is being built up inductively. But `cata` seems somehow more special: any value of a data type can be uniquely represented as a fold on the value itself. Is there a similar representation property for unfolds?

For the case of lists, the question is answered (at least somewhat) positively. Recall that when encoding a list as a fold, we "partially apply" the list value and leave everything else free. Here, we will do the opposite: we will supply the builder function and the seed value, but not the list itself. I chose `Int` for `b` for reasons that will become clear soon.

```language-haskell
type List1 a = (Int -> Maybe (a, Int), Int)
```

Decoding the list is as easy as simply calling unfold:

```language-haskell
decode :: List1 a -> [a]
decode (f, n) = unfoldr f n
```

But how do we encode an arbitrary list? Well, we can use the `Int` to describe the length of the list. When it reaches 0, we know that there are no more elements in our list to produce. Given a list encoded in this way, all we have to do to is increment the `Int` and wrap the current builder function with one that produces the supplied value as our new head.

```language-haskell
encode :: [a] -> List1 a
encode []    = (const Nothing, 0)
encode (h:t) = (go, n + 1)
  where (f, n) = encode t
        go x = if x == n + 1
                   then Just (h, n)
                   else f x
```

Encoding a list and decoding it again will certainly produce the same list. (**Exercise:** why?) However, if we go in the other direction &mdash; that is, decode a list, and then encode it &mdash; we could very well end up with a different value than what we had before. `encode xs` only describes one particular method of encoding `xs`; there are plenty others. This process can be generalized to other (recursive) data types, but extra data will have to be included proportional to the number of constructors and their arguments.

Conclusion
---

There's still one more interesting duality that I'd like to mention. If you have a fold on a data type, e.g. a list, the type signature looks like this, modulo some equivalences:

```language-haskell
foldr :: b -> (a -> b -> b) -> [a] -> b
      :: (() -> b) -> (a -> b -> b) -> [a] -> b
      :: (() -> b, a -> b -> b) -> [a] -> b
```

That is, it takes a *product* of destructors, a built-up value, and produces a *destroyed* result. Now, if we think about unfolds the same way, we get:

```language-haskell
unfoldr :: (b -> Maybe (a, b)) -> b -> [a]
        :: (b -> ListF a b) -> b -> [a]
```

which takes a (function to a) *coproduct* of constructors, a seed value, and produces a built-up result. I think there's a more precise way of stating this. Maybe the answer is to use the language of [final coalgebras](https://en.wikipedia.org/wiki/F-coalgebra), but I'm not sure.

**Exercise:** Figure this out for me :)
