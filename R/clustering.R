#' HDBScan clustering function
clust.hdbscan = function(
    distance_matrix, n_points_dist = NULL, min_pts_per_cluster = NULL, min_percent_points_per_cluster = 5
    ,put_all_outliers_in_a_single_cluster = FALSE
) {

  if (is.null(min_pts_per_cluster)) {
    min_pts_per_cluster = ceiling(n_points_dist * min_percent_points_per_cluster / 100)
  }

  # ensure that min_pts_per_cluster <= n_points_dist
  min_pts_per_cluster = min(min_pts_per_cluster, n_points_dist)

  # ensure that min_pts_per_cluster >= 2
  min_pts_per_cluster = max(min_pts_per_cluster, 2)

  clusters = dbscan::hdbscan(distance_matrix, minPts = min_pts_per_cluster)$cluster

  if (put_all_outliers_in_a_single_cluster == FALSE) {
    clusters = clusters %>% split_outliers()
  }

  clusters

}

#' First cutoff clustering function
clust.first_cutoff = function(distance_matrix, num_breaks_in_histogram_of_distances = 10, ...) {

  distance_object = distance_matrix %>% as.dist()

  dendrogram_of_distances = hclust(distance_object)

  histogram_of_distances = hist(distance_object, breaks = num_breaks_in_histogram_of_distances, plot = FALSE)
  first_empty_bin = which(histogram_of_distances$counts == 0)

  if (length(first_empty_bin) == 0) {
    clustering = rep(1, times = nrow(distance_matrix))
    return(clustering)
  }

  first_empty_bin = min(first_empty_bin)

  height_to_cut = histogram_of_distances$breaks[first_empty_bin]

  clustering = cutree(tree = dendrogram_of_distances, h = height_to_cut)
}

#' DBScan clustering function
clust.dbscan = function(
    distance_matrix, epsilon = 1, min_points_per_cluster = 1, border_points = TRUE, put_all_outliers_in_a_single_cluster = FALSE
    , ...
) {

  distance_object = distance_matrix %>% as.dist()

  clusters =
    dbscan::dbscan(
      x = distance_object, eps = epsilon, minPts = min_points_per_cluster, borderPoints = border_points
    ) %>%
    .$cluster

  if (put_all_outliers_in_a_single_cluster == FALSE) {
    clusters = clusters %>% split_outliers()
  }

  clusters
}


number_points_in_dist_object = function(n) {
  x = (1 + (sqrt(1 + 8 * n))) / 2

  ceiling(x)
}

#' Split the pullback of a covering
split_pullback = function(
    pullback, X_num = NULL, data = NULL, X = NULL, distance_matrix = NULL, distance_function = NULL, clustering_function = clustering_hdbscan
) {

  p <- progressr::progressor(along = pullback)

  splited_pullback =
    pullback %>%
    furrr::future_imap(function(pre_image, i) {

      # glue::glue('Clustering pullback {i}...') %>% print()
      p(glue::glue("Clustering pullback nº {i}..."))

      pre_image_size = length(pre_image)

      if (is.null(distance_matrix)) {
        pre_image_distance_matrix = distance_function(X_num[pre_image, ]) %>% as.matrix()
      } else {
        pre_image_distance_matrix = distance_matrix[pre_image, pre_image]
      }

      if (pre_image_size <= 1) {
        clustering = 1
      } else {
        clustering = clustering_function(
          distance_matrix = pre_image_distance_matrix, pre_image = pre_image, data = data, X = X
        )
      }

      clustering_formatted = paste0(i, ':', clustering)

      split(x = pre_image, f = clustering_formatted)
    })

}


split_outliers = function(x) {
  ids = which(x == 0)

  if (length(ids) == 0) {
    return(x)
  }

  x[ids] = seq_along(ids) + max(x, na.rm = TRUE)

  x

}


\(x) {
  ## cluster the moons data set with HDBSCAN
  library(dbscan)
  data(moons)
  plot(moons)

  res <- hdbscan(moons, minPts = 10)
  res$cluster

  plot(res)
  plot(moons, col = res$cluster + 1L)

  ## cluster the moons data set with HDBSCAN using Manhattan distances
  res <- hdbscan(dist(moons, method = "manhattan"), minPts = 5)
  plot(res)
  plot(moons, col = res$cluster + 1L)
}

