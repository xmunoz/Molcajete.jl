### Molcajete

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


## Debugging

Note: Molcajete should have Require statements which define what is needed to run it.


# Command-line plotting

using Blink
Blink.AtomShell.install()


# Modules
I like to do my development in a folder separate from the main Julia modules. So I clone to that area then I need to add that location to the PATH_LOAD variable using:

push!(LOAD_PATH, "/Path/To/My/Module/")

/Path/To/My/Module/ should contain the folder Molcajete, which in turn contains src/Molcajete.jl

From this location 'using Molcajete' should load the module.
 But note: debugging modules sucks. I find it easier to comment out the Module declaration and include the code instead.


# Jupyter Notebook
Still working from the clone to my own working-space rather than the Julia modules directory.

Set the environment variable:
	export MEETUP_API_TOKEN="blah"

Run the jupyter notebook (from the working directory which contains the Molcajete project folder):
	jupyter notebook

Then load the notebook and use it:
	Molcajete/david_ijulia_notebook.ipynb

