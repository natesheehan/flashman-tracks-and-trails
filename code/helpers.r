# Convert to coordinate system specified by EPSG code ----------------------------------------------------------
convert_coords = function(lat, long, from = CRS("+init=epsg:4326"), to) {
  data = data.frame(long = long, lat = lat)
  coordinates(data) = ~ long + lat
  proj4string(data) = from
  #
  xy = data.frame(sp::spTransform(data, to))
  colnames(xy) = c("x", "y")
  return(unlist(xy))
}
# Calculate route points as line ------------------------------------------
points2line_trajectory = function(p) {
  c = st_coordinates(p)
  i = seq(nrow(p) - 2)
  l = purrr::map(i, ~ sf::st_linestring(c[.x:(.x + 1),]))
  s = purrr::map_dbl(i, function(x) {
    geosphere::distHaversine(c[x,], c[(x + 1),]) /
      as.numeric(p$time[x + 1] - p$time[x])
  })
  lfc = sf::st_sfc(l)
  a = seq(length(lfc)) + 1 # sequence to subset
  p_data = cbind(sf::st_set_geometry(p[a,], NULL), s)
  sf::st_sf(p_data, geometry = lfc)
}