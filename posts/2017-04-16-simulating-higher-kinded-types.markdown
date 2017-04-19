---
title: Simulating Higher-Kinded Types, Part 1
---
Java is the de facto choice for my daily work. As a result, I often miss useful features from other languages. Introducing non-idiomatic code in a team-based context can do more harm than good, but it doesn't stop me from wondering: what would higher-kinded types look like in a language that does not have built-in support for them? In these posts, I take on this quixotic task.

**NOTE**: This is an ongoing research topic, so I have no definite solutions. For brevity's sake, most examples will be in Haskell.

### Kinds
Before we can tackle the problem of implementing higher-kinded types, let's take a step back and talk about what a higher-kinded type is. Just as a type classifies a collection of values, a _kind_ classifies a collection of types. It is the same concept, but "one level higher" in hierarchy of abstraction.

Since most languages have relatively simple type systems, the concept of kind may be new. In these languages, all types have the same kind, denoted ★ (or `*` in ASCII). Higher-kinded types extend this system by introducing a new way to form kinds: given any two kinds `k` and `k'`, we can form the _function kind_ `k -> k'`. We can form kinds such as ★, ★ →★, (★→★)→(★→★), et al.

This is an analogue of the _function type_, which allows us to form a new type `a -> b` from any two types `a` and `b`. The only difference is that instead of dealing with types of values, we are now dealing with kinds of types.

A common type in Haskell is `Identity a`, which is just a wrapper over the type `a`. Usually it is defined like so:

```language-haskell
newtype Identity a = Identity { runIdentity :: a }
```

We can construct a value such as `Identity 10`, which has a type of `Identity Int`. Since this is a value, it has kind ★. However, the type constructor `Identity` can be seen as a function over types, taking in an input type `a` and producing an output type `Identity a`. Thus, the type constructor `Identity` has kind ★ →★.

`Identity` can be defined in many languages. For instance, it can be defined in Java:

```language-java
public final class Identity<A> {

    private final A value;

    public Identity(A value) {
        this.value = value;
    }

    public A value() {
        return this.value;
    }
}
```

Given this, it may be confusing when someone says that a language does not support higher-kinded types. Haven't we just defined one here? Usually, they mean that the language does not support _abstraction_ over these types, i.e. we cannot be polymorphic over any higher-kinded type. A more correct description of the missing feature is _higher-kinded polymorphism_. If we had support for higher-kinded polymorphism, we would be able to define an interface for `Functor` in Java:

```language-java
public interface Functor<F> {
    <A, B> F<B> fmap(Function<A, B> f, F<A> x);
}
```

The issue here is that `F` must be of kind ★ →★ in order for `F<A>` and `F<B>` to be well-typed. Without the ability to instantiate `F` to a particular parameter, we cannot implement this.

### Approach 1: Type families

This topic is heavily inspired by [Lightweight Higher-Kinded Polymorphism](https://www.cl.cam.ac.uk/~jdy22/papers/lightweight-higher-kinded-polymorphism.pdf), which describes an implementation in OCaml. However, most languages do not have support for [ML functors](https://realworldocaml.org/v1/en/html/functors.html), which limits the applicability of these results.

The core idea of this paper is to convert a type `F<A>` into `App<F, A>` by giving `F` the kind of ★. Since all polymorphic types now have kind ★, we no longer run into limitations of the host language. In this approach, we also apply a [type family](https://wiki.haskell.org/GHC/Type_families) to map `App<F, A>` back to the the underlying type.

What is a type family? The previous link describes it in much better detail than I could hope to, but for the sake of self-containment we will go over it briefly here.

Previously, we mentioned that a type constructor could be interpreted as a function over types. However, these functions are very restricted in what we allow them to map to, e.g. `Identity` can only produce `Identity a`s. A _type family_ allows us to relax this restriction and map input types to arbitrary types. For example, this type family will map `Int` to `String`, but `Float` is mapped to `Maybe String`:

```language-haskell
type family F a where
    F Int   = String
    F Float = Maybe String
```

**NOTE:** The `TypeFamilies` extension must be enabled in GHC for this to work.

This is a _closed_ type family, which means that we have exhaustively defined all of the input types `F` will map. In an _open_ type family we leave the definition open for extension by others. To allow arbitrary implementations of functors we will use an open type family, initially defining a mapping for list types:

```language-haskell
data List

type family Apply f a
type instance Apply List a = [a]
```

Ideally we would continue in our quest, defining `Functor` and providing an implementation:

```
class Functor f where
    fmap :: (a -> b) -> Apply f a -> Apply f b

instance Functor List where
    fmap = map
```

However, this fails because `Apply` does not represent an [injective function](https://en.wikipedia.org/wiki/Injective_function) over types. Without this knowledge, the type checker rejects our definition of `Functor`. To solve this, we can introduce a new type that wraps `Apply f a`:

```
newtype App f a = Inject { project :: Apply f a }
```

Since all type constructors are injective, the type checker is suitably convinced and we can complete our implementation:

```language-haskell
class Functor f where
    fmap :: (a -> b) -> App f a -> App f b

instance Functor List where
    fmap f = Inject . map f . project
```

This approach is straightforward enough to warrant an automated solution. One implementation is the [higher](https://github.com/ocamllabs/higher) library in OCaml.

### A solution in Java?

Let's take the Haskell implementation and naïvely attempt to transform it to Java. In [A Comparative Study of Language Support for Generic Programming](https://www.osl.iu.edu/publications/prints/2003/comparing_generic_programming03.pdf) an approach for associated types in Java is laid out. This allows us to recover behavior similar to type families:

```language-java
public interface Apply<F, A> {
}

public class App<F, A, T extends Apply<F, A>> {

    private final T value;

    public App(T value) {
        this.value = value;
    }
}

public interface Functor<F> {
    <A, T extends Apply<F, A>, B, U extends Apply<F, B>>
        App<F, B, U> fmap(Function<A, B> f, App<F, A, T> x);
}
```

Everything looks good so far; we have managed to define a `Functor` interface. Since Java does not have full support for associated types, we introduce the type `T` (resp. `U`) as a parameter, using `F` and `A` (resp. `B`) to constrain what is allowed.

However, the problem surfaces when you attempt to implement `Functor`. In its definition, we allow `T` and `U` to be any subtypes of `Apply<F, A>` and `Apply<F, B>`, respectively. But in our implementation, we wish for them to be a specific concrete subtype. Without this, we will not be able to extract a `List<B>` after performing `fmap`, since we do not have enough information to conclude that `U = List<B>`.

We've hit our first show stopper. In the next post, I will describe another approach based on GADTs which runs into its own set of challenges during implementation.
