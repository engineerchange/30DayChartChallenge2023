library(tidyverse)
library(sf)
library(patchwork)
library(ggtext)

# Source: StackOverflow answer from Stewart McDonald: https://stackoverflow.com/questions/56238146/r-fill-map-with-color-by-percentage
increment <- 10*80 # smaller numbers mean more accurate map

# load shapefile
gerShp <- st_read('~/Downloads/cb_2018_us_state_500k/cb_2018_us_state_500k.shp')
gerShp <- st_transform(gerShp, 3035)
gerShp_ME <- gerShp %>% dplyr::filter(NAME=='Maine')
gerShp_ND <- gerShp %>% dplyr::filter(NAME=='North Dakota')

# Maine -------------------------------------------------------------------
totalArea <- st_area(gerShp_ME) # calculate total area
areaprop <- totalArea * 0.8946

bbox <- st_bbox(gerShp_ME) # add bounding box

thisArea <- totalArea - totalArea # zero with correct units
i <- 1

while (thisArea < areaprop) { # while loop is below area prop
  thisBBox <- bbox
  thisBBox['xmax'] <- thisBBox$xmin + (increment * i) # start from left and go right
  thisSubarea <- st_crop(gerShp_ME, y=thisBBox) # crop to bounding box
  thisArea <- st_area(thisSubarea)
  print(thisArea)
  i <- i + 1
}

f_thisSubarea = fortify(thisSubarea) # prepare shapefile
g1 <- ggplot() +
  geom_sf(data=gerShp_ME,fill='white') + # graph full shape file
  geom_sf(data=f_thisSubarea,fill='darkgreen') + # graph prop shape file on top of full shape file
  # remove all grids, axis labels, text, etc.
  theme(axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        legend.position="none",
        panel.background=element_blank(),
        panel.border=element_blank(),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        plot.background=element_blank(),
        plot.title = element_text(hjust = 0.5)) + # force title to center
  annotate("text",x=-564619, y=5565773, label="atop(bold('89.5% coverage'))", col="white",size=4,parse=TRUE) # annotate word over plots

thisArea / totalArea # calculate actual percentage


# North Dakota ------------------------------------------------------------
totalArea <- st_area(gerShp_ND) # calculate total area
areaprop <- totalArea * 0.0172

bbox <- st_bbox(gerShp_ND) # add bounding box

thisArea <- totalArea - totalArea # zero with correct units
i <- 1

while (thisArea < areaprop) { # while loop is below area prop
  thisBBox <- bbox
  thisBBox['xmax'] <- thisBBox$xmin + (increment * i) # start from left and go right
  thisSubarea <- st_crop(gerShp_ND, y=thisBBox) # crop to bounding box
  thisArea <- st_area(thisSubarea)
  print(thisArea)
  i <- i + 1
}

f_thisSubarea = fortify(thisSubarea)
g2 <- ggplot() +
  geom_sf(data=gerShp_ND,fill='white') + # graph full shape file
  geom_sf(data=f_thisSubarea,fill='darkgreen') + # graph prop shape file on top of full shape file
  # remove all grids, axis labels, text, etc.
  theme(axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        legend.position="none",
        panel.background=element_blank(),
        panel.border=element_blank(),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        plot.background=element_blank(),
        plot.title = element_text(hjust = 0.5)) + # force title to center
  annotate("text",x=-486091, y=7985587, label="atop(bold('1.72% coverage'))", col="darkgreen",size=4,parse=TRUE) # annotate word over plots

thisArea / totalArea # calculate actual percentage

# combine plots -----------------------------------------------------------
# use patchwork, ggtext
(g1 + ggtitle("Maine")) + (g2 + ggtitle("North Dakota")) +
  plot_annotation(title = "<span style='color:#006400;'>Forest coverage</span> extremes in the U.S.",
                  subtitle = "Visualizing the states with the largest and smallest amount of timberland",
                  caption = "Data source: U.S. Forest Service's Forest Inventory and Analysis (FY2016)",
                  theme = theme(plot.title = element_text(size = 18))) & 
  theme(text = element_text('mono'),plot.title = element_markdown(lineheight = 1.1))


