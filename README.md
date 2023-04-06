# 30DayChartChallenge2023

![2023](2023.jpeg)

Learn more about #30DayChartChallenge:
- [z3tt's repo](https://github.com/z3tt/30DayChartChallenge2021)
- [Official website](https://30daychartchallenge.org/about/)
- [The tweet that started it all](https://twitter.com/tjukanov/status/1187713840550744066)

# My submissions

## Day 1 – Part-To-Whole
![Day01](/01_part_to_whole/Day01.png)

ggplot2 visual using pictorial percentage chart (see [part-to-whole](https://datavizproject.com/function/part-to-whole/))

- Code: [Day01.R](/01_part_to_whole/Day01.R)
- Packages used: tidyverse (ggplot2), sf, patchwork, ggtext
- Data sources:
	- [Wikipedia: Forest cover by state and territory in the United States](https://en.wikipedia.org/wiki/Forest_cover_by_state_and_territory_in_the_United_States); note: the official source is US Forest Service's Forest Inventory and Analysis.
	- [Census States Shapefile (2018)](https://www.census.gov/geographies/mapping-files/time-series/geo/carto-boundary-file.html)
- Unrelated, but check out [rFIA](https://github.com/hunter-stanke/rFIA)

Resources that helped:
- Adapted mostly from [SO: Pictorial percentage chart in R](https://stackoverflow.com/questions/56238146/r-fill-map-with-color-by-percentage)
- [Coordinate reference system (crs) explainer](https://source.opennews.org/articles/choosing-right-map-projection/)
- [plot_annotation (patchwork)](https://patchwork.data-imaginist.com/reference/plot_annotation.html)
- [SO: color in patchwork title](https://stackoverflow.com/questions/61642489/colour-in-title-of-patchwork-of-ggplots-using-ggtext)
- [SO: bold/emphasis in annotate function](https://stackoverflow.com/questions/31568453/using-different-font-styles-in-annotate-ggplot2)

## Day 2 - Waffle
![Day02](/02_waffle/Day02.png)

ggplot2 waffle

- Code: [Day02.R](/02_waffle/Day02.R)
- Packages used: tidyverse (ggplot2, plyr), rvest, janitor, patchwork, [liamgilbey/ggwaffle](https://github.com/liamgilbey/ggwaffle)
- Data sources: Wikipedia lists of single-movie box office gross revenues; ex. [year of 1969](https://en.wikipedia.org/wiki/List_of_1969_box_office_number-one_films_in_the_United_States)
- Notes: 
	- Legend output has a bug I couldn't work around.
	- Some months have 6 weeks (vs. usual 4-5 weeks) in length. This impacts the "ease" of looking at the visual. 
	- Color choice could use some work.

Resources that helped:
- [ggwaffle's docs](https://liamgilbey.github.io/ggwaffle/)
- [SO: patchwork::wrap_plots explainer](https://stackoverflow.com/questions/66840743/putting-together-a-patchwork-of-plots-by-creating-single-plots-by-iterating-over)
- [viridis palette generator](https://waldyrious.net/viridis-palette-generator/)
- [patchwork's plot_layout doc](https://patchwork.data-imaginist.com/reference/plot_layout.html)
