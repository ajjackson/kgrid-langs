# kgrid-langs

A programming project for ajjackson.  The aim is to produce a program
with similar functionality to https://github.com/wmd-group/kgrid in a
range of programming languages, in order to get a sense of the
available options for routine scientific computing. Features to be
used, exploiting standard/mainstream library routines where possible,
include:

* Calculations on vectors/matrices
* Command-line arguments and help 
* File input and recognition
* Write to standard output

Speed is not the main target, as the amount of computation involved in
this test is very small, but the languages chosen were selected for
their potential to outperform Python+Numpy for common tasks.

## Chicken Scheme

The implementation of **kgrid** here is a little verbose and probably
involves more functions that strictly necessary. I tried to adhere to
a reasonably functional style, using `map` and `fold` operations to
apply simple scalar functions to lists. No doubt I have failed in some
aspects of taste for Scheme code and there should probably be more
"let" statements around, but I did have fun making my loops tail call
optimised. (In truth this is overkill for such small numbers of
iterations, but it is worth noting how easy it is to achieve.)

The immediate obstacle to scientific programming was the lack of
standard linear algebra tools; I was forced to implement my own
functions for the dot and cross products of the lattice vectors.
While these particular cases are quite straightforward, I do not
intend to write my own routines for diagonalising matrices and fitting
numerical data. It will be necessary to wrap external libraries to access
these core scientific tools.

File I/O and command-line arguments were easier to access than
expected. I chose to write a simple parser here rather than learn to
use the provided library, but it looks like the tools are available.
I'm quite pleased with the parser I came up with, however, which is
heavily influenced by *The Little Schemer*, being recursive and fully
tail-call optimised.

Surprisingly one of the hardest parts of this was formatting the
output. A little searching suggested it was necessary to
`chicken-install format` and `(use format)` to obtain a sufficiently
powerful string formatter for what is generally considered a very
basic output of formatted numbers. Most languages have some way of
accessing a thin wrapper or clone for C's `printf` statement, which
sets the standard.

In addition, I seem to have found a bug in this library, as the
integer numbers of k-point samples are printed with a decimal zero.
This is reproducible with
    (use format)
    (format #f "~D" 4.000000)
and rather frustrating for what seems like an everyday task.

Dipping into the freenode #chicken IRC channel I asked if anyone had
experience with `(use format)` and was recommended the inbuilt `fmt`
module instead. This presents quite an interesting and much more
functional-programming method of string formatting, but offers no
explicit integer printing at all. I realised the appropriate tool
would be to convert the value to an "exact" type with `inexact->exact`.
