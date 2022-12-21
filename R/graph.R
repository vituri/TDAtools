edge_combinations = function(x) {

  if (length(x) == 2) {
    edge_matrix = data.frame(v1 = x[1], v2 = x[2])
    return(edge_matrix)
  }

  edge_matrix =
    combn(x = x, m = 2) %>%
    t() %>%
    as.data.frame() %>%
    set_names(c('v1', 'v2'))

  edge_matrix
}

make_mapper_edges = function(clustered_pullback) {
  pb_x =
    clustered_pullback %>%
    flatten() %>%
    furrr::future_imap_dfr(function(pb, i) {
      data.frame(X_points = pb, Vertex = i)
    }) %>%
    as_tibble() %>%
    arrange(X_points)

  clustered_pullback_intersections =
    pb_x %>%
    group_by(X_points) %>%
    summarise(Edges = list(Vertex), N_edges = n()) %>%
    ungroup() %>%
    filter(N_edges > 1) %>%
    distinct(Edges) %>%
    pull(Edges)

  mapper_edges =
    clustered_pullback_intersections %>%
    map_dfr(edge_combinations) %>%
    distinct()
}

make_mapper_graph = function(mapper_vertices, mapper_edges) {
  G = igraph::graph_from_data_frame(
    d = mapper_edges, directed = FALSE, vertices = mapper_vertices
    )

  G
}
