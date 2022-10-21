
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

Let’s fix come notation:

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
#>  $ 1 : int [1:83] 1 9 11 20 59 86 100 103 120 126 ...
#>  $ 2 : int [1:268] 1 2 4 8 9 11 20 24 31 38 ...
#>  $ 3 : int [1:290] 2 4 8 10 17 18 22 24 27 31 ...
#>  $ 4 : int [1:192] 10 17 18 22 27 29 30 43 49 50 ...
#>  $ 5 : int [1:163] 7 13 21 28 29 30 40 58 61 66 ...
#>  $ 6 : int [1:173] 7 13 15 21 23 28 32 34 36 40 ...
#>  $ 7 : int [1:201] 12 14 15 19 23 26 32 33 34 36 ...
#>  $ 8 : int [1:273] 3 5 6 12 14 19 25 26 33 35 ...
#>  $ 9 : int [1:263] 3 5 6 16 25 35 37 41 42 44 ...
#>  $ 10: int [1:94] 16 41 48 78 83 87 94 121 127 129 ...
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
