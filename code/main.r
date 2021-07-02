source("code/libs.r")
source("code/helpers.r")
source("code/get_data.r")

#Convert data to matrix and small matrix for testing
fal_mat = raster_to_matrix(fal_school)
fal_small = resize_matrix(fal_mat, 0.25)

# Create Basemap based on lat long range of site --------------------------
lat_range = c(50.158378, 50.162544)
long_range = c(-5.102861, -5.090522)


utm_bbox = convert_coords(lat = lat_range,
                          long = long_range,
                          to = crs(fal_school))

extent_zoomed = extent(utm_bbox[1], utm_bbox[2], utm_bbox[3], utm_bbox[4])
fal_zoom = crop(fal_school, extent_zoomed)
fal_zoom_mat = raster_to_matrix(fal_zoom)

maxcolor = "#e6dbc8"
mincolor = "#b6bba5"
contour_color = "#7d4911"
basemap = fal_zoom_mat %>%
  height_shade() %>%
  add_overlay(sphere_shade(fal_zoom_mat, texture = "bw", colorintensity = 5),
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
resting_area = st_transform(resting_area, crs = crs(fal_school))


dd = subset(pp, select = "geometry")
View(dd)
dd$name = "Table top"
dd = dd[-(16:22),]
dd = dd[-(1:7),]
dd = dd[-(8:14),]
dd = dd[-(8),]
dd = dd[-(10),]
dd = dd[-(1:4),]
dd$name[1] = "Resting Area"
dd$name[2] = "Drain"
dd$name[3] = "Scrub to clear"
dd$name[4] = "Path to clear"
dd$name[5] = "Resting Area"
dd$name[1] = "Table top"

dd = st_transform(dd, crs = crs(fal_school))
# Plot map ----------------------------------------------------------------
basemap %>%
  add_overlay(
    generate_line_overlay(
      fal_lines,
      extent = extent_zoomed,
      linewidth = 6,
      color = "#2d8a91",
      heightmap = fal_zoom_mat
    )
  ) %>%
  add_overlay(generate_label_overlay(dd, extent = extent_zoomed,
                                     text_size = 2, point_size = 1, color = "black",
                                     halo_color = "white", halo_expand = 10, 
                                     halo_blur = 20, halo_alpha = 0.8,
                                     seed=1,
                                     heightmap = fal_zoom_mat, data_label_column = "name")) %>% 
  add_overlay(
    generate_line_overlay(
      resting_area,
      extent = extent_zoomed,
      linewidth = 6,
      color = "black",
      heightmap = fal_zoom_mat
    )
  ) %>% plot_map(title_text = "Falmouth School Bike Track (Flashman Track and Trails)", title_offset = c(15,15),
           title_bar_color = "grey5", title_color = "white", title_bar_alpha = 1)

basemap %>%
  add_overlay(
    generate_line_overlay(
      fal_lines,
      extent = extent_zoomed,
      linewidth = 6,
      color = "#2d8a91",
      heightmap = fal_zoom_mat
    )
  ) %>% add_overlay(
    generate_line_overlay(
      resting_area,
      extent = extent_zoomed,
      linewidth = 6,
      color = "black",
      heightmap = fal_zoom_mat
    )
  ) %>%
  add_overlay(generate_label_overlay(dd, extent = extent_zoomed,
                                     text_size = 2, point_size = 1, 
                                     halo_color = "white",halo_expand = 5, 
                                     seed=1,
                                     heightmap = fal_zoom_mat, data_label_column = "name")) %>%
  plot_3d(fal_zoom_mat, windowsize = c(1200, 800))
render_camera(
  theta = 240,
  phi = 30,
  zoom = 0.5,
  fov = 60
)
render_snapshot(
  filename = "Plots/3d-track.png",
  clear = T
)
#Plot only route
l = points2line_trajectory(pp)
plot(l)
