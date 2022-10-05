as_intervals = function(covering) {
  if ('intervals' %in% class(covering)) {
    covering
  } else {
    covering %>%
      as.matrix() %>%
      intervals::Intervals()
  }
}

calculate_pullback = function(covering, f_X) {
  points =
    matrix(c(f_X, f_X), ncol = 2) %>%
    as_intervals()

  intervals =
    covering %>%
    as_intervals()

  pullback = intervals::interval_overlap(from = intervals, to = points)

  names(pullback) = seq_along(pullback)

  pullback

}


