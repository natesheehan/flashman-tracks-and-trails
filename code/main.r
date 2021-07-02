source("code/libs.r")
source("code/helpers.r")
source("code/get_data.r")

#Convert data to matrix and small matrix for testing
fal_mat = raster_to_matrix(fal_school)
fal_small = resize_matrix(fal_mat, 0.25)


# Create Basemap based on lat long range of site --------------------------
lat_range = c(50.159382, 50.161639)
long_range = c(-5.098562,-5.094943)

utm_bbox = convert_coords(lat = lat_range,
                          long = long_range,
                          to = crs(fal_school))

extent_zoomed = extent(utm_bbox[1], utm_bbox[2], utm_bbox[3], utm_bbox[4])
fal_zoom = crop(fal_school, extent_zoomed)
fal_zoom_mat = raster_to_matrix(fal_zoom)

basemap = fal_zoom_mat %>%
  sphere_shade(
    texture = create_texture(
      "#f5dfca",
      "#63372c",
      "#dfa283",
      "#195f67",
      "#c2d1cf",
      cornercolors = c("#ffc500", "#387642", "#d27441", "#296176")
    ),
    sunangle = 0,
    colorintensity = 5
  ) %>%
  add_shadow(lamb_shade(fal_zoom_mat), 0.2) %>%
  add_overlay(
    generate_altitude_overlay(
      height_shade(fal_zoom_mat, texture = "#91aaba"),
      fal_zoom_mat,
      start_transition = min(fal_zoom_mat) -
        200,
      end_transition = max(fal_zoom_mat)
    )
  )
# Create overlays for DTM data --------------------------------------------
#Route overlay
fal_lines = st_transform(p, crs = crs(fal_school))

#OS roads overlay
osm_bbox = c(long_range[1], lat_range[1], long_range[2], lat_range[2])
fal_highway = opq(osm_bbox) %>%
  add_osm_feature("highway") %>%
  osmdata_sf()

fal_footpaths = subset(fal_roads,
                       highway == "footway")

fal_cyclepaths = subset(fal_roads,
                        highway == "cycleway")

fal_roads = subset(
  fal_roads,
  highway = c(
    "unclassified",
    "secondary",
    "tertiary",
    "residential",
    "service"
  )
)

fal_footpaths = st_transform(fal_footpaths$geometry, crs = crs(fal_school))
fal_roads = st_transform(fal_roads$geometry, crs = crs(fal_school))
fal_cyclepaths = st_transform(fal_cyclepaths$geometry, crs = crs(fal_school))
resting_area = st_transform(resting_area$geometry, crs = crs(fal_school))

# Plot map ----------------------------------------------------------------
basemap %>%
  add_overlay(
    generate_line_overlay(
      fal_lines,
      extent = extent_zoomed,
      linewidth = 4,
      color = "#2d8a91",
      heightmap = fal_zoom_mat
    )
  ) %>%
  add_overlay(
    generate_line_overlay(
      resting_area,
      extent = extent_zoomed,
      linewidth = 4,
      color = "black",
      heightmap = fal_zoom_mat
    )
  ) %>%
  plot_map()

#Plot only route
l = points2line_trajectory(pp)
plot(l)

