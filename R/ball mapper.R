#' Ball mapper
#' @param D A matrix of distances.
#' @param epsilon A non-negative number.
#' @param id A possible subset of indexes of D.
#' @export

ball_mapper = function(D, epsilon, id = NULL){
  # melhorar documentação do id; possibilidade de só passar o n e usar farthest points
  if (is.null(id)) id = seq_along(D[,1])
  n = length(id)

  points_in_vertex = vector(mode = "list", length = n)
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

  ball_mapper_graph =
    igraph::graph_from_edgelist(as.matrix(edges), directed = FALSE) %>%
    igraph::simplify(remove.loops = TRUE)

  return(list(ball_mapper_graph = ball_mapper_graph, points_in_vertex = points_in_vertex))
}

test_ball_mapper = function() {
  X = data.noisy_circle(n = 1000, radius = 10, sd = 0.5)
  Y = X
  Y$x = Y$x + 15
  X = bind_rows(X, Y)
  plot(X)
  X$z = 0
  X$w = 0
  X$v = 1
  X$u = 2

  D = dist(X) %>% as.matrix()

  id = nrow(X)
  epsilon = 4

  l = ball_mapper(D, epsilon, id = sample(nrow(X), nrow(X) / 10))
  G = l$ball_mapper_graph

  l$points_in_vertex

  coords = igraph::layout_with_fr(graph = G)
  igraph::plot.igraph(G, layout = coords)
}

\(x) {

  library(BallMapper)

  var <- seq(from=0,to=6.3,by=0.1)
  points <- as.data.frame( cbind( sin(var),cos(var) ) )
  plot(points)
  values <- points %>% select(V1)
  epsilon <- 0.25
  l <- BallMapper(points,values,epsilon)

  l

  l %>% color_by_distance_to_reference_points()



}
