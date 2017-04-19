---
title: ATS on Homebrew
---
Lately I've been playing with a language called [ATS](http://www.ats-lang.org/). It's statically typed and supports both linear and dependent typing. I'm hoping to write a few posts about it (from a Haskell perspective) once I've learned a bit more.

After reading a bit of the [tutorial introduction](http://www.ats-lang.org/DOCUMENT/INT2PROGINATS/HTML/book1.html), I tried to install ATS on my system. I noticed it wasn't available on Homebrew, so I submitted a PR to add it. You can now install it via the package name `ats2-postiats`. Happy hacking!

__NOTE:__ This bottle was compiled with GC disabled. I'm thinking about submitting a patch to change this in the near future.
