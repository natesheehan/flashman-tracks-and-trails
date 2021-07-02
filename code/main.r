source("code/libs.r")
source("code/helpers.r")
source("code/get_data.r")

#Convert data to matrix and small matrix for testing
fal_mat = raster_to_matrix(fal_school)
fal_small = resize_matrix(fal_mat, 0.25)


# Create Basemap based on lat long range of site --------------------------
lat_range = c(50.158314, 50.162294)
long_range = c(-5.102861,-5.093012)

utm_bbox = convert_coords(lat = lat_range,
                          long = long_range,
                          to = crs(fal_school))

extent_zoomed = extent(utm_bbox[1], utm_bbox[2], utm_bbox[3], utm_bbox[4])
fal_zoom = crop(fal_school, extent_zoomed)
fal_zoom_mat = raster_to_matrix(fal_zoom)

basemap = fal_zoom_mat %>%
  height_shade() %>%
  add_overlay(sphere_shade(fal_zoom_mat, texture = "desert", colorintensity = 5),
              alphalayer = 0.5) %>%
  add_shadow(lamb_shade(fal_zoom_mat), 0) %>%
  add_shadow(ambient_shade(fal_zoom_mat), 0) %>%
  add_shadow(texture_shade(
    fal_zoom_mat,
    detail = 8 / 10,
    contrast = 9,
    brightness = 11
  ),
  0.1)



# Create overlays for DTM data --------------------------------------------
#Route overlay
fal_lines = st_transform(p, crs = crs(fal_school))

#OS roads overlay
osm_bbox = c(long_range[1], lat_range[1], long_range[2], lat_range[2])
fal_highway = opq(osm_bbox) %>%
  add_osm_feature("highway") %>%
  osmdata_sf()
fal_roads = st_transform(fal_highway$osm_lines, crs = crs(fal_school))


# Plot map ----------------------------------------------------------------
basemap %>%
  add_overlay(
    generate_line_overlay(
      fal_lines,
      extent = extent_zoomed,
      linewidth = 4,
      color = "white",
      heightmap = fal_zoom_mat
    )
  ) %>%
  add_overlay(
    generate_line_overlay(
      fal_roads,
      extent = extent_zoomed,
      linewidth = 2,
      color = "green",
      heightmap = fal_zoom_mat
    )
  ) %>%
  plot_map()
