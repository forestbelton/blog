---
title: Fixed points of GADTs
---
Consider a basic language containing integer and boolean literals along with addition. The first approach to modeling this language could be a type like the following:

```language-haskell
data Exp
    = I Int
    | B Bool
    | A Exp Exp
```

with terms such as `I 10`, `B True`, `A (I 5) (I 6)`, and so on. Since this is a language, we will want to end up writing some interpreters for it, such as the following function to pretty-print a term:

```language-haskell
pprint :: Exp -> String
pprint (I i)   = show i
pprint (B b)   = show b
pprint (A l r) = "(" ++ pprint l ++ " + " ++ pprint r ++ ")"
```

The kind of recursion being performed here can be expressed easily as a [catamorphism](https://en.wikipedia.org/wiki/Catamorphism), so let's go ahead and generalize it out. We'll use the language of [F-algebras](https://www.schoolofhaskell.com/user/bartosz/understanding-algebras), introducing a new type parameter `a` and replacing all of the recursive references with it.

```language-haskell
newtype Fix f = Fix { unFix :: f (Fix f) }

cata :: Functor f => (f a -> a) -> Fix f -> a
cata h = h . fmap (cata h) . unFix

data ExpF a
    = I Int
    | B Bool
    | A a a
    deriving (Functor)

type Exp = Fix ExpF
```

Then, we can restate our pretty-printer without doing explicit recursion:

```language-haskell
pprint :: Exp -> String
pprint = cata go
    where go (I i)   = show i
          go (B b)   = show b
          go (A l r) = "(" ++ l ++ " + " ++ r ++ ")"
```

But what happens when we want to write an evaluator for our language? The existence of the `B` constructor "messes everything up" - we can't just implement `eval :: Exp -> Int` because not all of our terms will evaluate to an integer. Enter [GADTs](https://en.wikipedia.org/wiki/Generalized_algebraic_data_type):

```language-haskell
data Exp a where
    I :: Int                -> Exp Int
    B :: Bool               -> Exp Bool
    A :: Exp Int -> Exp Int -> Exp Int
```

Now, the `Exp` type is indexed by the type of the expression it represents, so now we can implement a well-typed evaluator:

```language-haskell
eval :: Exp a -> a
eval (I i)   = i
eval (B b)   = b
eval (A l r) = eval l + eval r
```

But now we're back to where we've started in terms of expressing recursive functions. Must we really implement our recursion manually for _every_ GADT we define?

As you might have guessed from the title, the answer is no! We can find fixed points of GADTs in a way that is very similar to the recursive ADTs we are used to.

## Constructing `HFix`

We can't simply replace every recursive reference with a new type parameter `a` of kind ★ &mdash; since `Exp` is indexed by a type, we would lose the fact that the argument to the constructor should also be indexed by a type. Instead, let's introduce a new type parameter `f :: * -> *`, which will allow us to retain the indexed type:

```language-haskell
data ExpF a f where
    I :: Int   ->          ExpF Int  f
    B :: Bool  ->          ExpF Bool f
    A :: f Int -> f Int -> ExpF Int  f
```

Now we need an analogue to `Fix` that works for this kind of type. The kind of `ExpF` is `* -> (* -> *) -> *`, and our output should be the same kind as our original `Exp`, so we want a type of kind `(* -> (* -> *) -> *) -> (* -> *)`.

```language-haskell
newtype HFix h a = HFix { unHFix :: h a (HFix h) }

type Exp a = HFix ExpF a
```

Just like in `Fix`, we instantiate the last type parameter of our input to the fixed-point type, recursively tying the knot. To build up an `Exp a`, we just apply `HFix` after applying each constructor from `ExpF`. Some examples of such terms include `HFix $ I 1` and `HFix $ A (HFix $ I 2) (HFix $ I 2)`.

It's getting rather unwieldy to construct terms of our language, so let's go ahead and define some smart constructors which use `HFix` for us:

```language-haskell
i :: Int -> Exp Int
i x = HFix $ I x

b :: Bool -> Exp Bool
b x = HFix $ B x

a :: Exp Int -> Exp Int -> Exp Int
a l r = HFix $ A l r
```

These aren't necessary to perform our evaluation, but would come in handy in a real-life implementation scenario.

## Catamorphisms

Now that we have a fixed-point representation of our data type, we need an analogue of `cata` for types of this kind. Recall the type of cata:

```language-haskell
cata :: Functor f => (f a -> a) -> Fix f -> a
```

Since `Exp` can't be a  `Functor`, we will need a higher-order analogue that fills the same role. Instead of changing our `a`, however, we will want to change `f`:

```language-haskell
class HFunctor h where
    hmap :: (f a -> g a) -> h a f -> h a g
```

With a `HFunctor`, we can lift a [natural transformation](https://en.wikipedia.org/wiki/Natural_transformation) `f a -> g a` into a map over `h`. We can implement `HFunctor` for `ExpF` easily:

```language-haskell
instance HFunctor ExpF where
    hmap m (I x)   = I x
    hmap m (B x)   = B x
    hmap m (A l r) = A (m l) (m r)
```

Now, we should be able to express our analogue `cataH`. With `cata`, the caller is able to choose what the folding function is, along with the carrier type `a`. Continuing the analogy, in `cataH` we will be able to choose the carrier **functor** `f`:

```language-haskell
cataH :: HFunctor => (h a f -> f a) -> HFix h a -> f a
cataH m = m . hmap (cataH m) . unHFix
```

The definition of `cataH` is identical to our previous definition of `cata`, modulo the choices of typeclass and fixed-point operator. This should give us some confidence that the definition is correct.

Finally, let's define evaluation for our new fixed type:

```language-haskell
eval :: Exp a -> a
eval = cataH go
    where go (I i)   = i
          go (B b)   = b
          go (A l r) = l + r
```

And we're done! If your type can be a `HFunctor`, you can use `cataH` to perform catamorphisms over it. This same approach can be generalized to types of other kinds in a very similar fashion.
