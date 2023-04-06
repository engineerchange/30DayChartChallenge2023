library(tidyverse)
library(rvest)
# plyr for rbind.fill()
library(janitor)
library(ggwaffle) #devtools::install_github("liamgilbey/ggwaffle")
library(patchwork)

dfs = tibble()
for(i in 1969:2023){
  cat(as.character(i),"\n")
  if(i!=1985){ # 1985 has an extra table, so we need to get that differently
    df = read_html(paste0("https://en.wikipedia.org/wiki/List_of_",as.character(i),"_box_office_number-one_films_in_the_United_States")) %>% html_table() %>% .[[1]] 
  } else{
    df = read_html(paste0("https://en.wikipedia.org/wiki/List_of_",as.character(i),"_box_office_number-one_films_in_the_United_States")) %>% html_table() %>% .[[2]]
  }
  Sys.sleep(1) # a calm pause
  df = df %>% mutate(year=i) %>% select(year,everything())
  dfs = plyr::rbind.fill(dfs,df)
}

dfs2 = dfs %>% janitor::clean_names() %>% select(-c(notes)) %>%
  rename("number2"="mw_parser_output_tooltip_dotted_border_bottom_1px_dotted_cursor_help_number")

dfs3 = dfs2 %>%
  mutate(number=ifelse(!is.na(number),number,number_no)) %>% mutate(number=ifelse(!is.na(number),number,number2)) %>%
  mutate(week_ending=ifelse(!is.na(week_ending),week_ending,weekend_end_date)) %>% 
  mutate(gross=ifelse(!is.na(gross),gross,box_office)) %>% mutate(gross=ifelse(!is.na(gross),gross,total_weekend_gross)) %>%
  select(year,number,week_ending,film,gross) %>%
  mutate(month=str_extract(week_ending,"^[A-Za-z]{1,}")) %>%
  mutate(month=case_when(
    month=='January' ~ 1,
    month=='February' ~ 2,
    month=='March' ~ 3,
    month=='April' ~ 4,
    month=='May' ~ 5,
    month=='June' ~ 6,
    month=='July' ~ 7,
    month=='August' ~ 8,
    month=='September' ~ 9,
    month=='October' ~ 10,
    month=='November' ~ 11,
    month=='December' ~ 12,
    TRUE ~ NA_integer_
  )) %>% group_by(year,month) %>% arrange(year,month,number) %>% mutate(n=1:n()) %>% ungroup() %>%
  select(year,month,n,week_ending,film,gross) %>%
  mutate(gross=str_replace(gross,"\\$","") %>% str_replace_all(.,"\\,","")) %>%
  mutate(gross=str_replace(gross,"\\[.*","")) %>%
  mutate(gross2=case_when(
    str_detect(gross,"^[0-9]{1,}$") ~ "Number",
    str_detect(gross,"TBD") ~ "TBD",
    TRUE ~ NA_character_ # this NA value is covid...
  )) %>%
  # manually add our covid data
  rbind(
    tribble(~year,~month,~n,~week_ending,~film,~gross,~gross2,
            2020,3,3,"March 22, 2020","COVID",NA_character_,"COVID",
            2020,3,4,"March 29, 2020","COVID",NA_character_,"COVID",
            2020,4,1,"April 5, 2020","COVID",NA_character_,"COVID",
            2020,4,2,"April 12, 2020","COVID",NA_character_,"COVID",
            2020,4,3,"April 19, 2020","COVID",NA_character_,"COVID",
            2020,4,4,"April 26, 2020","COVID",NA_character_,"COVID",
            2020,5,1,"May 3, 2020","COVID",NA_character_,"COVID",
            2020,5,2,"May 10, 2020","COVID",NA_character_,"COVID",
            2020,5,3,"May 17, 2020","COVID",NA_character_,"COVID",
            2020,5,4,"May 24, 2020","COVID",NA_character_,"COVID",
            2020,5,5,"May 31, 2020","COVID",NA_character_,"COVID",
            2020,6,1,"June 7, 2020","COVID",NA_character_,"COVID",
            2020,6,2,"June 14, 2020","COVID",NA_character_,"COVID",
            2020,6,3,"June 21, 2020","COVID",NA_character_,"COVID",
            2020,6,4,"June 28, 2020","COVID",NA_character_,"COVID",
            2020,7,1,"July 5, 2020","COVID",NA_character_,"COVID",
            2020,7,2,"July 12, 2020","COVID",NA_character_,"COVID",
            2020,7,3,"July 19, 2020","COVID",NA_character_,"COVID",
            2020,7,4,"July 26, 2020","COVID",NA_character_,"COVID",
            2020,8,1,"August 2, 2020","COVID",NA_character_,"COVID",
            2020,8,2,"August 9, 2020","COVID",NA_character_,"COVID",
            2020,8,3,"August 16, 2020","COVID",NA_character_,"COVID"
            )
  ) %>%
  # arrange didnt work, so retry
  dplyr::filter(!is.na(gross2)) %>% # filter out covid entry (March 22, 2020–August 16, 2020)
  mutate(date=as.Date(week_ending,"%b %d, %Y")) %>% arrange(date) %>%
  group_by(year,month) %>% mutate(n=1:n()) %>% ungroup() %>%
  mutate(gross_bucket = case_when(
    is.na(gross) ~ NA_character_,
    gross == 'TBD' ~ NA_character_,
    gross == 'COVID' ~ 'COVID',
    as.integer(gross) < 1000000 ~ "<1M",
    as.integer(gross) <= 5000000 ~ "1-5M",
    as.integer(gross) <= 10000000 ~ "5-10M",
    as.integer(gross) <= 25000000 ~ "10-25M",
    as.integer(gross) <= 50000000 ~ "25-50M",
    as.integer(gross) < 100000000 ~ "50-100M",
    as.integer(gross) >= 100000000 ~ "100M+",
    TRUE ~ 'else'
  ))
