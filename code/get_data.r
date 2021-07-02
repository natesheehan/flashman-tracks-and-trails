# Get dtm data ------------------------------------------------------------
if (file.exists("data/fal_school_dtm.tif")) {
  fal_school = raster("data/fal_school_dtm.tif")
} else {
  #Get lidar data
  fal_school = get_from_xy(
    xy = c(179011, 033245),
    radius = 500,
    resolution = 0.5,
    model_type = 'DSM'
  )
}
# Get bike route data -----------------------------------------------------
p = read_sf("data/full_track.gpx", layer = "tracks")
pp = read_sf("data/full_track.gpx", layer = "track_points") # track points
resting_area = sf::read_sf("data/Resting-Area/Resting-area.shp")
