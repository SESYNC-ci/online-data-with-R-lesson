---
---

## Exercises

### Exercise 1

Create a data frame with the population of all countries in the world by scraping
the [Wikipedia list of countries by population].
*Hint*: First call the function `read_html()`, then call `html_node()`
on the output of `read_html()` with the argument `xpath='//*[@id="mw-content-text"]/div/table[1]'`
to extract the table element from the HTML content, then call a third function to 
convert the HTML table to a data frame.

### Exercise 2

Identify the name of the census variable in the table of ACS variables whose
label includes "COUNT OF THE POPULATION". Next, use the Census API to collect
the data for this variable, for every county in Maryland (FIPS code 24) 
into a data frame. Create a map or figure to visualize the data.

### Exercise 3

Request an [API key for data.gov], which will enable you to access the FoodData
Central API. Use the API to collect 3 "pages" of food results matching a search 
term of your choice. Save the names of the foods and a nutrient value of your
choice into a new SQLite file.

[Wikipedia list of countries by population]: https://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_population
[API key for data.gov]: https://api.data.gov/signup/