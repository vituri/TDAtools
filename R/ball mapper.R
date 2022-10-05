#' Ball mapper
#' @param X Matrix of distances
#' @param epsilon A non-negative number
#' @param id A possible subset of indexes of X
#' @export

ball_mapper = function(D, epsilon, id = NULL){
  # melhorar documentação do id; possibilidade de só passar o n e usar farthest points
  if (is.null(id)) id = seq_along(D[,1])
  n = length(id)

  points_in_vertex = list()
  i = 1
  for (i in seq_along(id)){
    points_in_vertex[[i]] = which(D[id[i], ] <= epsilon, useNames = FALSE)
  }

  edges = list()
  i = n

  edges =
    seq_along(id) %>%
    map_dfr(function(i) {
      vec = sapply(X = points_in_vertex, FUN = function(x) any(x %in% points_in_vertex[[i]]))
      vec = which(vec)
      tibble(i = i, j = vec)
    })

  edges =
    edges %>%
    filter(i < j)

  mapper_graph =
    igraph::graph_from_edgelist(as.matrix(edges), directed = FALSE) %>%
    igraph::simplify(remove.loops = TRUE)

  return(list(mapper_graph = mapper_graph, points_in_vertex = points_in_vertex))
}

test_ball_mapper = function() {
  X = generate_data_noisy_circle(n = 1000, radius = 10, sd = 0.5)
  Y = X
  Y$x = Y$x + 15
  X = bind_rows(X, Y)
  D = dist(X) %>% as.matrix()
  plot(X)
  id = nrow(X)
  epsilon = 4

  l = ball_mapper(D, epsilon, id = sample(nrow(X), nrow(X) / 10))
  G = l$mapper_graph

  l$points_in_vertex

  coords = igraph::layout_with_fr(graph = G)

  igraph::plot.igraph(G, layout = coords)
}
