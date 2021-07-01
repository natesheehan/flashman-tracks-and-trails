# Get dtm data ------------------------------------------------------------
if(file.exists("data/fal_school_dtm.tif")){
  fal_school = raster("data/fal_school_dtm.tif")
} else {
  #Get lidar data
  fal_school = get_from_xy(
    xy = c(179011, 033245),
    radius = 500,
    resolution = 0.5,
    model_type = 'DSM',
    dest_folder = "data",
    out_name = "fal_school_dtm",
    ras_format = "GTiff"
  )
}
# Get bike route data -----------------------------------------------------
p = read_sf("data/full_track.gpx", layer = "tracks")
