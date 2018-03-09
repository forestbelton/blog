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
polynomial](https://en.wikipedia.org/wiki/Zhegalkin_polynomial). Coefficients of Zhegalkin
polynomials are in $\mathbb{Z}/2\mathbb{Z}$, which represents the set of integers modulo 2
and has two elements: 0 and 1. Further, the addition and multiplication operations have been
replaced with the boolean [AND](https://en.wikipedia.org/wiki/Logical_conjunction) and
[XOR](https://en.wikipedia.org/wiki/Exclusive_or), respectively. XYZ,