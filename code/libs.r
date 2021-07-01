# Packages ----------------------------------------------------------------
#Set pkgs
pkgs = c("EAlidaR",
         "sf",
         "raster",
         "rayshader",
         "magick",
         "osmdata")

#Install pkgs
installed_packages = pkgs %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(pkgs[!installed_packages])
}
#Load pkgs
invisible(lapply(pkgs, library, character.only = TRUE))