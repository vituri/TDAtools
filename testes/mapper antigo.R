devtools::install_github("paultpearson/TDAmapper")
library(TDAmapper)

require(fastcluster)

m1 <- mapper1D(
  distance_matrix = dist(data.frame( x=2*cos(0.5*(1:100)), y=sin(1:100) )),
  filter_values = 2*cos(0.5*(1:100)),
  num_intervals = 10,
  percent_overlap = 50,
  num_bins_when_clustering = 10)

library(igraph)

g1 <- graph.adjacency(m1$adjacency, mode="undirected")
plot(g1, layout = layout.auto(g1) )

X = data.frame(x=2*cos(1:100), y=sin(1:100))
plot(X)

m2 <- mapper2D(
  distance_matrix = dist(X),
  filter_values = list( 2*cos(1:100), sin(1:100) ),
  num_intervals = c(5,5),
  percent_overlap = 50,
  num_bins_when_clustering = 10)

g2 <- graph.adjacency(m2$adjacency, mode="undirected")
plot(g2, layout = layout.auto(g2) )

set.seed("1")
t <- runif(100, min=1, max=6.3) # theta
X <- data.frame( x = c( t*cos(t), -t*cos(t) ), y = c( t*sin(t), -t*sin(t) ) )
d <- dist(X)
plot(X[,1], X[,2])

filter <- X[,2] # height projection
num_intervals <- 10
percent_overlap <- 50
num_bins_when_clustering <- 10

m3 <- mapper1D(
  distance_matrix = d,
  filter_values = filter,
  # num_intervals = 10, # use default
  # percent_overlap = 50, # use default
  # num_bins_when_clustering = 10 # use default
)

g3 <- graph.adjacency(m3$adjacency, mode="undirected")
plot(g3, layout = layout.auto(g3) )
