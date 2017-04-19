---
title: Church encoding
---
It's possible to represent data types purely as functions. For example, consider the following type:

```language-haskell
data What = Foo | Bar | Baz
```

Ignoring undefined, `What` has three inhabitants given by the three nullary value constructors. This can be represented via the *Church encoding* as follows:

```language-haskell
type What1 = forall b. b -> b -> b -> b
```

`What1` also has 3 inhabitants, due to parametricity of b: a function of type `What1` must evaluate to one of its three arguments. The mapping between these two types is given by the following two functions:

```language-haskell
to :: What -> What1
to Foo = \x y z -> x
to Bar = \x y z -> y
to Baz = \x y z -> z

from :: What1 -> What
from f = f Foo Bar Baz
```

Note that to extract a value of type `What` back out, all you have to do is pass in the value constructors.

What happens when the data constructor is not nullary?

```language-haskell
data Where = Location String | Nowhere
```

It seems plausible to take all the instances of the type in the signature and just replace them with `b`. Then, to construct the encoded version, we use `String -> b` for Location and `b` for Nowhere. Thus:

```language-haskell
type Where1 = forall b. (String -> b) -> b -> b

to :: Where -> Where1
to (Location s) = \f x -> f s
to Nowhere      = \f x -> x

from :: Where1 -> Where
from f = f Location Nowhere
```

What about a unary type constructor? Modulo newtypes, everything is more of the same:

```language-haskell
type Maybe1 a = forall b. (a -> b) -> b -> b

to :: Maybe a -> Maybe1 a
to (Just s) = \f x -> f s
to Nothing  = \f x -> x

from :: Maybe1 a -> Maybe a
from f = f Just Nothing
```

The situation becomes a little more illuminating when recursive types are considered. Consider the following encoded version of the list type:

```language-haskell
type List1 a = forall b. (a -> b -> b) -> b -> b
```

But this is just a fold on a specific list! It turns out that the encoding of any data type *corresponds to its fold*.

**Exercise:** What do `to` and `from` look like for `List1 a`?
