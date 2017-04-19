---
title: Computing domains
---
Recently I've been tutoring someone who's taking a pre-calculus class. They've been away from math for quite some time, so it's been an interesting challenge to find and fix gaps in their understanding.

One of the first questions we went over was as follows: given a function $f$, what is the largest subset of $\mathbb{R}$ it can be defined on?

I remember this problem giving me a lot of trouble back when I learned it. It's easy to figure out the largest possible domain of $f(x) = \frac{1}{x}$, but when expressions start getting more complicated it can be difficult figuring out where to start.

Definition
--
After a few minutes of thinking, you can probably come up with the simple inductive definition that I've defined below. But first, some notation:

* $D(f)$ - The largest domain on which $f$ can be defined
* $Z(f)$ - The set of zeros for $f$
* $I(f)$ - The image of $f$

We start with the simple cases, and work our way up inductively. Here, $x$ will refer to the input parameter of $f$.

Constant and identity functions are defined across their entire domain, so we have:

$$
\begin{align\*}
D(c) &= \mathbb{R} \\\\
D(x) &= \mathbb{R}
\end{align\*}
$$

If we know $D(f)$ and $D(g)$, what can we say about $D(f + g)$? Well, any value that makes $f$ undefined would also make $f + g$ undefined, and the same goes for $g$. This is also the case for $f - g$ and $f \times g$, so we have:

$$
\begin{align\*}
D(f + g) &= D(f) \cap D(g) \\\\
D(f - g) &= D(f) \cap D(g) \\\\
D(f \times g) &= D(f) \cap D(g) \\\\
\end{align\*}
$$

What about $f / g$? We can apply the same reasoning above, but we also need to exclude the values which satisfy $g(x)=0$.

$$
D(f / g) = D(f) \cap D(g) \cap (\mathbb{R} - Z(g))
$$

Now the only remaining expression to compute is $f \circ g$, which is the most complicated, and arguably the most important as well. In this case we are clearly limited by the domain of $g$ &mdash; any value which is not in the domain of $g$ will not even "make it" to the application of $f$.

However, there is one improvement we can make: if a value does not appear in the image of $g$, it doesn't matter if it is in $f$'s domain or not.

$$
D(f \circ g) = D(g) - (I(g) - D(f))
$$

Examples
--
This should give us all the tools we need to start computing. Applying the definition to $f(x) = \frac{1}{x}$, we get:

$$
\begin{align\*}
D\left(\frac{1}{x}\right) &= D(1) \cap D(x) \cap \left(\mathbb{R} - Z(x)\right) \\\\
&= \mathbb{R} \cap \mathbb{R} \cap \left(\mathbb{R} - \left\\\{0 \right\\\}\right) \\\\
&= \mathbb{R} - \left\\\{0\right\\\} \\\\
&= \left(-\infty, 0\right) \cup \left(0, \infty\right)
\end{align\*}
$$

This even works for more complicated examples. For instance, assuming we already know the domain of $\sqrt{x}$:

$$
\begin{align\*}
D\left(\sqrt{x^2}\right) &= D\left(x^2\right) - \left(I\left(x^2\right) - D\left(\sqrt{x}\right)\right) \\\\
&= \mathbb{R} - \left(\left[0, \infty\right) - \left[0, \infty\right)\right) \\\\
&= \mathbb{R} - \emptyset \\\\
&= \mathbb{R}
\end{align\*}
$$

Conclusion
--
I'm not sure if this method is effective in general for a few reasons:

1. $Z(f)$ is impossible to compute in general. For instance, we can't compute $Z(ax^5 + bx^4 + cx^3 + dx^2 + ex + f)$, the zero set of a quintic polynomial.
2. $I(f)$ is also impossible to compute. Consider the simpler problem of determining $y \in I(f)$: this reduces to the problem $\exists x. f(x) = y$, which in turn reduces to $\exists x. f(x) - y = 0$, which means that this is just as difficult to compute as a zero is.
3. Set operations can be tedious to reduce. Trying to come up with a fool-proof algorithm for this led me through topology and order theory, only to end up at [term rewriting systems](https://en.wikipedia.org/wiki/Rewriting#Term_rewriting_systems). These turn out to be really interesting, and I plan on writing about them more later.

That being said, it should be easy to turn the inductive definition into a recursive algorithm, prompting the user for holes that the program cannot solve. Here's a toy implementation in Haskell:

```language-haskell
data FOp
    = Add
    | Mul
    | Sub
    | Div
    | Compose

data Fun
    = Val Int
    | Var
    | FunOp FOp Fun Fun

data Set
    = R
    | Image Fun
    | Zero Fun
    | Cap Set Set
    | Diff Set Set

dom :: Fun -> Set
dom (Val x)        = R
dom Var            = R
dom (FunOp op f g) = case op of
    Div     -> dom f `Cap` dom g `Cap` (R `Diff` Zero g)
    Compose -> dom g `Diff` (Image f `Diff` dom f)
    _       -> dom f `Cap` dom g
```
