cover.uniform = function(x = NULL, num_intervals = 10, percent_overlap = 50) {

  if (is.null(x)) {
    return(function(x) cover.uniform(x = x, num_intervals = num_intervals, percent_overlap = percent_overlap))
  }

  step_size = (max(x) - min(x)) / (num_intervals - 1)

  if (step_size == 0) {
    stop('min(x) must be different from max(x)!')
  }

  centers = seq.default(from = min(x), to = max(x), length.out = num_intervals)

  radius = step_size / (2 * (1 - percent_overlap / 100))

  intervals =
    matrix(
      c(centers - radius, centers + radius)
      ,ncol = 2
      ) %>%
    as_intervals()

  intervals
}

cover.equally_distributed = function(x = NULL, num_intervals = 10, percent_overlap = 50) {
  ## !!! descobrir como fazer
  ## ideia: todo intervalo tem que conter x% dos pontos (na medida do possível)
}
