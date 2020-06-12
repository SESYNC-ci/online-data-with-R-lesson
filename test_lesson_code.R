# First attempt to port the Python code in online-data-lesson to R
# 12 June 2020


# Requests ----------------------------------------------------------------



# first code block: httr corresponds to requests
library(httr)

response <- GET('https://xkcd.com/869')
response

# second code block: rvest corresponds to Beautifulsoup
# rvest is a (bad) pun on harvest
library(rvest) # Also loads xml2

doc <- read_html(response)

library(htmltidy) # optional: display a more human readable version in the viewer

html_view(doc)

# third code block: find image below section of document with attribute id = comic
img <- doc %>%
  html_nodes('#comic > img') 
img

# fourth code block: extract single element with html_node() and get the title
img <- doc %>%
  html_node('#comic > img') 

img_attrs <- img %>%
  html_attrs()

img_attrs['title']


# HTML tables -------------------------------------------------------------

# first code block: get the variable documentation from US Census web data services
census_vars_doc <- read_html('https://api.census.gov/data/2017/acs/acs5/variables.html') %>% 
  html_node('table')

# Convert the table node to a data frame
# Note: takes a long time and returns an error unless fill = TRUE set (inconsistent n columns)
census_vars <- html_table(census_vars_doc, fill = TRUE)

head(census_vars)

# second code block: use dplyr to pull out certain rows from the table


# Web Services ------------------------------------------------------------

# first code block: query the census API
path <- 'https://api.census.gov/data/2017/acs/acs5'
query_params <- list('get' = 'NAME,B19013_001E', 
                     'for' = 'tract:*',
                     'in' = 'state:24')

response = GET(path, query = query_params)
response

# second code block: determine the content type
response$headers['content-type']

# third code block: convert JSON to matrix
library(jsonlite)

maryland_income <- response %>%
  content(as = 'text') %>%
  fromJSON()

head(maryland_income)
# Maybe we should note that this doesn't recognize the header row. In "real life" we would convert to a data frame and promote first row to header

# Specialized Packages ----------------------------------------------------

# first code block: ACS5 for 2017 (not sure what this does)

# second and third code blocks: define what variables to get and pull from census pkg


# Paging and Stashing -----------------------------------------------------

# first code block: read api_key into the environment
source('api_key.R')

# second code block: query the USDA API for fruit nutrition info
api <- 'https://api.nal.usda.gov/fdc/v1/'
path <- 'foods/search'
query_params <- list('api_key' = API_KEY,
                     'query' = 'fruit')
doc <- GET(paste0(api, path), query = query_params) %>%
  content(as = 'parsed')

# 3rd-5th code blocks : inspect the doc object

names(doc)

doc$totalHits

length(doc$foods)

# code block 6-7: setup database schema

# code block 8: extract one fruit and see its name
fruit <- doc$foods[[1]]
fruit$description

# code block 9: list some of the nutrients (with purrr)
library(purrr)
library(dplyr)

map_dfr(fruit$foodNutrients, 
        ~ data.frame(name = .$nutrientName, value = .$value)) %>%
  head(10)

# code block 10: initialize 
library(DBI) # RSQLite is a DBI compliant package, whatever that means, and itself contains sqlite
library(RSQLite)

fruit_db <- dbConnect(SQLite(), 'fruits.sqlite') # Creates in WD

dbExecute(conn = fruit_db,
            'CREATE TABLE Food
              (foodID INTEGER,
               name TEXT,
               sugar FLOAT)')

# code block 11-12: increase page size parameter and repeatedly page through and stash
query_params$pageSize <- 100

# This is really long code and probably ends up confusing people. I'd like to find a simpler example.
get_sugar_content <- function(fruit) {
  nutrients <- map_dfr(fruit$foodNutrients, ~ data.frame(name = .$nutrientName, value = .$value)) 
  sugar_content <- nutrients %>% 
    filter(grepl('Sugar', name)) %>%
    pull(value)
  ifelse(length(sugar_content) == 1, sugar_content, as.numeric(NA))
}

for (i in 1:10) {
  # Advance page and query
  query_params$pageNumber <- i
  response <- GET(paste0(api, path), query = query_params) 
  page <- content(response, as = 'parsed')
  fruits <- page$foods
  
  # Save page 
  values <- map_dfr(fruits, 
                    ~ data.frame(foodID = .$fdcId,
                                 name = .$description,
                                 sugar = get_sugar_content(.)))
  
  # Stash in database
  dbWriteTable(conn = fruit_db, name = 'Food', value = values, append = TRUE)

}

# code block 13: read to dataframe and view

fruit_sugar_content <- dbReadTable(conn = fruit_db, name = 'Food')
head(fruit_sugar_content, 10)

# code block 14: disconnect from database
dbDisconnect(conn = fruit_db)
