#' Ball mapper
#' @param distance_matrix A matrix of distances.
#' @param epsilon A non-negative number.
#' @param id A possible subset of indexes of distance_matrix.
#' @export

ball_mapper = function(X, distance_matrix, epsilon, id = NULL){
  # melhorar documentação do id; possibilidade de só passar o n e usar farthest points
  if (is.null(id)) id = seq_along(distance_matrix[,1])
  n = length(id)

  X_points_in_vertex = vector(mode = "list", length = n)
  i = 1
  for (i in seq_along(id)){
    X_points_in_vertex[[i]] = which(distance_matrix[id[i], ] <= epsilon, useNames = FALSE)
  }

  edges = list()
  i = n

  edges =
    seq_along(id) %>%
    furrr::future_map_dfr(function(i) {
      vec = sapply(X = X_points_in_vertex, FUN = function(x) any(x %in% X_points_in_vertex[[i]]))
      vec = which(vec)
      tibble(i = i, j = vec)
    })

  edges =
    edges %>%
    filter(i < j)

  graph =
    igraph::graph_from_edgelist(as.matrix(edges), directed = FALSE) %>%
    igraph::simplify(remove.loops = TRUE)

  igraph::V(graph)$name = seq_along(id)

  return(list(X = X, graph = graph, X_points_in_vertex = X_points_in_vertex))
}

\(x) {
  X = data.noisy_circle(n = 1000, radius = 10, sd = 0.5)
  Y = X
  Y$x = Y$x + 15
  X = bind_rows(X, Y)
  plot(X)
  X$z = 0
  X$w = 0
  X$v = 1
  X$u = 2

  distance_matrix = dist(X) %>% as.matrix()

  id = nrow(X)
  epsilon = 4

  bm = ball_mapper(distance_matrix, X = X, epsilon, id = sample(nrow(X), nrow(X) / 25))
  bm %>% plot_mapper(vector_of_values = X$x + X$y, use_physics = TRUE)

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
