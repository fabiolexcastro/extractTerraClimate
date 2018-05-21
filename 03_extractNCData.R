
# Load libraries
require(raster)
require(rgdal)
require(tidyverse)
require(velox)
require(stringr)
require(doMC)
require(foreach)

# Initial setup
rm(list = ls())
setwd('//mnt/workspace_cluster_9/Coffee_Cocoa2/_nick')

# Functions to use
extMskNCO <- function(vr, yr, path_inp, path_out){
  inp <- paste0(path_inp, vr, '_', yr, '.nc')
  out <- paste0(path_out, vr, '_', yr, '.nc')
  system(paste("cdo sellonlatbox,", 
               xmin = -91.22307, ",", 
               xmax = -86.16873, ",", 
               ymin = 13.7911, ",", 
               ymax = 15.09972, " ", 
               nc = inp, " ", 
               outNc = out, sep=""))
  print('Done!!!')
}
extNC <- function(vr, yr, occ){
  bck <- paste0('//mnt/workspace_cluster_9/Coffee_Cocoa2/_nick/_data/_nc/_world/TerraClimate_', vr, '_', yr, '.nc') %>%
    brick()
  vlx <- velox(bck)
  print('To make the extraction by points')
  vlx$extract_points(sp = occ)
  vls <- vlx$extract_points(sp = occ) %>% 
    cbind(coordinates(occ)) %>% 
    as.tibble() %>%
    setNames(c(month.name, occ %>% coordinates %>% colnames)) %>%
    mutate(year = yr,
           id = 1:nrow(.)) %>%
    gather(var, value, -year, -Longitude, -Latitude, -id)
  print('Done!')
  return(vls)
}

# Load data
yrs <- 2010:2017
vrs <- c('ppt', 'tmax', 'tmin')
fls <- list.files('./_data/_nc/_world', full.name = T, pattern = '.nc$')
occ <- read_csv('./_data/_tbl/coords.csv')

# Knowing the extent
coordinates(occ) <- ~ Longitude + Latitude
ext <- extent(occ) + 0.5

# Apply the Function - Example
extNC(vr = vrs[1], yr = yrs[1], occ = occ)
registerDoMC(length(yrs))

# Precipitation
ppt <- foreach(y = 1:length(yrs), .packages = c('velox', 'raster', 'rgdal', 'tidyverse'), .verbose = TRUE) %dopar% {
  extNC(vr = vrs[1], yr = yrs[y], occ = occ)
}
ppt <- bind_rows(ppt)

# Maximum temperature
registerDoMC(length(yrs))
tmax <- foreach(y = 1:length(yrs), .packages = c('velox', 'raster', 'rgdal', 'tidyverse'), .verbose = TRUE) %dopar% {
  extNC(vr = vrs[2], yr = yrs[y], occ = occ)
}
tmax <- bind_rows(tmax)

# Minimum temperature
registerDoMC(length(yrs))
tmin <- foreach(y = 1:length(yrs), .packages = c('velox', 'raster', 'rgdal', 'tidyverse'), .verbose = TRUE) %dopar% {
  extNC(vr = vrs[3], yr = yrs[y], occ = occ)
}
tmin <- bind_rows(tmax)

# Write the final files
dir.create('./_data/_tbl/_climate')
write_csv(ppt, './_data/_tbl/_climate/ppt.csv')
write_csv(tmax, './_data/_tbl/_climate/tmax.csv')
write_csv(tmin, './_data/_tbl/_climate/tmin.csv')

# End
