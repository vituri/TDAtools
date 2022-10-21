new_mapper = function() {
  list()
}

add_data = function(mp, data) {

  if (!is.data.frame(data)) {
    data %<>% as.data.frame()
  }

  mp$data = data

  mp$X = data %>% select(where(is.numeric))

  invisible(mp)
}

add_X = function(mp, X) {
  mp$X = X

  invisible(mp)
}

add_distance = function(mp, distance_matrix = dist) {

  if (is.function(distance_matrix)) {
    mp$distance_matrix = distance_matrix(mp$X) %>% as.matrix()
  } else {
    mp$distance_matrix = distance_matrix %>% as.matrix()
  }

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
    pullback = mp$pullback, distance_matrix = mp$distance_matrix, clustering_function = mp$clustering_function
    ,data = mp$data, X = mp$X
  )

  mp$flattened_clustered_pullback = mp$clustered_pullback %>% flatten()

  mp$vertices = mp$flattened_clustered_pullback %>% names()

  mp$edges = make_mapper_edges(mp$clustered_pullback)

  mp$graph = make_mapper_graph(mapper_vertices = mp$vertices, mapper_edges = mp$edges)

  invisible(mp)
}

#' Calculate the mapper graph of a set
#' @param X A dataframe or matrix.
#' @param distance_matrix A dist object or matrix of distances; or a function that return such object when applied to X.
#' @param f_X A numeric vector with length equal to the rows of X; or a function that return such a vector when applied to X.
#' @param covering A matrix with intervals or a function that returns such an matrix.
#' @param clustering_function A clustering function.
#' @return A mapper object.
#' @export
#' @examples mp = mapper()
#' mp %>% plot_mapper()
mapper = function(
    X = data.noisy_circle()
    ,distance_matrix = stats::dist
    ,f_X = X[1,]
    ,covering = cover.uniform
    ,clustering_function = clust.first_cutoff
) {
  mp =
    new_mapper() %>%
    add_data(X) %>%
    add_distance(distance_matrix = distance_matrix) %>%
    add_filter(f_X) %>%
    add_covering(covering = covering) %>%
    add_clustering_method(clustering_function = clustering_function) %>%
    calculate_mapper_graph()

  # plot(mp$graph)

  invisible(mp)
}

\(x) {

  X = data.noisy_circle(n = 1000, radius = 2)
  D = dist(X) %>% as.matrix()

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

  mp =
    mapper(
      X = X
      ,f_X = f_X
    )

  mp$pullback
  mp$clustered_pullback
  mp$graph

  mp$graph %>% plot()

  mp %>% plot_mapper()
}

