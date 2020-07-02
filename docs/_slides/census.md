---
---

## Specialized Packages

The third tier of access to online data is much preferred, if it
exists: a dedicated package in your programming language's repository,
[CRAN](http://cran.r-project.org) or [PyPI](http://pypi.python.org).

- Additional guidance on query parameters
- Returns data in native formats
- Handles all "encoding" problems

===

The [tidycensus](){:.rlib} package, developed by Kyle Walker,
streamlines access to the API and is integrated with [tidyverse](){:.rlib} packages.

To repeat the exercise below at home, request an API key at
<https://api.census.gov/data/key_signup.html>, and store it in a file named `census_api_key.R`
in your working directory. The file should contain the line 
`Sys.setenv(CENSUS_API_KEY = 'your many digit key')`. This creates a hidden
system variable containing the key. This is good practice---it is much safer than
pasting the API key directly into your code or saving it as a variable in the global environment.
{:.notes}




~~~r
library(tidycensus)
source('census_api_key.R')
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


===

Compared to using the API directly via the [httr](){:.rlib} package:

**Pros**
- More concise code, quicker development
- Package documentation (if present) is usually more user-friendly than API documentaion.
- May allow seamless update if API changes

**Cons**
- No guarantee of updates
- Possibly limited in scope

===

Query the Census ACS5 survey for the variable `B19013_001E` (median annual household income,
in dollars) and each entity's `NAME`.



~~~r
variables <- c('NAME', 'B19013_001E')
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


===

Get the variables `NAME` and `B19013_001E` (median household income) 
from all counties in Maryland. [tidycensus](){:.rlib}
converts the JSON string into a data frame. (No need to check headers.) 

This code uses the `get_acs` function, which is the main function in 
[tidycensus](){:.rlib} for interacting with the American Community Survey 
API. The arguments are fairly self-explanatory. We can use the text 
abbreviation for the state of Maryland (`MD`); the function automatically
converts this into the numerical FIPS code. The `geometry = TRUE` argument
means that we want `get_acs` output to include the county boundaries as a
spatial object.
{:.notes}



~~~r
county_income <- get_acs(geography = 'county',
                         variables = variables,
                         state = 'MD',
                         year = 2018,
                         geometry = TRUE)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}




~~~r
> head(county_income)
~~~
{:title="Console" .input}


~~~
Simple feature collection with 6 features and 5 fields
geometry type:  MULTIPOLYGON
dimension:      XY
bbox:           xmin: -79.06756 ymin: 38.31653 xmax: -75.70736 ymax: 39.72304
CRS:            4269
# A tibble: 6 x 6
  GEOID NAME        variable estimate   moe                             geometry
  <chr> <chr>       <chr>       <dbl> <dbl>                   <MULTIPOLYGON [°]>
1 24001 Allegany C… B19013_…    44065  1148 (((-79.06756 39.47944, -79.06003 39…
2 24003 Anne Arund… B19013_…    97810  1299 (((-76.84036 39.10314, -76.83678 39…
3 24005 Baltimore … B19013_…    74127   922 (((-76.3257 39.31397, -76.32452 39.…
4 24009 Calvert Co… B19013_…   104301  3548 (((-76.70121 38.71276, -76.69915 38…
5 24011 Caroline C… B19013_…    54956  2419 (((-76.01505 38.72869, -76.01321 38…
6 24013 Carroll Co… B19013_…    93363  1867 (((-77.31151 39.63914, -77.30972 39…
~~~
{:.output}


===

We can use [dplyr](){:.rlib} to manipulate the output, and [ggplot2](){:.rlib} to visualize the data.
Because we set `geometry = TRUE`, [tidycensus](){:.rlib} even includes spatial information in its
output that we can use to create maps!

This code uses the spatial data frame output from `get_acs` to plot the counties of Maryland with
fill color corresponding to the median household income of the counties, with some additional
graphical options.
{:.notes}



~~~r
ggplot(county_income) + 
  geom_sf(aes(fill = estimate), color = NA) + 
  coord_sf() + 
  theme_minimal() + 
  scale_fill_viridis_c()
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}
![ ]({% include asset.html path="images/census/unnamed-chunk-5-1.png" %})
{:.captioned}

For a more in-depth tutorial on R's geospatial data types, check out 
[SESYNC's lesson on geospatial packages in R](https://cyberhelp.sesync.org/geospatial-packages-in-R-lesson).
{:.notes}
