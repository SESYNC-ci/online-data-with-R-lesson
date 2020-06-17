## Web Scraping

library(...)

response <- ...('https://xkcd.com/869')
response

library(rvest) 
library(htmltidy)

doc <- read_html(...)
html_view(...)

img <- doc %>%
  html_node(...) 

img_attrs <- img %>%
  html_attrs()

img_attrs[...]

## HTML Tables

census_vars_doc <- ...('https://api.census.gov/data/2017/acs/acs5/variables.html') %>% 
  html_node(...)

census_vars <- html_table(..., fill = TRUE) 

head(census_vars)

library(tidyverse)

... %>%
  set_tidy_names() %>%
  ...(Name, Label) %>%
  filter(grepl('Median household income', ...))

## Web Services

path <- 'https://api.census.gov/data/2017/acs/acs5'
query_params <- list('get' = 'NAME,...', 
                     'for' = 'tract:*',
                     'in' = 'state:24')

response = GET(..., ... = ...)
response

response$...['content-type']

## Response Content

library(...)

maryland_income <- ... %>%
  ...(as = 'text') %>%
  ...()

head(maryland_income)

## Specialized Packages

library(censusapi)
source(...)

variables <- c('NAME', 'B19013_001E')

tract_income <- getCensus(name = 'acs/acs5', 
                          vintage = 2017, 
                          vars = ..., 
                          region = 'tract:*', 
                          regionin = 'state:24+county:*')

head(tract_income)

tract_income <- tract_income %>%
  rename(household_income = B19013_001E) %>%
  ...(... > 0) 

ggplot(tract_income, aes(x = county, y = ...)) +
  geom_boxplot()

## Paging & Stashing

api <- 'https://api.nal.usda.gov/fdc/v1/'
path <- ...

query_params <- list('api_key' = Sys.getenv('DATAGOV_KEY'),
                     'query' = ...)

doc <- GET(paste0(..., ...), query = query_params) %>%
  ...(as = 'parsed')

map_dfr(fruit$foodNutrients, 
        ~ data.frame(name = .$nutrientName, 
                     value = .$value)) %>%
  head(10)

library(DBI) 
library(RSQLite)

fruit_db <- ...(...(), 'fruits.sqlite') 

query_params$pageSize <- ...

for (i in 1:10) {
  # Advance page and query
  query_params$pageNumber <- ...
  response <- GET(paste0(api, path), query = query_params) 
  page <- content(response, as = 'parsed')
  fruits <- page$foods
  
  # Convert nested list to data frame
  values <- tibble(fruit = fruits) %>%
    unnest_wider(fruit) %>%
    unnest_longer(foodNutrients) %>%
    unnest_wider(foodNutrients) %>%
    filter(grepl('Sugars, total', nutrientName)) %>%
    select(fdcId, description, value) %>%
    setNames(c('foodID', 'name', 'sugar'))
  
  # Stash in database
  dbWriteTable(fruit_db, name = 'Food', value = values, append = TRUE)
  
}

fruit_sugar_content <- ...(fruit_db, name = 'Food')
head(fruit_sugar_content, 10)

dbDisconnect(...)
