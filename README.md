# Molcajete

A date finder for the Julia meetup. First, you'll need to set the environment variable `MEETUP_API_TOKEN`. Anyone logged into meetup.com can find their token here: https://secure.meetup.com/meetup_api/key/

To run, simly edit `src/test.jl` and run `julia src/test.jl`.

Alternatively,

```
julia

> Pkg.clone("https://github.com/xmunoz/Molcajete.jl.git")
> using Molcajete
> Molcajete.show_calendar("Julia-Users-Group", Date(2016, 12, 1), Date(2016, 12, 31), num_meetups = 20)
```

The 3 required arguments for `show_calendar` are meetup url name, scan start date, and the scan end date. Optionally, you can specify how many of the top N meetups of your members to consider with the `num_meetups` keyword argument.
