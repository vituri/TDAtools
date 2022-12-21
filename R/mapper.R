new_mapper = function() {
  list()
}

# add_data = function(mp, data) {
#
#   if (!is.data.frame(data)) {
#     data %<>% as.data.frame()
#   }
#
#   mp$data = data
#
#   mp$X = data %>% select(where(is.numeric))
#
#   invisible(mp)
# }

add_X = function(mp, X) {

  mp$X = X
  mp$X_num = X %>% select(where(is.numeric)) %>% as.matrix()

  invisible(mp)
}

add_distance = function(mp, distance = dist) {

  mp$distance = distance

  invisible(mp)
}

add_filter = function(mp, f_X) {
  if (is.function(f_X)) {
    mp$f_X = f_X(mp$X)
  } else {
    mp$f_X = f_X
  }

  invisible(mp)
}

add_covering = function(mp, covering = partial(cover.uniform, num_intervals = 10, percent_overlap = 50)) {
  if (is.function(covering)) {
    mp$covering = covering(mp$f_X) %>% as_intervals()
  } else {
    mp$covering = covering %>% as_intervals()
  }

  invisible(mp)
}

add_clustering_method = function(mp, clustering_function = clust.first_cutoff) {
  mp$clustering_function = clustering_function

  invisible(mp)
}


calculate_mapper_graph = function(mp) {

  mp$pullback = calculate_pullback(covering = mp$covering, f_X = mp$f_X)

  mp$clustered_pullback = split_pullback(
    pullback = mp$pullback
    ,X_num = mp$X_num
    ,distance_matrix = if (is_dist_or_matrix(mp$distance)) mp$distance
    ,distance_function = if (is.function(mp$distance)) mp$distance
    ,clustering_function = mp$clustering_function
    ,data = mp$data, X = mp$X
  )


  mp$X_points_in_vertex = mp$clustered_pullback %>% flatten()

  mp$vertices = mp$X_points_in_vertex %>% names()

  mp$edges = make_mapper_edges(mp$clustered_pullback)

  mp$graph = make_mapper_graph(mapper_vertices = mp$vertices, mapper_edges = mp$edges)

  invisible(mp)
}

#' Calculate the mapper graph of a set
#' @param X A dataframe or matrix.
#' @param distance A dist object or matrix of distances; or a function that return such object when applied to X.
#' @param f_X A numeric vector with length equal to the rows of X; or a function that return such a vector when applied to X.
#' @param covering A matrix with intervals or a function that returns such an matrix.
#' @param clustering_function A clustering function.
#' @return A mapper object.
#' @export
#' @examples mp = mapper()
#' mp %>% plot_mapper()
mapper = function(
    X = data.noisy_circle()
    ,distance = stats::dist
    ,f_X = X[1,]
    ,covering = cover.uniform
    ,clustering_function = clust.first_cutoff
) {
  mp =
    new_mapper() %>%
    add_X(X) %>%
    add_distance(distance = distance) %>%
    add_filter(f_X) %>%
    add_covering(covering = covering) %>%
    add_clustering_method(clustering_function = clustering_function) %>%
    calculate_mapper_graph()

  # plot(mp$graph)

  invisible(mp)
}

\(x) {

  library(progressr)
  handlers(global = TRUE)
  handlers("progress")

  X = data.noisy_circle(n = 50000, radius = 2)
  # D = dist(X) %>% as.matrix()
  D = \(x) dist(x)

  f_X = X$x

  faixa = ggplot2::cut_interval(f_X, n = 50)
  cores = rainbow(nlevels(faixa))[as.integer(faixa)]
  plot(X, col = cores)

  X$z = 0
  X$w = 0

  #   mp =
  #     new_mapper() %>%
  #     add_data(X) %>%
  #     add_distance() %>%
  #     add_filter(f_X) %>%
  #     add_covering() %>%
  #     add_clustering_method(clustering_function = partial(clust.dbscan, epsilon = 0.2, min_points_per_cluster = 2, put_all_outliers_in_a_single_cluster = FALSE)) %>%
  #     calculate_mapper_graph()

  # debugonce(calculate_mapper_graph)

  library(future)
  plan(multisession)
  # plan(sequential)

  tictoc::tic()
  mp =
    mapper(
      X = X
      ,f_X = f_X
      ,covering = \(x) cover.uniform(x = x, num_intervals = 15, percent_overlap = 20)
      # ,distance = D
      ,clustering_function = partial(clust.first_cutoff, num_breaks_in_histogram_of_distances = 10)
    )
  tictoc::toc()

  mp$pullback
  mp$clustered_pullback
  mp$graph

  mp$graph %>% plot()

  mp$X
  mp %>% plot_mapper(vector_of_values = 'x')
}

