
# Load libraries
require(XLConnect)
require(xlsx)
require(tidyverse)

# Load the rJava library
if(Sys.getenv("JAVA_HOME")!=""){
  Sys.setenv(JAVA_HOME="")
}
library(rJava)

# Initial setup
g <- gc(reset = TRUE)
rm(list = ls())
options(scipen = 999)

# Load data
coords <- read.xlsx2("../_data/_tbl/request_v01.xlsx", 1) %>%
  as.tibble()
coords <- coords %>% 
    setNames(c('Start', 'End', 'Latitude', 'Longitude')) %>%
    mutate(Latitude = as.numeric(as.character(Latitude)),
           Longitude = as.numeric(as.character(Longitude)),
           ID = 1:nrow(.)) 
coords <- coords[complete.cases(coords),]
write.csv(coords, '../_data/_tbl/coords.csv', row.names = F)





