color_vector = function(x, colors = rainbow(10)) {
  cores = colorRamp(colors)(scales::rescale(x = x))
  cores = rgb(red = cores[,1], green = cores[,2], blue = cores[,3], maxColorValue = 255)
}


extract_X_points_by_vertex = function(m = NULL, X = NULL, vertices = NULL) {
  if (is.null(vertices)) {
    return(X)
  }

  ids = m$vertices[as.character(vertices)] %>% unlist(use.names = FALSE)

  X_points =
    X %>%
    slice(ids)

  X_points
}

extract_amount_X_points_per_vertex = function(m, rescale_function = identity) {
  amount_X_points_per_vertex =
    m$vertices %>%
    map(length) %>%
    unlist(use.names = FALSE) %>%
    rescale_function()

  amount_X_points_per_vertex =
    scales::rescale(x = amount_X_points_per_vertex, to = c(3, 20))

  amount_X_points_per_vertex

}

format_graph_from_mapper = function(m) {

  G = m$as_igraph()

  # browser()

  c('color') %>%
    walk(\(name) G <<- remove.edge.attribute(graph = G, name = name))

  c('size', 'label') %>%
    walk(\(name) G <<- remove.vertex.attribute(graph = G, name = name))

  V(G)$size = m %>% extract_amount_X_points_per_vertex()

  # V(G)$color = m %>%
  G

}

if_function_then_eval = function(.x, ...) {
  if (is.function(x)) {
    .x(...)
  } else {
    .x
  }
}
