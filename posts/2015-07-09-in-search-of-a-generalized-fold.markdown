---
title: In search of a generalized fold
---
Writing a fold for a custom data type is a fairly mechanical process. This hints that there is some common shape to a fold that we can abstract over. Since a fold is just the recursion principle for a data type, this will essentially let us decouple the recursion from the folding computation itself.

Consider the normal list data type, defined like so:

```language-haskell
data List a = Nil | Cons a (List a)
```

If you replace the recursive argument with an extra type parameter, we have removed the explicit recursion from the data structure:

```language-haskell
data ListF a b = Nil | Cons a b
```

How can we recover the original recursive definition from this type? If we attempt to simply substitute, we end up with something like `ListF a (ListF a (ListF a ...))`, continuing on infinitely. But we can't have infinite types, so this won't work.

```language-haskell
newtype Fix f = MkFix { unFix :: f (Fix f) }
```

`Fix f` represents an f-wrapped value `f (f (f ...))`. `Fix (ListF a)` would give us the `ListF a (ListF a (ListF a ...))` we want. Since `MkFix` is applied inductively, we don't have to worry about actually constructing an infinite type.

How do we produce a `f (Fix f)` so that we can pass it to `MkFix`? In general, we can pass all of our value constructors that don't refer to the recursive argument directly to `MkFix`. This coincides with the fact that they are the base cases of any recursive function on the data type. For `ListF`, note that `Nil :: ListF a b`. If we let `b = Fix (ListF a)`, then the types work out for `Fix` and we can produce `MkFix Nil :: Fix (ListF a)`. From `MkFix Nil`, we can construct `MkFix $ Cons 1 (MkFix Nil)`, etc. as desired.

**Exercise:** Implement the two following functions and prove that they are inverses of one another:

```language-haskell
fromListF :: Fix (ListF a) -> [a]
toListF :: [a] -> Fix (ListF a)
```

**Exercise:** What type is `Fix Maybe` isomorphic to?

Now that the recursive data types have been encoded using `MkFix`, all that's left is to encode the recursive folds that act on them. Again, the definitions we provide won't have any explicit recursion in them, leaving that for the generic recursion function we write later. We will make one assumption when writing our fold: the recursive argument has been replaced with the result of the recursive call already made for us.

Compare the two implementations of `length` on lists. The first version is the normal recursive implementation, while the second is our non-recursive version for ListF:

```language-haskell
length :: List a -> Int
length Nil        = 0
length (Cons _ t) = 1 + length t
```

```language-haskell
lengthF :: ListF a Int -> Int
lengthF Nil        = 0
lengthF (Cons _ l) = 1 + l
```

Our non-recursive version looks very similar, but instead of the second argument to Cons representing the tail of the list, it represents _the result of lengthF applied recursively to the tail_. Therefore, we can just take the value and add one to it.

_Aside_: For the next section, we'll want to go ahead and make a `Functor` instance for `ListF a`. You can either implement this by hand or use GHC's `DeriveFunctor` extension. Why this is necessary will become clear once we use it.

Suppose we want to run `lengthF` on a `Fix`-encoded list. We have a `ListF a Int -> Int`, a `Fix (ListF a)`, and we want an `Int` back. Based off of that information, our function should look something like:

```language-haskell
makeRecursive :: (ListF a Int -> Int) -> Fix (ListF a) -> Int
makeRecursive f (MkFix x) = case x of
  Nil      -> f Nil
  Cons h t -> f $ Cons h (makeRecursive f x)
```

Since there is only one constructor for `Fix f`, we only have one case to pattern match on. However, once we've unpacked the `MkFix` constructor, we have two cases: one for each in `ListF a b`. In the `Nil` case, we don't have any extra information, so we can just apply `f` to `Nil`. Note that the `Nil` we are applying `f` to has a different type from what we matched on. In the `Cons` case, we have an `a` and a `Fix (ListF a)`. This is where the recursion comes in, so naturally the only thing we can do is a call to `makeRecursive`.

How can this be generalized? Looking at the argument we are passing to `f`, it's clear that we are mapping `x`, which is a `ListF a (Fix (ListF a))`, to a `ListF a Int`. We are doing this using a function `Fix (ListF a) -> Int`, so this is really just an `fmap` operation.

```language-haskell
makeRecursive :: (ListF a Int -> Int) -> Fix (ListF a) -> Int
makeRecursive f (MkFix x) = f $ fmap (makeRecursive f) x
```

But this definition isn't relying on anything specific about `Int` or `ListF` &mdash; it only assumes that we have a `Functor` instance. Generalizing the type, we have:

```language-haskell
makeRecursive :: Functor f => (f b -> b) -> Fix f -> b
makeRecursive f (MkFix x) = f $ fmap (makeRecursive f) x
```

This function is usually called `cata` (for "catamorphism"). After renaming and conversion to point-free form, we end up with the final definition:

```language-haskell
cata :: Functor f => (f b -> b) -> Fix f -> b
cata f = f . fmap (cata f) . unFix
```

**Exercise:** Convert the following data type to one usable by `Fix`:

```language-haskell
data Tree a = Leaf | Branch a (Tree a) (Tree a)
```

**Exercise:** Write a function using `cata` on the data type from the previous exercise called `depth` that computes the depth of the tree.
