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

The [censusapi](){:.rlib} package, developed by Hannah Recht,
is a user-contributed suite of tools that streamline access to the API.

To repeat the exercise below at home, request an API key at
https://api.census.gov/data/key_signup.html, and store it in a file named `census_api_key.R`
in your working directory. The file should contain the line 
`Sys.setenv(CENSUS_KEY = 'your many digit key')`. This creates a hidden
environment variable containing the key.
{:.notes}




~~~r
library(censusapi)
source('census_api_key.R')
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


===

Compared to using the API directly via the [requests](){:.pylib} package:

**Pros**
- More concise code, quicker development
- Package documentation (if present) is usually more user-friendly than API documentaion.
- May allow seamless update if API changes

**Cons**
- No guarantee of updates
- Possibly limited in scope

===

Query the Census ACS5 survey (American Community Survey) for the variable `B19001_001E` (median annual household income,
in dollars) and each entity's `NAME`.

The American Community Survey (ACS) is a yearly survey that provides detailed population
and housing information at fine geographic scale across the United States. Much of the 
[censusapi](){:.rlib} package is dedicated to accessing the ACS data. ACS5 refers to a five-year
average of the annual surveys.
{:.notes}



~~~r
variables <- c('NAME', 'B19013_001E')
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


===

This code pulls the variables `NAME` and `B19001_001E` from all census tracts and all
counties in the state with ID `24` (Maryland). The [censusapi](){:.rlib} package 
converts the JSON string into a data frame. (No need to check headers.) 



~~~r
tract_income <- getCensus(name = 'acs/acs5', 
                          vintage = 2017, 
                          vars = variables, 
                          region = 'tract:*', 
                          regionin = 'state:24+county:*')

head(tract_income)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


~~~
  state county  tract                                           NAME
1    24    045 010501 Census Tract 105.01, Wicomico County, Maryland
2    24    013 501002 Census Tract 5010.02, Carroll County, Maryland
3    24    013 507704 Census Tract 5077.04, Carroll County, Maryland
4    24    013 506102 Census Tract 5061.02, Carroll County, Maryland
5    24    013 506101 Census Tract 5061.01, Carroll County, Maryland
6    24    013 505206 Census Tract 5052.06, Carroll County, Maryland
  B19013_001E
1       68652
2       75069
3       88306
4       84810
5       95075
6       91908
~~~
{:.output}


===

We can use our `dplyr` tools to manipulate the output of `getCensus`.



~~~r
tract_income <- tract_income %>%
  rename(household_income = B19013_001E) %>%
  filter(household_income > 0) 
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


===

We can use `ggplot2` to create boxplots showing the income distribution among
census tracts within each county in Maryland.



~~~r
ggplot(tract_income, aes(x = county, y = household_income)) +
  geom_boxplot()
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}
![ ]({% include asset.html path="images/census/unnamed-chunk-5-1.png" %})
{:.captioned}

