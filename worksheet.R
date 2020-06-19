## Web Scraping

library(...)

response <- ...('http://research.jisao.washington.edu/pdo/PDO.latest')
response

library(rvest) 

pdo_doc <- read_html(...)

pdo_node <- html_node(..., "p")
pdo_text <- ...(pdo_node)

pdo_text_2017 <- str_match(pdo_text, "(?<=2017).*.(?=\\n2018)")

str_extract_all(pdo_text_2017[1], "[0-9-.]+")

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

county_income <- ... %>%
  ...(as = 'text') %>%
  ...()

head(county_income)

## Specialized Packages

library(tidycensus)
source(...)

variables <- c('NAME', 'B19013_001E')

county_income <- get_acs(geography = 'county',
                         variables = ...,
                         state = ...,
                         year = 2018,
                         geometry = TRUE)
head(county_income)

ggplot(...) + 
  geom_sf(aes(fill = ...), color = NA) + 
  coord_sf() + 
  theme_minimal() + 
  scale_fill_viridis_c()

## Paging & Stashing

api <- 'https://api.nal.usda.gov/fdc/v1/'
path <- ...

query_params <- list('api_key' = Sys.getenv('DATAGOV_KEY'),
                     'query' = ...)

doc <- GET(paste0(..., ...), query = query_params) %>%
  ...(as = 'parsed')

nutrients <- map_dfr(fruit$foodNutrients, 
                     ~ data.frame(name = .$nutrientName, 
                                  value = .$value))
head(nutrients, 10)

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
