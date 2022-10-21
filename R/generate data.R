#' Noisy circle data
#' @param n The amount of points in the sample.
#' @param radius The radius of the circle.
#' @param sd The standard deviation.
#' @returns A tibble.
#' @export
#' @examples X = data.noisy_circle()
#' plot(X)

data.noisy_circle = function(n = 1000, radius = 1, sd = 0.1) {
  t <- stats::runif(n = n, min = 0, max = 2*pi)
  d <- data.frame(
    x = radius*cos(t) + stats::rnorm(n = n, mean = 0, sd = sd),
    y = radius*sin(t) + stats::rnorm(n = n, mean = 0, sd = sd)
  ) %>%
    as_tibble()

  d
}
