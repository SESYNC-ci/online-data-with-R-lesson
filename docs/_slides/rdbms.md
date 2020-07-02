---
---

## Paging & Stashing

A common strategy that web service providers take to balance their
load is to limit the number of records a single API request can
return. The user ends up having to flip through "pages" with the API,
handling the response content at each iteration. Options for stashing
data are:

1. Store it all in memory, write to file at the end.
1. Append each response to a file, writing frequently.
1. Offload these decisions to database management software.

The [data.gov](https://www.data.gov) API provides a case in point. 
Data.gov is a service provided by the U.S. federal government to make data available
from across many government agencies. It hosts a catalog of raw data and of many other
APIs from across government.
Among the APIs catalogued by data.gov is the [FoodData Central](https://fdc.nal.usda.gov/) API.
The U.S. Department of Agriculture maintains a data system of nutrition information 
for thousands of foods. 
We might be interested in the relative nutrient content of different fruits.
{:.notes}

To repeat the exercise below at home, request an API key at
https://api.data.gov/signup/, and store it in a file named `datagov_api_key.R`
in your working directory. The file should contain the line 
`Sys.setenv(DATAGOV_KEY = 'your many digit key')`.
{:.notes}

===

Load the `DATAGOV_KEY` variable as a system variable by importing it from the file you saved it in.



~~~r
> source('datagov_api_key.R')
~~~
{:title="Console" .input}


===

Run an API query for all foods with `"fruit"` in their name and parse the content of the response.

Just like we did previously in this lesson, we create a named list 
of query parameters, including the API key and the
search string, and pass them to `GET()`. We use the pipe operator `%>%` 
to pipe the output of `GET()` to `content()`. We use the `as = 'parsed'`
argument to convert the JSON content to a nested list.
{:.notes}



~~~r
api <- 'https://api.nal.usda.gov/fdc/v1/'
path <- 'foods/search'

query_params <- list('api_key' = Sys.getenv('DATAGOV_KEY'),
                     'query' = 'fruit')

doc <- GET(paste0(api, path), query = query_params) %>%
  content(as = 'parsed')
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


===

Extract data from the returned JSON object, which gets mapped to an
R list called `doc`.
First inspect the names of the list elements.



~~~r
> names(doc)
~~~
{:title="Console" .input}


~~~
[1] "foodSearchCriteria" "totalHits"          "currentPage"       
[4] "totalPages"         "foods"             
~~~
{:.output}


===

We can print the value of `doc$totalHits` to see
how many foods matched our search term, `"fruit"`.



~~~r
> doc$totalHits
~~~
{:title="Console" .input}


~~~
[1] 18801
~~~
{:.output}


===

The claimed number of results is much larger than the length
of the `foods` array contained in this response. The query returned only the
first page, with 50 items.



~~~r
> length(doc$foods)
~~~
{:title="Console" .input}


~~~
[1] 50
~~~
{:.output}


===

Continue to inspect the returned object. Extract one element from the list
of `foods` and view its description.



~~~r
> fruit <- doc$foods[[1]]
> fruit$description
~~~
{:title="Console" .input}


~~~
[1] "Fruit leather and fruit snacks candy"
~~~
{:.output}


===

The `map_dfr` function from the [purrr](){:.rlib} package extracts the name and
value of all the nutrients in the `foodNutrients` list within the first search
result, and creates a data frame.



~~~r
nutrients <- map_dfr(fruit$foodNutrients, 
                     ~ data.frame(name = .$nutrientName, 
                                  value = .$value))
head(nutrients, 10)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


~~~
                           name  value
1                       Protein   0.55
2             Total lipid (fat)   2.84
3   Carbohydrate, by difference  84.31
4                        Energy 365.00
5                Alcohol, ethyl   0.00
6                         Water  11.25
7                      Caffeine   0.00
8                   Theobromine   0.00
9  Sugars, total including NLEA  53.37
10         Fiber, total dietary   0.00
~~~
{:.output}


===

The `DBI` and `RSQLite` packages together allow R to connect to a 
database-in-a-file. If the `fruits.sqlite` file does not exist
in your working directory already when you try to connect,
`dbConnect()` will create it.



~~~r
library(DBI) 
library(RSQLite)

fruit_db <- dbConnect(SQLite(), 'fruits.sqlite') 
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


===

Add a new `pageSize` parameter by appending a named element
to the existing `query_params` list, to request `100` documents per page.



~~~r
query_params$pageSize <- 100
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


===

We will send 10 queries to the API to get 1000 total records.
In each request (each iteration through the loop), 
advance the query parameter `pageNumber` by one. 
The query will retrieve 100 records, starting with `pageNumber * pageSize`. 


We use some `tidyr` and `dplyr` manipulations to
extract the ID number, name, and the amount of sugar from each
of the foods in the page of results returned by the query. The series of 
`unnest_longer()` and `unnest_wider()` functions turns the nested list into 
a data frame by successively converting lists into columns in the data frame.
This long manipulation is necessary because R does not easily handle the
nested list structures that APIs return. If we were using
a specialized API R package, typically it would handle this data wrangling 
for us. After converting the list to a data frame, we use `filter` to retain
only the rows where the `nutrientName` contains the substring `'Sugars, total'`
and then select the three columns we want to keep: the numerical ID of 
the food, its full name, and its sugar content. Finally the 100-row data
frame is assigned to the object `values`.
{:.notes}

===

Each time through the loop, insert the next 100 fruits 
(the three-column data frame `values`) 
in bulk to the database with `dbWriteTable()`.




~~~r
for (i in 1:10) {
  # Advance page and query
  query_params$pageNumber <- i
  response <- GET(paste0(api, path), query = query_params) 
  page <- content(response, as = 'parsed')

  # Convert nested list to data frame
  values <- tibble(food = page$foods) %>%
    unnest_wider(food) %>%
    unnest_longer(foodNutrients) %>%
    unnest_wider(foodNutrients) %>%
    filter(grepl('Sugars, total', nutrientName)) %>%
    select(fdcId, description, value) %>%
    setNames(c('foodID', 'name', 'sugar'))

  # Stash in database
  dbWriteTable(fruit_db, name = 'Food', value = values, append = TRUE)

}
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


===

View the records in the database by reading
everything we have so far into a data frame
with `dbReadTable()`.



~~~r
fruit_sugar_content <- dbReadTable(fruit_db, name = 'Food')
head(fruit_sugar_content, 10)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


~~~
   foodID                                       name sugar
1  789246       Fruit leather and fruit snacks candy 53.37
2  781278 Fruit smoothie, with whole fruit and dairy  8.28
3  786863 Fruit smoothie, with whole fruit, no dairy  8.20
4  789150                                Fruit sauce 36.23
5  786838                                Soup, fruit 14.77
6  789114                                Fruit syrup 53.00
7  784748                               Bread, fruit 24.96
8  167781                              Candied fruit 80.68
9  784768                      Cheesecake with fruit 15.27
10 784566                           Croissant, fruit 13.98
~~~
{:.output}


===

Don't forget to disconnect from your database!



~~~r
dbDisconnect(fruit_db)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}



