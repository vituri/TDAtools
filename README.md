
<!-- README.md is generated from README.Rmd. Please edit that file -->

# TDAtools

<!-- badges: start -->
<!-- badges: end -->

TDAtools provides many functions to help data scientists using TDA.

## Installation

You can install the development version of TDAtools from
[GitHub](https://github.com/) with:

``` r
# devtools::install_github("vituri/TDAtools")
```

## Notation

Let’s fix some notation:

-   `X` is a data.frame with possibly factor columns. When needed, we
    select only the numeric columns (like when calculating the distance
    matrix of `X`) and denote it by $X$. The rows of `X` are called
    observations, and the columns are called variables;

-   `f_X` is a vector with one number for each observation of `X`. That
    is: `f_X` is the result of applying a *filter function*
    $f: X \to \mathbb{R}$ to `X`. We provide many filter functions;

-   `distance_matrix` is a matrix of distances calculated with `X` OR a
    function that when applied to `X` results in such a matrix

## Graph-reducing algorithms

We provide the Mapper algorithm and the Ball Mapper algorithm. Both
return a list consisting of:

-   a graph with weighted vertices;

-   a list showing which points of `X` are in each vertex.

## Examples

Let `X` be a sample of random points in a noisy circle:

``` r
library(TDAtools)
#> Carregando pacotes exigidos: shiny
#> Carregando pacotes exigidos: dplyr
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
#> Carregando pacotes exigidos: purrr
#> Carregando pacotes exigidos: ggplot2

X = data.noisy_circle()
```

Let the filter function be the projetion on the x-axis and let color `X`
using it:

``` r
f_X = X$x

color_band = ggplot2::cut_interval(f_X, n = 50)
col_vector = viridis::viridis(nlevels(color_band))[as.integer(color_band)]
plot(X, col = col_vector)
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />

Now we embed `X` in $R^4$:

``` r
X$z = 0
X$w = 0
```

and calculate its Mapper Graph:

``` r
mp =
  mapper(
    X = X
    ,f_X = f_X
  )
#> Clustering pullback 1...
#> Clustering pullback 2...
#> Clustering pullback 3...
#> Clustering pullback 4...
#> Clustering pullback 5...
#> Clustering pullback 6...
#> Clustering pullback 7...
#> Clustering pullback 8...
#> Clustering pullback 9...
#> Clustering pullback 10...
```

The result is a list with many objects. For example, the pullback of
each interval in the covering:

``` r
mp$pullback |> str()
#> List of 10
#>  $ 1 : int [1:105] 2 39 42 60 61 62 72 77 89 92 ...
#>  $ 2 : int [1:279] 2 4 14 16 24 26 39 42 44 52 ...
#>  $ 3 : int [1:273] 4 6 8 10 14 16 18 21 24 26 ...
#>  $ 4 : int [1:181] 1 6 8 10 18 21 23 28 29 40 ...
#>  $ 5 : int [1:173] 1 3 5 23 30 35 38 40 41 50 ...
#>  $ 6 : int [1:172] 3 5 13 20 22 25 30 35 38 43 ...
#>  $ 7 : int [1:199] 13 17 19 20 22 25 27 34 43 45 ...
#>  $ 8 : int [1:314] 7 9 11 17 19 27 31 32 34 36 ...
#>  $ 9 : int [1:250] 7 9 11 12 15 31 32 33 36 37 ...
#>  $ 10: int [1:54] 12 15 33 73 88 94 144 147 152 167 ...
#>  - attr(*, "class")= chr "AsIs"
```

Let’s plot the mapper graph:

``` r
mp$graph %>% plot()
```

<img src="man/figures/README-unnamed-chunk-7-1.png" width="100%" />

Or, for a better visualization, we use the `networkVis` package and
color the nodes using the mean value of the `x` variable of `X`:

``` r
mp %>% plot_mapper()
```

<img src="man/figures/README-unnamed-chunk-8-1.png" width="100%" />

Or color it by `y`:

``` r
mp %>% plot_mapper(data_column = 'y')
```

<img src="man/figures/README-unnamed-chunk-9-1.png" width="100%" />

## To do

-   Vignettes using mapper with factor variables
-   Ball Mapper documentation
-   Persistent homology examples
-   Data analysis using some vertices of the mapper + machine learning
