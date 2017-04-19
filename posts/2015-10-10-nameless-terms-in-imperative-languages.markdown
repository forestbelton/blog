---
title: Nameless terms in imperative languages
---
I've been helping a friend out with a compiler that he's building for his awesome product, [ShaderFrog](https://shaderfrog.com). Andy was running into a serious performance issue as the number of shaders increased, so we sat down and brainstormed potential solutions.

It turned out that the biggest bottleneck was a phase that was performing a substitution of one shader AST into another. Since this requires looking for names and performing [&alpha;-conversion](https://en.wikipedia.org/wiki/Lambda_calculus#.CE.B1-conversion), it can get costly quick &mdash; especially if you are traversing the entire AST.

Since substitution is [well understood](https://en.wikipedia.org/wiki/Lambda_calculus#Substitution) in the lambda calculus, I thought of the usual solutions and which would be the easiest to apply. Ultimately I decided on a [gensym](https://en.wikipedia.org/wiki/Hygienic_macro#Strategies_used_in_languages_that_lack_hygienic_macros)-like approach, where top-level declarations were prefixed with an AST-unique value to ensure uniqueness during composition. I chose it because of its relative simplicity to the other approaches.

This worked great! The performance issue disappeared and Andy could go back to focusing on more important things (he has some really cool stuff in the pipeline that I can't wait to see released). But I was unsatisfied &mdash; this approach, while effective, seemed very antiquated. What if we parsed the AST into a nameless representation, à la [De Bruijn indices](https://en.wikipedia.org/wiki/De_Bruijn_index)? Then the issue of renaming would be abolished forever.

A new hope
----
With De Bruijn indices, we replace names with numbers. These numbers represent how many binders "deep" they are, relative to the binder they were introduced at. For example, $\lambda x. x$ is converted to $\lambda 0$, and $\lambda x. \lambda y. x$ to $\lambda \lambda 1$.

With an imperative C-like language like GLSL, the "binders" are just the block of code that the identifier is declared in. Given that [shadowing](https://en.wikipedia.org/wiki/Variable_shadowing) exists, these behave very much like a lambda would. But these languages add one extra dimension &mdash; you can have multiple declarations within one block.

If you simply use a *pair* of numbers to track the names, where the second number is the relative ordering of the declaration within the current block, you get a nameless representation. For example:

```language-clike
int foo = 7; /* (0, 0) */
char bar; /* (0, 1) */

void baz /* (0, 2) */
(int x) { /* (1, 0) */
    int y = 3; /* (1, 1) */
    
    if (x != 1) {
        int z = 5; /* (2, 0) */
        return z; /* (2, 0) */
    }
    
    return foo /* (0, 0) */ + x /* (1, 0) */ + y /* (1, 1) */;
```

I haven't spent the time proving that this is a valid representation, but since it seems like a fairly natural extension of De Bruijn indices, I'm confident in it.

This makes substitution very simple:

* Let `n` be the highest value for which `(0, n)` occurs in the first AST.
* For every pair `(0, k)` in the second AST, replace it with `(0, k + n)`.

All of the pairs are "shifted down", just like they would be if the two sources had been concatenated before parsing into an AST.

This is very nice and pretty, but there is an issue of performance: Every time we compose these two ASTs, we have to traverse all of the functions defined in the second one to replace `(0, k)` with `(0, k + n)`. If we extend this pair to a triple, where the third value represents an "offset", we only have to traverse the top-level declarations. That offset can then propagate from the top-level definition into its block of code. For example:

```language-clike
// Source from first shader
int a; /* (0, 0, 0) */
char b; /* (0, 1, 0) */

// Source from second shader, after composition
float c; /* (0, 0, 1) */

void bar() { /* (0, 1, 1) */
    int y = 3; /* (1, 0) */
    
    return y /* (1, 0) */ + c /* (0, 0) */;
}
```

Since `bar` has an offset of 1, we can ensure that during interpretation the enclosed reference to `c` will be `(0, 1)` instead of `(0, 0)`, which is what `a` is mapped to. Essentially, we delay the computation of `c`'s real index until it is actually necessary.

I'm not sure how often substitution comes up with the implementation of imperative compilers, but it could be effective depending on the scenario.
