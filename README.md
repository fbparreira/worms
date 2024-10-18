README
================

# `worms()`

## Overview

`worms()` is a tool based on the [worrms
package](https://cran.r-project.org/web/packages/worrms/index.html) to
call the [WoRMS Taxon match
tool](https://www.marinespecies.org/aphia.php?p=match) from R to update
and correct marine species names. This tool was created to support my
specific workflow, thus it is highly advisable to see the example
section for a correct application.

This tool is intended to give more feedback on what is going on behind
the scene during the process by providing informative messages as well
as producing intentional errors. This allows the user to better identify
the problem as well as resolve it.

Don’t hesitate in contacting me directly to <fbparreira@ualg.pt> if you
have any doubt or contribution to add.

## Installation

``` r
source("https://raw.githubusercontent.com/fbparreira/worms/main/code.R")
```

## Usage

``` r
worms(names, 
      names_to_delete)

# reults are automaticcaly saved to:
worms_results
```

## Arguments

- `names` A vector containing the species names.

- `names_to_delete` A vector containing the AphiaID duplicates to
  remove.

## Example 1

``` r
species_names <- 
  c("Gammarus insensibilis",
    "Bittium reticulatum")

your_results <- 
  worms(names = species_names)
```

    ## 
    ##   
    ## ---- WoRMS records ---- was created succefully!
    ##                 
    ##           
    ## A total of ----  2  ---- species were searched.

    ## 
    ## 
    ## |status   | total|
    ## |:--------|-----:|
    ## |accepted |     2|

## Example 2

Often [WoRMS](https://www.marinespecies.org/index.php) will have more
than one match for the same species name, as is the case for *Gobius
niger*. In this case, the `worms()` function will automatically produce
an `Error` with the instructions on how to proceed.

``` r
species_names <- 
  c("Gobius niger",
    "Gammarus insensibilis",
    "Bittium reticulatum")

worms(names = species_names)
```

    ## Error: More than one match was found for ---- Gobius niger 
    ##                
    ## To resolve this issue please:
    ## 
    ## 1. go to worms_results;
    ## 2. take note of the AphiaID of the species you want to remove;
    ## 3. Add them together in a vector;
    ## 4. Give that vector to the function in the argument 'names_to_delete'
    ##                
    ## i.e. names_to_delete = c(AphiaID_1, AphiaID_2, ...)

following the instructions given by the previous error message:

``` r
names_to_delete <- c(405560)

your_results <- 
  worms(names = species_names,
        names_to_delete = names_to_delete)
```

    ## 
    ##   
    ## ---- WoRMS records ---- was created succefully!
    ##                 
    ##           
    ## A total of ----  3  ---- species were searched.

    ## 
    ## 
    ## |status   | total|
    ## |:--------|-----:|
    ## |accepted |     3|

## Example 3

If you are working with large datasets of marine biodiversity data to
the species level, you know it’s not all roses. Very often perfect
complete taxonomic identifications are not possible and it is very
common to find in your dataset identifications with, among others,
“c.f.” (to confirm) or “n.i.” (non identified). Naturally, these “c.f.”
and “n.i.” are not recognized by
[WoRMS](https://www.marinespecies.org/index.php) and need to be removed
to run the tool. Thus, if you have a non-corrected *Genus c.f. species*,
you need to remove the “c.f” to run [WoRMS Taxon match
tool](https://www.marinespecies.org/aphia.php?p=match), but later you
naturally need to re-include the “c.f.” into the corrected *Genus c.f.
species*.

Bellow I’ll show how I would use `worms()` in a real life scenario to
correct a species name list.

### Example 3.1 dataset

``` r
# Lets create an example dataset (fauna) to work with
library(tidyverse)
library(stringi)

Species <- 
  c("Gobius niger",
    "Gammarus insensibilis",
    "Bitium reticulatum",
    "Anomia ephippium",
    "Gibbula umbilicaris",
    "Bitium c.f. reticulatum",
    "Clibanarus erithropus",
    "Liocarcinus navigator")

n <- 1:5
Samples <- paste0("S", n)

fauna <- 
  merge(Samples,Species,by=NULL) %>%
  mutate(Count = ceiling(runif(40, min = 0, max = 100))) %>%
  setNames(c("Sample","Species","Count")) %>%
  arrange(Sample)

head(fauna)
```

    ##   Sample                 Species Count
    ## 1     S1            Gobius niger    52
    ## 2     S1   Gammarus insensibilis    54
    ## 3     S1      Bitium reticulatum    94
    ## 4     S1        Anomia ephippium    18
    ## 5     S1     Gibbula umbilicaris    27
    ## 6     S1 Bitium c.f. reticulatum     2

### Example 3.2 unique species list

Now lets create a unique species list to feed [WoRMS Taxon match
tool](https://www.marinespecies.org/aphia.php?p=match) without the
“c.f.”. In this example only the “c.f.” was used, but any “n.i.”, “sp.”,
etc., should be removed as well.

**Important:**

- Make sure you don’t have unnecessary white spaces. You can use the
  `stringr::str_squish()` function for this.

- Make sure you address all variations of “c.f.”, “n.i.” and “sp.”. For
  example, one might be “c.f.” and other might be “cf.”, etc.. Better to
  standardized everything.

- Make sure you apply the corrections of “c.f.” AFTER calling for unique
  species names. If you want to preserve those “c.f.”, “n.i.” and “sp.”.

``` r
species_names <-
  fauna %>%
  # Unique species names
  dplyr::select(Species) %>%
  distinct() %>%
  # Remove the "c.f."
  mutate(Species = stri_replace_all_fixed(Species, "c.f.", "")) %>%
  mutate(Species = str_squish(Species))

# Make sure the species list is a vector
species_names <- as.vector(species_names$Species)
```

### Example 3.3 address duplicate results

Now we are ready to run `worms()`

``` r
your_results <-
  worms(names = species_names)
```

    ## Error: More than one match was found for ---- Gobius niger 
    ##                
    ## To resolve this issue please:
    ## 
    ## 1. go to worms_results;
    ## 2. take note of the AphiaID of the species you want to remove;
    ## 3. Add them together in a vector;
    ## 4. Give that vector to the function in the argument 'names_to_delete'
    ##                
    ## i.e. names_to_delete = c(AphiaID_1, AphiaID_2, ...)

As in **Example 2**, lets remove the unwanted duplicate for *Gobius
niger*.

``` r
names_to_delete <- c(405560)

your_results <- 
  worms(names = species_names,
        names_to_delete = names_to_delete)
```

    ## [1] "No match was found for ---- Bitium reticulatum"
    ## [1] "No match was found for ---- Bitium reticulatum"
    ## [1] "No match was found for ---- Clibanarus erithropus"

    ## 
    ##   
    ## ---- WoRMS records ---- was created succefully!
    ##                 
    ##           
    ## A total of ----  8  ---- species were searched.

    ## 
    ## 
    ## |status                 | total|
    ## |:----------------------|-----:|
    ## |accepted               |     3|
    ## |superseded combination |     1|
    ## |unaccepted             |     1|
    ## |unmatched              |     3|

### Example 3.4 unmatched results

The unmatched results are names that the [WoRMS Taxon match
tool](https://www.marinespecies.org/aphia.php?p=match) is unable to find
any match, often misspelled species names. In this example we have no
match found *Bitium reticulatum* and *Clibanarus erithropus*, which the
correct names are *Bittium reticulatum* and *Clibanarius erythropus*,
respectively.

Also, there are 2 results for *Bittium reticulatum*. This is because one
of them is actually *Bittium c.f. reticulatum*. This is important as you
naturally want to preserve the “c.f.” in your dataset. Thus, you should
correct both:

- `Bitium reticulatum => Bittium reticulatum`

and

- `Bitium c.f. reticulatum => Bittium c.f. reticulatum`

To apply these corrections you can do as follows, **always making sure
the “post worms” section is before everything**. At this point the
entire script should look like this:

``` r
# Post worms
fauna <-
  fauna %>%
  mutate(Species = stri_replace_all_fixed(Species, 
                                          "Bitium reticulatum", 
                                          "Bittium reticulatum")) %>%
  mutate(Species = stri_replace_all_fixed(Species, 
                                          "Bitium c.f. reticulatum", 
                                          "Bittium c.f. reticulatum")) %>%
  mutate(Species = stri_replace_all_fixed(Species, 
                                          "Clibanarus erithropus", 
                                          "Clibanarius erythropus"))



# Unique species name vector
species_names <-
  fauna %>%
  # Unique species names
  dplyr::select(Species) %>%
  distinct() %>%
  # Remove the "c.f."
  mutate(Species = stri_replace_all_fixed(Species, "c.f.", "")) %>%
  mutate(Species = str_squish(Species))

species_names <- as.vector(species_names$Species)



# Remove duplicate results
names_to_delete <- c(405560)


# Run worms()
your_results <- 
  worms(names = species_names,
        names_to_delete = names_to_delete)
```

    ## 
    ##   
    ## ---- WoRMS records ---- was created succefully!
    ##                 
    ##           
    ## A total of ----  8  ---- species were searched.

    ## 
    ## 
    ## |status                 | total|
    ## |:----------------------|-----:|
    ## |accepted               |     6|
    ## |superseded combination |     1|
    ## |unaccepted             |     1|

### Example 3.5 accept WoRMS valid names

At this point, we now have 1 name that is “unaccepted” and 1 “superseded
combination”. You should check your WoRMS results table (`your_results`
or `worms_results`) and under the “Status” column **evaluate if you want
to address or ignore the valid name**.

To address it you can correct the names as in the previous section. To
apply all corrections for this examples, your script should look like
this:

``` r
# Post worms
fauna <-
  fauna %>%
  mutate(Species = stri_replace_all_fixed(Species, 
                                          "Bitium reticulatum", 
                                          "Bittium reticulatum")) %>%
  mutate(Species = stri_replace_all_fixed(Species, 
                                          "Bitium c.f. reticulatum", 
                                          "Bittium c.f. reticulatum")) %>%
  mutate(Species = stri_replace_all_fixed(Species, 
                                          "Clibanarus erithropus", 
                                          "Clibanarius erythropus")) %>%
  mutate(Species = stri_replace_all_fixed(Species, 
                                          "Liocarcinus navigator", 
                                          "Polybius navigator")) %>%
  mutate(Species = stri_replace_all_fixed(Species, 
                                          "Gibbula umbilicaris", 
                                          "Steromphala umbilicaris"))



# Unique species name vector
species_names <-
  fauna %>%
  # Unique species names
  dplyr::select(Species) %>%
  distinct() %>%
  # Remove the "c.f."
  mutate(Species = stri_replace_all_fixed(Species, "c.f.", "")) %>%
  mutate(Species = str_squish(Species))

species_names <- as.vector(species_names$Species)



# Remove duplicate results
names_to_delete <- c(405560)


# Run worms()
your_results <- 
  worms(names = species_names,
        names_to_delete = names_to_delete)
```

    ## 
    ##   
    ## ---- WoRMS records ---- was created succefully!
    ##                 
    ##           
    ## A total of ----  8  ---- species were searched.

    ## 
    ## 
    ## |status   | total|
    ## |:--------|-----:|
    ## |accepted |     8|
"# worms" 
