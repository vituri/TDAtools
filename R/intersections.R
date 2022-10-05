interval_intersections = function(covering) {

  intervals =
    covering %>%
    as_intervals()

  interval_intersections = intervals::interval_overlap(from = intervals, to = intervals, check_valid = FALSE)

}
