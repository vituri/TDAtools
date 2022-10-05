library(igraph)
X = generate_data$generate_data_noisy_circle(n = 100, radius = 10)
X = generate_data$generate_data_noisy_circle(n = 100, radius = 1)
X$x = X$x + 4

X = bind_rows(X, generate_data$generate_data_noisy_circle(100))
plot(X)

D = dist(X) %>% as.matrix()
hist(D, breaks = 5)

h = hclust(D %>% as.dist(), method = 'single')
plot(h)

h$height

ids = which(D <= max(h$height), arr.ind = TRUE, useNames = FALSE)
n_edges = nrow(ids)
plot(X)



i = 1
for (i in seq.int(n_edges)) {
  if (i == n_edges) next

  id1 = ids[i, 1]
  id2 = ids[i, 2]

  if (identical(id1, id2)) next

  vec = c(id1, id2)

  lines(X %>% slice(vec))
}


G =
  graph_from_edgelist(el = ids, directed = FALSE) %>%
  simplify()

is_connected(G)
components(G)

plot(G)

k = 50
knn = kNN(x = X, k = k)

plot(X)

i = 1
for (i in seq_along(X$x)) {
  vec = c(i, knn$id[i, ])
  lines(X %>% slice(vec), col = rainbow(k))
}

res = dbscan::hdbscan(x = X, minPts = 50)
plot(X, col = res$cluster)




data("DS3")
DS3
plot(DS3)
# use a shared neighborhood of 20 points and require 12 shared neighbors
cl <- jpclust(DS3, k = 20, kt = 12)
cl
cl$cluster %>% table()

plot(DS3, col = cl$cluster+1L, cex = .5)
# Note: JP clustering does not consider noise and thus,
# the sine wave points chain clusters together.

# use a precomputed kNN object instead of the original data.
nn <- kNN(DS3, k = 30)
nn

cl <- jpclust(nn, k = 20, kt = 12)
cl

# cluster with noise removed (use low pointdensity to identify noise)
d <- pointdensity(DS3, eps = 25)
hist(d, breaks = 20)
DS3_noiseless <- DS3[d > 110,]
plot(DS3_noiseless)

cl <- jpclust(DS3_noiseless, k = 20, kt = 10)
cl

plot(DS3_noiseless, col = cl$cluster+1L, cex = .5)

data("DS3")

# Out of k = 20 NN 7 (eps) have to be shared to create a link in the sNN graph.
# A point needs a least 16 (minPts) links in the sNN graph to be a core point.
# Noise points have cluster id 0 and are shown in black.
cl <- sNNclust(DS3, k = 20, eps = 7, minPts = 16)
plot(DS3, col = cl$cluster + 1L, cex = .5)

