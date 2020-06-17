---
---

## Requests

That "http" at the beginning of the URL for a possible data source is
a protocol---an understanding between a client and a server about how
to communicate. The client does not have to be a web browser, so long
as it knows the protocol. After all, [servers exist to
serve](https://xkcd.com/869/).

===

The [httr](){:.rlib} package provides a simple interface to
issuing HTTP requests and handling the response. Here's an example
using an [XKCD comic](https://xkcd.com/869/).



~~~r
library(httr)

response <- GET('https://xkcd.com/869')
response
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


~~~
Response [https://xkcd.com/869/]
  Date: 2020-06-17 19:25
  Status: 200
  Content-Type: text/html; charset=UTF-8
  Size: 7.54 kB
<!DOCTYPE html>
<html>
<head>
<link rel="stylesheet" type="text/css" href="/s/7d94e0.css" title="Default"/>
<title>xkcd: Server Attention Span</title>
<meta http-equiv="X-UA-Compatible" content="IE=edge"/>
<link rel="shortcut icon" href="/s/919f27.ico" type="image/x-icon"/>
<link rel="icon" href="/s/919f27.ico" type="image/x-icon"/>
<link rel="alternate" type="application/atom+xml" title="Atom 1.0" href="/ato...
<link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="/rss.x...
...
~~~
{:.output}


===

The response is still binary. It takes a browser-like parser to
translate the raw content into an HTML document. 
[rvest](){:.rlib} does the translating. 



~~~r
library(rvest) 

doc <- read_html(response)
doc
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


~~~
{html_document}
<html>
[1] <head>\n<meta http-equiv="Content-Type" content="text/html; charset=UTF-8 ...
[2] <body>\n<div id="topContainer">\n<div id="topLeft">\n<ul>\n<li><a href="/ ...
~~~
{:.output}


===

[htmltidy](){:.rlib}
displays an easier-to-read version with indentations 
and line breaks in your Viewer pane.



~~~r
> library(htmltidy)
> html_view(doc)
~~~
{:title="Console" .no-eval .input}


![screenshot of html view]({% include asset.html path = 'images/html_view_screenshot.PNG' %}){:.small-image}

===

Searching the document for desired content is the hard part. This search
uses a CSS query to find the image below a section of the document with
attribute `id = comic`.



~~~r
> img <- doc %>%
+   html_nodes('#comic > img') 
> img
~~~
{:title="Console" .input}


~~~
{xml_nodeset (1)}
[1] <img src="//imgs.xkcd.com/comics/server_attention_span.png" title="They h ...
~~~
{:.output}


===

It is possible to query by CSS for a single element and extract
attributes such as the image title.



~~~r
img <- doc %>%
  html_node('#comic > img') 

img_attrs <- img %>%
  html_attrs()

img_attrs['title']
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


~~~
                                                                                                                                                                                                                                          title 
"They have to keep the adjacent rack units empty. Otherwise, half the entries in their /var/log/syslog are just 'SERVER BELOW TRYING TO START CONVERSATION *AGAIN*.' and 'WISH THEY'D STOP GIVING HIM SO MUCH COFFEE IT SPLATTERS EVERYWHERE.'" 
~~~
{:.output}


===

## Was that so bad?

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

Set `fill = TRUE` when you convert the html table into an R 
data frame, so that inconsistent numbers of columns in each row
are filled in.



~~~r
census_vars_doc <- read_html('https://api.census.gov/data/2017/acs/acs5/variables.html') %>% 
  html_node('table')

# This line takes a few moments to run.
census_vars <- html_table(census_vars_doc, fill = TRUE) 

head(census_vars)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


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

