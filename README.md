# Molcajete

A date finder for the Julia meetup.

To run, simly edit `src/test.jl` and run `julia src/test.jl`.

Alternatively,

```
julia

> Pkg.clone("https://github.com/xmunoz/Molcajete.jl.git")
> using Molcajete
> Molcajete.show_calendar("Julia-Users-Group", Date(2016, 12, 1), Date(2016, 12, 31), num_meetups = 20)
```
