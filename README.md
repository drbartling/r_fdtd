# r_fdtd
Finite difference time domain (FDTD) simulation written in R with some example transmission line configurations.

Last verified with R 4.5.2

## Getting Started

### Installing R

Go to https://cran.r-project.org/ and follow the instructions for your operating system.

### Running

Change the directory to this directory:
  Select file -> Change Dir...
  Then browse to the folder with this readme and the `fdtd.R` file.

Enter one of the following commands in the command line.
```r
source("simulate_t_line.R")
source("compare_t_lines.R")
source("test_example_lines.R")
```

#### simulate_t_line

simulate_t_line.R will simulate a single transmission line. Showing the voltage and current as a function of distance.  It will also show the left-most (input) voltage as a function of time.

#### compare_t_lines

compare_t_lines.R will allow you to simulate multiple transmission lines.
To queue up the transmission lines you want:
Select each transmission file you want to simulate in the order you want them simulated.
End selection by selecting the same file twice in a row.

The first transmission line will show the full simulation, as in simulate_t_lines.R.  The remaining transmission line sims will be overlaid on the final plot of the first file for comparison.

#### test_example_lines

test_example_lines.R will simulate all transmission line files in the examples directory.  This will only show the overlay, as in compare_tlines.R

example_line.R shows how a transmission line is defined in a single file.
The other examples show how you can add to a base transmission line to avoid retyping basic parameters that are used for several simulations.
