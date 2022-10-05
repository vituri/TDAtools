

g <- make_tree(n = 10, mode = 'undirected')
g$name <- "Ring"
V(g)$name <- letters[1:vcount(g)]
E(g)$weight <- runif(ecount(g))

plot(g)

g2 <- contract(graph = g, mapping = rep(1:5, each=2),vertex.attr.comb = toString) %>% simplify()

## graph and edge attributes are kept, vertex attributes are
## combined using the 'toString' function.
print(g2, g=TRUE, v=TRUE, e=TRUE)
plot(g2)
