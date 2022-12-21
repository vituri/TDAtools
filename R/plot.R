# http://www.sthda.com/english/articles/33-social-network-analysis/136-network-analysis-and-manipulation-using-r/
# https://stackoverflow.com/questions/64655646/r-display-popup-information-when-mouse-hovers-over-graph-visnetwork

library(igraph)
library(visNetwork)

\(x) {

  X = data.noisy_circle(n = 1000, radius = 2)
  D = dist(X) %>% as.matrix()

  f_X = X$x

  faixa = ggplot2::cut_interval(f_X, n = 50)
  cores = rainbow(nlevels(faixa))[as.integer(faixa)]
  plot(X %>% select(x, y), col = cores)

  X$z = 0
  X$w = 0
  X$letra = X$y %>% round() %>% `+`(3) %>% letters[.] %>% factor()

  mp =
    new_mapper() %>%
    add_data(X) %>%
    add_distance() %>%
    add_filter(f_X) %>%
    add_covering() %>%
    add_clustering_method() %>%
    calculate_mapper_graph()

  mp$pullback
  mp$clustered_pullback
  mp$graph

  mp$graph %>% plot()

  mp %>%
    plot_mapper(data_column = 'letra')
}

\(x) {

  X = heplots::Diabetes %>% as_tibble()
  f_X = X$relwt

  mp =
    new_mapper() %>%
    add_data(X) %>%
    add_distance() %>%
    add_filter(f_X) %>%
    add_covering(covering = partial(cover.uniform, num_intervals = 20, percent_overlap = 50)) %>%
    add_clustering_method() %>%
    calculate_mapper_graph()

  mp$pullback
  mp$clustered_pullback
  mp$graph

  mp$graph %>% plot()

  mp %>%
    plot_mapper(data_column = names(X)[6])
}

#' Plot the mapper graph interactively
#' @export
#' @param mp The mapper graph
#' @param vector_of_values A vector with one value per each point of `X`. These values will be aggregated with `aggregate_function` to color each vertex.
#' If a string, then will be taken as a column name of `X`.
#' @param aggregate_function A function to apply to each vertex `v` of `X`.
#' @param color_scale A color scale.
#' @details Let `v` be a vertex and `x1`, ..., `xn` the points of `X` in `v`.
#' Denote by `y1`, ..., `yn` the corresponding values of `vector_of_values` associated to `x1`, ..., `xn`. We then apply the
#' `aggregate_function` to `y1`, ..., `yn` to obtain a value, which will then be the color of `v`.
plot_mapper = function(
    mp, vector_of_values = names(mp$X)[1], vector_name = NULL, aggregate_function = f
    ,color_scale = viridis::viridis(10), use_physics = TRUE
) {
  G = mp$graph

  graph_net = visNetwork::toVisNetworkData(G)

  if (length(vector_of_values) == 1) {
    main_text = glue::glue('Coloring by {vector_of_values}')
    vector_of_values = mp$X[[vector_of_values]]
  } else {

    if (is.null(vector_name)) vector_name = 'vector'

    main_text = glue::glue('Coloring by {vector_name}')
  }

  l =
    igraph::V(G)$name %>%
    furrr::future_map(function(vertex_name) {

      ids = mp$X_points_in_vertex[[vertex_name]]

      value = vector_of_values[ids] %>% aggregate_function()
      size = mp$X_points_in_vertex[[vertex_name]] %>% length()

      list(value = value, size = size)
    }) %>%
    transpose()

  size = l$size %>% unlist()
  values = l$value %>% unlist()

  if (is.numeric(vector_of_values)) {
    colors = values %>% color_vector(colors = color_scale)
  } else {
    values = values %>% factor()
    values_as_integer = values %>% as.integer()
    pallete = RColorBrewer::brewer.pal(n = min(max(values_as_integer), 12), name = 'Paired')
    colors = pallete[values_as_integer %% 12]
  }

  graph_net$nodes$color = colors
  graph_net$nodes$value = size
  graph_net$nodes$title = glue::glue('Size: {size} <br>Value: {values}')
  graph_net$nodes$label = values

  visNetwork::visNetwork(nodes = graph_net$nodes, edges = graph_net$edges, main = main_text) %>%
    visNetwork::visLayout(randomSeed = 9, improvedLayout = TRUE) %>%
    visNetwork::visPhysics(solver = 'repulsion', enabled = use_physics)
}

# coloring plots ----------------------------------------------------------
# f = function(x) {
#   UseMethod()
# }


f = function(x) {
  if (is.numeric(x)) {
    value = mean(x)
  } else {
    value =
      tibble(
        x = x
      ) %>%
      count(x) %>%
      slice_max(n) %>%
      slice_head(n = 4) %>%
      pull(x) %>%
      glue::glue_collapse(sep = '/\n')
  }

  return(value)
}
