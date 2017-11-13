---
title: Introduction to generating functions
---

**NOTE**: I recently learned about [Yours](https://www.yours.org/). As an
experiment, I [mirrored this post there](https://www.yours.org/content/introduction-to-generating-functions-1d684f5e97ba).
I couldn't find a way to embed math and didn't want to write ASCII art, so the
version here is much easier to follow.

Sequences of numbers appear everywhere throughout computer science and
mathematics. One example is the [triangular numbers](https://en.wikipedia.org/wiki/Triangular_number) (0, 1, 3, 6, 10, 15, …),
where the $n$th term is described by the equation

$$
a_{n+1} = a_n + n + 1
$$

This equation is known as a [recurrence](https://en.wikipedia.org/wiki/Recurrence_relation).
Another example is the [Fibonacci numbers](https://en.wikipedia.org/wiki/Fibonacci_number)
(0, 1, 1, 2, 3, 5, …), given by the recurrence

$$
a_{n+2} = a_{n+1} + a_n
$$

Given a recurrence, is there a way to find a [closed-form expression](https://en.wikipedia.org/wiki/Closed-form_expression)
in $n$ that describes the $n$th term of the sequence? There is more than one
answer to this question, but the one we will investigate involves the theory
of generating functions.

### Generating functions

If a function $f(x)$ can be represented as a [formal power series](https://en.wikipedia.org/wiki/Formal_power_series)
in $x$, with $a_n$ being the coefficient of $x^n$, then $f(x)$ is called the
[(ordinary) generating function](https://en.wikipedia.org/wiki/Generating_function#Ordinary_generating_function_.28OGF.29)
of $a_n$. In other words, $f(x)$ must satisfy

$$
f(x) = \sum_{n \ge 0} a_n x^n
$$

For example, the sequence consisting of all 1's is represented by the formal
sum

$$
\sum_{n \ge 0} x^n = 1 + x + x^2 + \cdots
$$

This sum is a [geometric series](https://en.wikipedia.org/wiki/Geometric_series),
and can be simplified to the generating function

$$
\sum_{n \ge 0} x^n = \frac{1}{1 - x}
$$

**NOTE:** For readers who are familiar with calculus, the fact that we are
working with formal power series and not continuous functions means that we
don't have to worry about issues like convergence.

Once we have a generating function, we can use a method such as partial
fraction expansion to compute the terms we care about. But is there a more
general method for finding a generating function from a recurrence? One way is
as follows:

1. Multiply both sides of the equation by $x^n$
2. Sum both sides of the equation for all $n \ge 0$
3. Rewrite sums to be in the form of the generating function we are looking for, and rename them to A(x)
4. Solve the equation for A(x)

Let's try it out on the triangular numbers. To simplify things, let's apply
steps 1 through 3 to each side separately, and then combine them for the final
step. Starting with the left-hand side, we have

$$
\begin{align*}
\sum_{n \ge 0} a_{n+1}\,x^n &= \frac{\sum_{n \ge 0} a_{n+1}\,x^{n+1}}{x}\\
&= \frac{\sum_{n \ge 0} a_n\,x^n - a_0}{x}\\
&= \frac{A(x) - a_0}{x}\\
&= \frac{A(x)}{x}
\end{align*}
$$

The right hand reduces to

$$
\begin{align*}
\sum_{n \ge 0} \left(a_n + n + 1\right)\,x^n &= \sum_{n \ge 0} a_n\,x^n + \sum_{n \ge 0} n\,x^n + \sum_{n \ge 0} x^n \\
&= A(x) + \frac{x}{(1-x)^2} + \frac{1}{1-x}
\end{align*}
$$

Combining the two and solving for A(x), we find the generating function:

$$
\begin{align*}
\frac{A(x)}{x} &= A(x) + \frac{x}{(1-x)^2} + \frac{1}{1-x} \\
A(x) &= x A(x) + \frac{x^2}{(1-x)^2} + \frac{x}{1-x} \\
(1-x) A(x) &= \frac{x}{(1-x)^2} \\
A(x) &= \frac{x}{(1-x)^3}
\end{align*}
$$

which gives the following formula after partial fraction expansion (ommitted):

$$
a_n = \frac{n(n+1)}{2}
$$

### Final thoughts

If you're familiar with other methods of solving recurrences, this approach may
seem fairly heavy-handed without much benefit. However, not only do generating
functions encompass many different kinds of recurrences, later techniques allow
solving a wide variety of counting problems in [enumerative combinatorics](https://en.wikipedia.org/wiki/Enumerative_combinatorics).

Ordinary generating functions are not the only kind of generating functions.
There are several other families, including exponential and Dirichlet generating
functions. Choosing the right family for a problem can make it much easier
to solve. If you're interested in learning more, I recommend checking out
the book [generatingfunctionology](https://www.math.upenn.edu/~wilf/DownldGF.html),
available for free and in hard copy at major online retailers.

### Exercise

Using the method described in the article, find the generating function for the Fibonacci numbers. Remember that a₀ = 0 and a₁ = 1.

Solution available on [Yours](https://www.yours.org/content/introduction-to-generating-functions-1d684f5e97ba/).
