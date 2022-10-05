pullback

G = make_empty_graph(n = nrow(X))
plot(G)

for (i in seq_along(pullback)) {

  if (length(pullback[[i]]) <= 1) next

  edges =
    pullback[[i]] %>%
    combn(m = 2, simplify = TRUE) %>%
    t()

  G =
    G %>%
    add_edges(edges)

}

plot(G)

G =
  G %>%
  simplify()

plot(G)



intervals_per_point %>%
  .[1:2] %>%
  set_names(1:2 %>% as.character()) %>%
  bind_rows()

g = graph_from_literal(A, A-B, B, C)
plot(g)

g2 = contract(graph = g, mapping = c(1, 2, 2))
plot(g2)

g3 = contract(graph = g2, mapping = c(1, 2, 2))

g <- make_empty_graph(n = 5) %>%
  add_edges(c(1,2, 2,3, 3,4, 4,5)) %>%
  set_edge_attr("color", value = "red") %>%
  add_edges(c(5,1), color = "green")
E(g)[[]]
plot(g)


g <- make_ring(10)
g %>%
  rewire(each_edge(p = .1, loops = FALSE)) %>%
  plot(layout=layout_in_circle)
print_all(rewire(g, with = keeping_degseq(niter = vcount(g) * 10)))
rewire(g, with = keeping_degseq(niter = vcount(g) * 10)) %>% plot()