dfs3$gross_bucket <- factor(dfs3$gross_bucket, levels = c("<1M","1-5M","5-10M","10-25M","25-50M","50-100M","100M+",NA_character_))
ggmovieyr <- function(yr){
  g1 = dfs3 %>% dplyr::filter(year==yr) %>%
    ggplot() + geom_waffle(aes(month,n,fill = gross_bucket)) + 
    coord_equal() + #scale_colour_waffle() +
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
          plot.title = element_text(hjust = 0.5)) +
    scale_fill_manual(name = "Gross Revenue",na.value = "gray",
                      values = c("<1M" = "#fde725",
                                 "1-5M" = "#90d743",
                                 "5-10M" = "#35b779",
                                 "10-25M" = "#21918c",
                                 "25-50M" = "#31688e",
                                 "50-100M" = "orange",
                                 "100M+" = "red"))
  if(yr %% 10==0){
    g1 = g1 + ggtitle(as.character(yr))
  }
  return(g1)
}
  
do.call(patchwork::wrap_plots, lapply(c(1969:1975), function(x){
  ggmovieyr(x)
})) -> gg_multi
gg_multi + plot_annotation(title="Weekly number-one film in the U.S.'s gross revenue from 1969 to 2023",
                           subtitle='Each square represents the highest gross revenue of any movie that week.',
                           theme = theme(plot.title = element_text(hjust = 0.5),
                                         plot.subtitle = element_text(hjust = 0.5)),
                           caption = "Data source: Wikipedia's List of [year] box office number-one films in the United States\nNote: missing data and covid period as 'NA'.") +
  plot_layout(guides = 'collect',
              heights = 2,
              widths = 4,
              ) & theme(legend.position='bottom') # the legend doesn't display quite right (different categories per plot force extra legend)

# Note to reader: could not figure out how to reduce legend to one single one
# root cause appears to be related to some plots having different combinations of options
# and some not having some options at all.
# All documentation points to scale_continuous type solution and the guides='collect' option I'm using.
# Feel free to post a PR if you have a solution. The output plot's legend is edited.
