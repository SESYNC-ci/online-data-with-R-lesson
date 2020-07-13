---
---

## Web Scraping

That "http" at the beginning of the URL for a possible data source is
a protocol---an understanding between a client and a server about how
to communicate. The client could either be a web browser or your web
scraping program written in R, as long as it uses the correct protocol. 
After all, [servers exist to serve](https://xkcd.com/869/).

===

The following example
uses the [httr](){:.rlib} and [rvest](){:.rlib} packages to issue a 
HTTP request and handle the response. 

The page we are scraping, <http://research.jisao.washington.edu/pdo/PDO.latest>,
deals with the [Pacific Decadal Oscillation](https://en.wikipedia.org/wiki/Pacific_decadal_oscillation) 
(PDO), a periodic switching between
warm and cool water temperatures in the northern Pacific Ocean. Specifically, it
contains monthly values from 1900-2018 indicating how far above or below normal the sea surface
temperature across the northern Pacific Ocean was during that month.
{:.notes}



~~~r
library(httr)

response <- GET('http://research.jisao.washington.edu/pdo/PDO.latest')
response
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


~~~
Response [http://research.jisao.washington.edu/pdo/PDO.latest]
  Date: 2020-07-02 19:22
  Status: 200
  Content-Type: <unknown>
  Size: 12.3 kB
<BINARY BODY>
~~~
{:.output}


===

The response is binary (0s and 1s). The [rvest](){:.rlib} package translates
the raw content into an HTML document, just like a browser does. We use the 
`read_html` function to do this.



~~~r
library(rvest) 

pdo_doc <- read_html(response)
pdo_doc
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


~~~
{html_document}
<html>
[1] <body><p>PDO INDEX\n\nIf the columns of the table appear without formatti ...
~~~
{:.output}


===

If you look at the HTML document, you can see that all the data is inside an 
element called `"p"`. We use the `html_node` function to extract the 
single `"p"` element from the HTML document, then the `html_text` function
to extract the text from that element.



~~~r
pdo_node <- html_node(pdo_doc, "p")
pdo_text <- html_text(pdo_node)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


===

Now we have a long text string containing all the data. We can use text mining tools
like regular expressions to pull out data. If we want the twelve monthly
values for the year 2017, we can use the [stringr](){:.rlib} package to get 
all the text between the strings "2017" and "2018" with `str_match`.



~~~r
library(stringr)
pdo_text_2017 <- str_match(pdo_text, "(?<=2017).*.(?=\\n2018)")
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


===

Then extract all the numeric values in the substring with `str_extract_all`.



~~~r
str_extract_all(pdo_text_2017[1], "[0-9-.]+")
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


~~~
[[1]]
 [1] "0.77" "0.70" "0.74" "1.12" "0.88" "0.79" "0.10" "0.09" "0.32" "0.05"
[11] "0.15" "0.50"
~~~
{:.output}


You can learn more about how to use regular expressions to extract information
from text strings in [SESYNC's text mining lesson](https://cyberhelp.sesync.org/text-mining-lesson/).
{:.notes}

===

## Manual web scraping is hard!

Pages designed for humans are increasingly harder to parse programmatically.

- Servers provide different responses based on client "metadata"
- JavaScript often needs to be executed by the client
- The HTML `<table>` is drifting into obscurity (mostly for the better)

===

## HTML Tables

Sites with easily accessible html tables nowadays may be specifically
intended to be parsed programmatically, rather than browsed by a human reader.
The US Census provides some documentation for their data services in a massive table:

<https://api.census.gov/data/2017/acs/acs5/variables.html>

===

`html_table()` converts the html table into an R 
data frame. Set `fill = TRUE` so that inconsistent numbers 
of columns in each row are filled in.



~~~r
census_vars_doc <- read_html('https://api.census.gov/data/2017/acs/acs5/variables.html')

table_raw <- html_node(census_vars_doc, 'table')

# This line takes a few moments to run.
census_vars <- html_table(table_raw, fill = TRUE) 
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}




~~~r
> head(census_vars)
~~~
{:title="Console" .input}


~~~
             Name           Label                                   Concept
1 25110 variables 25110 variables                           25110 variables
2          AIANHH       Geography                                          
3          AIHHTL       Geography                                          
4           AIRES       Geography                                          
5            ANRC       Geography                                          
6     B00001_001E Estimate!!Total UNWEIGHTED SAMPLE COUNT OF THE POPULATION
         Required      Attributes           Limit    Predicate Type
1 25110 variables 25110 variables 25110 variables   25110 variables
2    not required                               0 (not a predicate)
3    not required                               0 (not a predicate)
4    not required                               0 (not a predicate)
5    not required                               0 (not a predicate)
6    not required    B00001_001EA               0               int
            Group              NA
1 25110 variables 25110 variables
2             N/A            <NA>
3             N/A            <NA>
4             N/A            <NA>
5             N/A            <NA>
6          B00001            <NA>
~~~
{:.output}


===

We can use our tidy data tools to search this unwieldy
documentation for variables of interest.

The call to `set_tidy_names()` is necessary because the table
extraction results in some columns with undefined names---a
common occurrence when parsing Web content.
{:.notes}



~~~r
library(tidyverse)

census_vars %>%
  set_tidy_names() %>%
  select(Name, Label) %>%
  filter(grepl('Median household income', Label))
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


~~~
           Name
1   B19013_001E
2  B19013A_001E
3  B19013B_001E
4  B19013C_001E
5  B19013D_001E
6  B19013E_001E
7  B19013F_001E
8  B19013G_001E
9  B19013H_001E
10 B19013I_001E
11  B19049_001E
12  B19049_002E
13  B19049_003E
14  B19049_004E
15  B19049_005E
16  B25099_001E
17  B25099_002E
18  B25099_003E
19  B25119_001E
20  B25119_002E
21  B25119_003E
                                                                                                                         Label
1                                 Estimate!!Median household income in the past 12 months (in 2017 inflation-adjusted dollars)
2                                 Estimate!!Median household income in the past 12 months (in 2017 inflation-adjusted dollars)
3                                 Estimate!!Median household income in the past 12 months (in 2017 inflation-adjusted dollars)
4                                 Estimate!!Median household income in the past 12 months (in 2017 inflation-adjusted dollars)
5                                 Estimate!!Median household income in the past 12 months (in 2017 inflation-adjusted dollars)
6                                 Estimate!!Median household income in the past 12 months (in 2017 inflation-adjusted dollars)
7                                 Estimate!!Median household income in the past 12 months (in 2017 inflation-adjusted dollars)
8                                 Estimate!!Median household income in the past 12 months (in 2017 inflation-adjusted dollars)
9                                 Estimate!!Median household income in the past 12 months (in 2017 inflation-adjusted dollars)
10                                Estimate!!Median household income in the past 12 months (in 2017 inflation-adjusted dollars)
11                         Estimate!!Median household income in the past 12 months (in 2017 inflation-adjusted dollars)!!Total
12    Estimate!!Median household income in the past 12 months (in 2017 inflation-adjusted dollars)!!Householder under 25 years
13    Estimate!!Median household income in the past 12 months (in 2017 inflation-adjusted dollars)!!Householder 25 to 44 years
14    Estimate!!Median household income in the past 12 months (in 2017 inflation-adjusted dollars)!!Householder 45 to 64 years
15 Estimate!!Median household income in the past 12 months (in 2017 inflation-adjusted dollars)!!Householder 65 years and over
16                                                                                    Estimate!!Median household income!!Total
17                                 Estimate!!Median household income!!Total!!Median household income for units with a mortgage
18                              Estimate!!Median household income!!Total!!Median household income for units without a mortgage
19                         Estimate!!Median household income in the past 12 months (in 2017 inflation-adjusted dollars)!!Total
20      Estimate!!Median household income in the past 12 months (in 2017 inflation-adjusted dollars)!!Owner occupied (dollars)
21     Estimate!!Median household income in the past 12 months (in 2017 inflation-adjusted dollars)!!Renter occupied (dollars)
~~~
{:.output}

