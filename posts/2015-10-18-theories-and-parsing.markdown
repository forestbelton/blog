---
title: Theories and parsing
---
I've had a lot of opportunity to get some reading in while spending time in the beautiful [Chania](https://en.wikipedia.org/wiki/Chania). One of the books I'm reading is [Logic as algebra](http://www.amazon.com/Logic-Algebra-Dolciani-Mathematical-Expositions/dp/0883853272), written by [Halmos](https://en.wikipedia.org/wiki/Paul_Halmos) himself.

One of the examples in the book really stuck out for me &mdash; this post is about that example.

A formal language, described informally, is just a set of words that are composed from letters from an alphabet. For example, suppose we have the following alphabet:

$$
\Sigma = \left\\\{ D, N, E, A \right\\\}
$$

and that our words are built up inductively from $DED$, $NEN$, and the following rewrite rules:

  3. $D \rightarrow DAN$
  4. $D \rightarrow NAD$
  5. $N \rightarrow DAD$
  6. $N \rightarrow NAN$

Some examples of words in our language are $DED$, $DANED$, $NANADADEN$, and so on.

When we have a language, we generally want to create a parser for it. A parser has one task: given a word, does it exist in the language or not?

Given a [BNF](https://en.wikipedia.org/wiki/Backus%E2%80%93Naur_Form) description of the language's grammar, it's very easy to create a parser. The BNF for our language is as follows:

```
<eqn> ::= <d> "e" <d>
        | <n> "e" <n>

  <d> ::= <d> "a" <n>
        | <n> "a" <d>
        | "d"

  <n> ::= <n> "a" <n>
        | <d> "a" <d>
        | "n"
```

**Exercise:** Remove the left recursion from this grammar and implement a parser for it using a method of your choice.

So far, everything is all fine and dandy. But the syntax of a language has no meaning on its own &mdash; there is an additional step of [denoting](https://en.wikipedia.org/wiki/Denotation) words in our language with an interpretation.

Suppose that we interpret our language as a logical theory. Every word in the language represents a provable theorem. If that were the case, then a parser for this language would effectively be a [theorem prover](https://en.wikipedia.org/wiki/Automated_theorem_proving) &mdash; given a theorem, is it provable in the theory or not?

The language we described above has one such interpretation. It can be thought of as equations over natural numbers involving [parity](https://en.wikipedia.org/wiki/Parity_(mathematics%29); the addition of two odd numbers is an even number, and so on.

Given that:

* $D$ means an od**d** number
* $N$ means an eve**n** number
* $E$ means **e**quals
* $A$ means **a**ddition

So when we have the word $DANED$, that's really saying:

$$
\text{odd} + \text{even} = \text{odd}
$$

Not many logical theories can be captured so nicely in this way, but it is an interesting & useful way to think about them.
