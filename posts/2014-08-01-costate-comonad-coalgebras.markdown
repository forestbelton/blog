---
title: Costate comonad coalgebras
---
Every now and then you hear that lenses are actually just "costate comonad coalgebras".

```language-haskell
data State s a = State (s -> (a, s))
```

The State monad we all know and love. Given a state `s`, produce a value `a` and a new `s`.

```language-haskell
data Store s a = Store (s -> a) s
```

The Store type, which is dual to State. It's sometimes called CoState. The idea of this type is that we take a "piece" out of our `a` value of type `s`. We also give a way to insert the `s` back into `a`, making it whole again.

```language-haskell
instance Functor (Store s) where
  fmap f (Store p x) = Store (f . p) x
```

If we have a way to turn an `a` into a `b`, then we can essentially consider the `s` to be a piece of `b` as well.

```language-haskell
fmap id (Store p x)
= Store (id . p) x
= Store p x
```

Thus `fmap id = id`, making sure that `Store s` is actually a Functor. [The second Functor law is redundant](https://github.com/quchen/articles/blob/master/second_functor_law.md), so we don't have to prove it.

```language-haskell
instance Comonad (Store s) where
  extract (Store p x)   = p x
  duplicate (Store p x) = Store p' x
    where p' s = Store p s
```

To extract the whole value of the Store, simply apply the piece to the builder. To duplicate it, we construct a modified Store to return a `Store s a` when it becomes whole again. Since `s` is arbitrary, our only choice is to just use the one we've given. Our building function has to construct a Store, so we just pass it the `s` we're given and use the builder from the original Store.

```language-haskell
extract (duplicate (Store p x))
= extract (Store (\s -> Store p s) x)
= (\s -> Store p s) x
= Store p x
```

Thus `extract . duplicate = id`.

```language-haskell
fmap extract (duplicate (Store p x))
= fmap extract (Store (\s -> Store p s) x)
= Store (\s -> extract (Store p s)) x
= Store (\s -> p s) x
= Store p x
```

Thus `fmap extract . duplicate = id`.

```language-haskell
duplicate (duplicate (Store p x))
= ... -- Fill in later (AKA, exercise left to reader)
= fmap duplicate (duplicate (Store p x))
```

Thus `duplicate . duplicate = fmap duplicate . duplicate`, and we have shown that `Store s` satisfies all of the Comonad laws.

```language-haskell
type Coalgebra f a = a -> f a
```

For a given Functor `f` and type `a`, a map `a -> f a` is known as an F-coalgebra. If the Functor is a Comonad and the map preserves the comonadic structure, then this is known as a comonad coalgebra.

```language-haskell
type Lens s a = Coalgebra (Store s) a
              = a -> Store s a
              = a -> (s -> a, s)
```

So there you have it: a Lens gives us a way to take a value and form a Store out of it. For a more detailed look, see [Relating Algebraic and Coalgebraic Descriptions of Lenses](http://www.cs.ox.ac.uk/jeremy.gibbons/publications/colens.pdf) by Jeremy Gibbons and Michael Johnson.
