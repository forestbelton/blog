---
title: Zhegalkin polynomials
---

Many people become acquainted with [polynomials](https://en.wikipedia.org/wiki/Polynomial)
during grade school math. These polynomials are of a single variable (usually denoted $x$)
and take the [real numbers](https://en.wikipedia.org/wiki/Real_number) as coefficients.
But what happens when we change or relax these constraints? What kind of polynomials do
we end up with?

With the language of [abstract algebra](https://en.wikipedia.org/wiki/Abstract_algebra), the
definition of a polynomial becomes a rather general one. Not only can we [take polynomials
over a different set of coefficients](https://en.wikipedia.org/wiki/Polynomial_ring), but
we can also change what multiplication and addition mean, provided they [follow the laws
we expect](https://en.wikipedia.org/wiki/Ring_%28mathematics%29#Definition).

In this post, we will consider a very specific kind of polynomial known as a [Zhegalkin
polynomial](https://en.wikipedia.org/wiki/Zhegalkin_polynomial). Zhegalkin polynomials differ
from regular polynomials in the coefficients they take and in the operations used.

Coefficients of Zhegalkin polynomials are in $\mathbb{Z}/2\mathbb{Z}$, which represents the
set of integers modulo 2. Thus, $\mathbb{Z}/2\mathbb{Z}$ has two elements: one that
represents 0 and another for 1. Multiplication and addition have been replaced with boolean
[AND](https://en.wikipedia.org/wiki/Logical_conjunction) and
[XOR](https://en.wikipedia.org/wiki/Exclusive_or), respectively. For example, the polynomial
$x^2 + x + 1$ represents the boolean operation $\left(x \land x\right) \oplus x \oplus 1$
where $1$ represents a "true" value. We will use $\oplus$ to denote addition via XOR in order
to avoid confusion with regular addition.

These changes greatly simplify the different kinds of polynomials available. Since $x \land x$
is equivalent to $x$, we have $x = x^2 = x^3 = x^4 = \,\, ...$ and thus it is not necessary to
raise variables to a power.

Zhegalkin polynomials are capable of representing any boolean operation. For example, the
following connectives are mapped to their equivalent polynomials:

$$
\begin{align*}
\neg a & \rightarrow a \oplus 1 \\
a \lor b & \rightarrow a \oplus b \oplus ab \\
a \Rightarrow b & \rightarrow ab \oplus a \oplus 1
\end{align*}
$$

When converted in this manner, Zhegalkin polynomials represent a
[normal form](https://en.wikipedia.org/wiki/Normal_form_%28abstract_rewriting%29) for
boolean operations. What this means is that any two _equivalent_ boolean operations will be
_equal_ when represented as Zhegalkin polynomials.

This property becomes immensely useful in the context of
[automated theorem proving](https://en.wikipedia.org/wiki/Automated_theorem_proving). Since
expressions in boolean algebra correspond to propositions in [propositional logic](https://en.wikipedia.org/wiki/Propositional_calculus),
we can prove that two propositions are equivalent (or not) by converting them to Zhegalkin
polynomials and performing an equality check.

As an example, consider [De Morgan's laws](https://en.wikipedia.org/wiki/De_Morgan%27s_laws).
One of the laws states that $\neg\left(P \lor Q\right) \iff \left(\neg P\right) \land \left(\neg Q\right)$. Converting
the left-hand side to a Zhegalkin polynomial, we see:

$$
\begin{align*}
\neg\left(P \lor Q\right) &= \neg\left(P \oplus Q \oplus PQ\right) \\
&= P \oplus Q \oplus PQ \oplus 1
\end{align*}
$$

If we do the same to the right-hand side, we find:

$$
\begin{align*}
\left(\neg P\right) \land \left(\neg Q\right) &= (P \oplus 1) \land (Q \oplus 1) \\
&= (P \oplus 1)(Q \oplus 1) \\
&= PQ \oplus P \oplus Q \oplus 1
\end{align*}
$$

Since $\oplus$ is commutative, both sides are equal and we have proven the law.

The ease with which properties like De Morgan's laws can be checked shows just how effective
this method can be. However, it's important to note that while this method works well for
_propositional logic_, it breaks down when you move to [_first-order logic_](https://en.wikipedia.org/wiki/First-order_logic),
which augments propositional logic with universal and existential quantifiers. Unfortunately,
there does not exist a similar method for first-order logic, as logical consequence is no longer
[decidable](https://en.wikipedia.org/wiki/Decidability_%28logic%29).

In short, Zhegalkin polynomials provide an interesting way of looking at propositions. Their simple
representation permits a straightforward method to determine whether propositions are equivalent.
However, their application is limited due to the necessity of first-order logic in many situations.