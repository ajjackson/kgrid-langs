# kgrid-langs

A programming project for ajjackson.  The aim is to produce a program
with similar functionality to https://github.com/wmd-group/kgrid in a
range of programming languages, in order to get a sense of the
available options for routine scientific computing.  The repository is
made public for general interest, but is intended as a curiosity; this
code will probably include "rookie errors" and bad style. the existing
[Python implementation](https://github.com/wmd-group/kgrid) is
suggested for production calculations.

Language features to be used, exploiting standard/mainstream library routines
where possible, include:

* Calculations on vectors/matrices
* Command-line arguments and help 
* File input and recognition
* Write to standard output

Speed is not the main target, as the amount of computation involved in
this test is very small, but the languages chosen were selected for
their potential to outperform Python+Numpy for common tasks.

## Chicken Scheme

The implementation of **kgrid** here is a little verbose and probably
involves more functions that strictly necessary.
At the moment, only POSCAR import is implemented.
I tried to adhere to a reasonably functional style, using `map` and
`fold` operations to apply simple scalar functions to lists. No doubt
I have failed in some aspects of taste for Scheme code and there
should probably be more "let" statements around, but I did have fun
making my loops tail call optimised. (In truth this is overkill for
such small numbers of iterations, but it is worth noting how easy it
is to achieve.)

The immediate obstacle to scientific programming was the lack of
inbuilt linear algebra tools.

To begin with, I rolled my own functions for the dot and cross
products of lattice vectors expressed as lists.  While these
particular cases are quite straightforward, I do not intend to write
my own routines for diagonalising matrices and fitting numerical data.
This can be done with the ATLAS BLAS and LAPACK libraries (see below).

File I/O and command-line arguments were easier to access than
expected. I chose to write a simple parser here rather than learn to
use the provided library, but it looks like the tools are available.
I'm quite pleased with the parser I came up with, however, which is
heavily influenced by *The Little Schemer*, being tail-recursive.

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
"functional-style" method of string formatting, but offers no
explicit integer printing at all. I realised the appropriate tool
would be to convert the value to an "exact" type with `inexact->exact`.

Defining functions on the fly is a scheme-y thing to do, so I have
made use of this to implement the "verbose" flag. I learned this
particular trick with Python.

### BLAS and LAPACK
The [BLAS](http://wiki.call-cc.org/eggref/4/blas) package for chicken
provided an opportunity to play with the package management features
of chicken.
A modified version of kgrid.scm has been written to use this library,
and manipulate the lattice vectors in a 32-bit floating-point vector type.

The compiled version of the program is actually slightly slower than
the all-native version, presumably due to the additional function
calls. The order should be reversed when operating on larger datasets,
but it may be worth playing with.  After installing the ATLAS package
provided by my Linux distro,

    sudo chicken-install blas

built the library, which can then be loaded with

    (use blas)

BLAS only covers basic vector and matrix operations;
[LAPACK](http://wiki.call-cc.org/eggref/4/atlas-lapack) provides
important tools such as matrix inversion. This module provides quite a
thin wrapper around the Fortran libraries, and closely follows their
notoriously terse naming conventions. In the Chicken Scheme program
here we use macros to wrap more intuitive names around the desired
operations, without any unnecessary run-time function calls. In more
flexible programs, these macros might also identify the correct
function to call and deal with converting from nested lists to the
"vectors + dimensions" format used by this library. Certainly there is
less done for us than in scientific computing environments like MATLAB
or Julia. On the other hand, there is a certain satisfaction in being
this close to the libraries we are using and perhaps some
unnecessary/counter-productive actions can be avoided as a result...
