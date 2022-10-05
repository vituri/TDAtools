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

plot_mapper = function(mp, data_column = names(mp$data)[1], color_vertex_by = f, color_scale = viridis::viridis(10)) {
  # browser()
  G = mp$graph

  graph_net = toVisNetworkData(G)

  # arrumar tamanho dos vértices!!

  vertex_name = '1:1'
  vertex_name = '9:1'

  l =
    igraph::V(G)$name %>%
    map(function(vertex_name) {

      ids = mp$flattened_clustered_pullback[[vertex_name]]

      value = mp$data %>% slice(ids) %>% .[[data_column]] %>% f()
      size = mp$flattened_clustered_pullback[[vertex_name]] %>% length()

      list(value = value, size = size)
    }) %>%
    transpose()

  size = l$size %>% unlist()
  values = l$value %>% unlist()

  if (is.numeric(mp$data[[data_column]])) {
    colors = values %>% color_vector(colors = color_scale)
  } else {
    values = values %>% factor()
    values_as_integer = values %>% as.integer()
    pallete = RColorBrewer::brewer.pal(n = min(max(values_as_integer), 12), name = 'Paired')
    colors = pallete[values_as_integer %% 12]
  }

  graph_net$nodes$color = colors

  graph_net$nodes$value = size
  # graph_net$nodes$size = size
  graph_net$nodes$title = glue::glue('Size: {size} <br>Value: {values}')

  graph_net$nodes$label = values

  visNetwork(nodes = graph_net$nodes, edges = graph_net$edges, main = glue::glue('Coloring by {data_column}')) %>%
    visLayout(randomSeed = 9, improvedLayout = TRUE)
}

# coloring plots ----------------------------------------------------------

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
