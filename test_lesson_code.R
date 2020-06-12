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

# third code block: convert JSON to dataframe


# Specialized Packages ----------------------------------------------------

# first code block: ACS5 for 2017 (not sure what this does)

# scond and third code blocks: define what variables to get and pull from census pkg

