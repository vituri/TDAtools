remotes::install_github("rrrlw/ggtda", vignettes = TRUE)
devtools::install_github("rrrlw/ripserr")


# generate a noisy circle
n <- 36; sd <- .2
set.seed(0)
t <- stats::runif(n = n, min = 0, max = 2*pi)
d <- data.frame(
  x = cos(t) + stats::rnorm(n = n, mean = 0, sd = sd),
  y = sin(t) + stats::rnorm(n = n, mean = 0, sd = sd)
)
# compute the persistent homology
ph <- as.data.frame(ripserr::vietoris_rips(as.matrix(d), dim = 1))
print(head(ph, n = 12))
#>    dimension birth      death
#> 1          0     0 0.02903148
#> 2          0     0 0.05579919
#> 3          0     0 0.05754819
#> 4          0     0 0.06145429
#> 5          0     0 0.10973364
#> 6          0     0 0.11006440
#> 7          0     0 0.11076601
#> 8          0     0 0.12968679
#> 9          0     0 0.14783527
#> 10         0     0 0.15895889
#> 11         0     0 0.16171041
#> 12         0     0 0.16548606
ph <- transform(ph, dim = as.factor(dimension))


# fix a proximity for a Vietoris complex
prox <- 2/3

# attach *ggtda*
library(ggtda)
# visualize disks of fixed radii and the Vietoris complex for this proximity



p_d <- ggplot(d, aes(x = x, y = y)) +
  theme_bw() +
  coord_fixed() +
  stat_disk(radius = prox/2, fill = "aquamarine3") +
  geom_point()
p_sc <- ggplot(d, aes(x = x, y = y)) +
  theme_bw() +
  coord_fixed() +
  stat_vietoris2(diameter = prox, fill = "darkgoldenrod") +
  stat_vietoris1(diameter = prox, alpha = .25) +
  stat_vietoris0()
# combine the plots
gridExtra::grid.arrange(
  p_d, p_sc,
  layout_matrix = matrix(c(1, 2), nrow = 1)
)

# visualize the persistence data, indicating cutoffs at this proximity
p_bc <- ggplot(ph,
               aes(start = birth, end = death, colour = dim)) +
  theme_barcode() +
  geom_barcode() +
  labs(x = "Diameter", y = "Homological features") +
  geom_vline(xintercept = prox, color = "darkgoldenrod", linetype = "dashed")
p_pd <- ggplot(ph) +
  theme_persist() +
  coord_fixed() +
  stat_persistence(aes(start = birth, end = death, colour = dim, shape = dim)) +
  geom_abline(intercept = 0, slope = 1, color = "darkgray") +
  labs(x = "Birth", y = "Death") +
  lims(x = c(0, 0.8), y = c(0, NA)) +
  geom_point(data = data.frame(x = prox), aes(x, x),
             colour = "darkgoldenrod", shape = "diamond", size = 4)
# combine the plots
gridExtra::grid.arrange(
  p_bc, p_pd,
  layout_matrix = matrix(c(1, 2), nrow = 1)
)
