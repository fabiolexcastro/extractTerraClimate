
# Load libraries
require(raster)
require(rgdal)
require(tidyverse)

# Initial setup
g <- gc(reset = TRUE)
rm(list = ls())
options(scipen = 999)

# Article: https://www.nature.com/articles/sdata2017191#abstract 
# Download: https://www.northwestknowledge.net/monthly-climate-and-climatic-water-balance-global-terrestrial-surfaces-1958-2015
# URL: http://www.climatologylab.org/terraclimate.html

'//mnt/workspace_cluster_9/Coffee_Cocoa2/_nick/_data/terraclimate_wget.sh'
