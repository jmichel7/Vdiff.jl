# Vdiff
Visual  and  interactive  comparison  of  two  files  or directories. It is
written   as  a   console  application   using  the   ncurses  bindings  in
`TextUserInterfaces` (it is a Julia port of a Ruby app "rdelta").

To start the application, you can either:

in the REPL

```
using Vdiff
vdiff("xxx","yyy")
```

where  "xxx" and "yyy" are two files or two directories to compare. In each
case  you get a window where help is available with "F1" of "h" or from the
menu.

Or from the command line, using the file `main.jl` in the `src` directory:
```
julia main.jl xxx yyy
```

[![Build Status](https://github.com/jmichel7/Vdiff.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/jmichel7/Vdiff.jl/actions/workflows/CI.yml?query=branch%3Amain)
