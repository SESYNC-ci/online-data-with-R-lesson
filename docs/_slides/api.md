---
---

## Web Services

The US Census Bureau provides access to its vast stores of demographic
data over the Web via their API at <https://api.census.gov>.

===

The **I** in **GUI** is for interface---it's the same in **API**, where buttons
and drop-down menus are replaced by functions and object attributes.

Instead of interfacing with a user, this kind of **i**nterface is suitable for
use in **p**rogramming another software **a**pplication. In the case of the
Census, the main component of the application is some relational database
management system. There are several GUIs designed for humans to
query the Census database; the Census API is meant for communication between
your program (i.e. script) and their application.
{:.notes}

You'll often see the acronym "REST API." In this context, **REST** stands for
**Re**presentational **s**tate **t**ransfer. This refers to a set of standards that
help ensure that the Web service works well with any computer system it 
may interact with.
{:.notes}

The following code acquires data from the US Census Bureau's American Community Survey (ACS).
The ACS is a yearly survey that provides detailed population
and housing information at fine geographic scale across the United States. 
ACS5 refers to a five-year average of the annual surveys.
{:.notes}

===

Look carefully at [this URL](https://api.census.gov/data/2018/acs5?get=NAME&for=county:*&in=state:24#irrelephant){:target="_blank"}. 

The URL is a query to the US Census API. The parameters after the `?`
request the variable `NAME` for all counties in state `24` (Maryland).

In a web service, the already universal system for
transferring data over the internet, known as HTTP, is half of the
interface. All you really need is documentation for how to construct
the URL in a standards-compliant way that the service will recognize.
{:.notes}

===

| Section | Description |  
|---+---|
| `https://`        | **scheme** |
| `api.census.gov`  | **authority**, or simply domain if there's no user authentication |
| `/data/2018/acs/acs5` | **path** to a resource within a hierarchy |
|---+---|
| `?`          | beginning of the **query** component of a URL |
| `get=NAME`   | first query parameter |
| `&`          | query parameter separator |
| `for=county:*` | second query parameter |
| `&`          | query parameter separator |
| `in=state:24` | third query parameter |
|---+---|
| `#`          | beginning of the **fragment** component of a URL |
| `irrelephant` | a document section, it isn't even sent to the server |

===

To construct the URL in R and send the query to the API, use `GET()` from 
[httr](){:.rlib}. 

The first argument to `GET()` is the base URL, and the 
`query` argument is a named list that passes 
the parameters of the query to the API. All the elements
of the list should be character strings.
{:.notes}



~~~r
path <- 'https://api.census.gov/data/2018/acs/acs5'
query_params <- list('get' = 'NAME,B19013_001E', 
                     'for' = 'county:*',
                     'in' = 'state:24')

response <- GET(path, query = query_params)
response
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


~~~
Response [https://api.census.gov/data/2018/acs/acs5?get=NAME%2CB19013_001E&for=county%3A%2A&in=state%3A24]
  Date: 2021-12-01 14:50
  Status: 200
  Content-Type: application/json;charset=utf-8
  Size: 1.25 kB
[["NAME","B19013_001E","state","county"],
["Howard County, Maryland","117730","24","027"],
["Prince George's County, Maryland","81969","24","033"],
["Anne Arundel County, Maryland","97810","24","003"],
["Baltimore County, Maryland","74127","24","005"],
["Frederick County, Maryland","91999","24","021"],
["Calvert County, Maryland","104301","24","009"],
["Garrett County, Maryland","49619","24","023"],
["Kent County, Maryland","56009","24","029"],
["Montgomery County, Maryland","106287","24","031"],
...
~~~
{:.output}


===

## Response Header

The response from the API is a bunch of 0s and 1s, but part of the
HTTP protocol is to include a "header" with information about how
to decode the body of the response.

The output of `GET()` has already decoded the body of the response
from binary format.
{:.notes}

===

Most REST APIs return as the "content" either:

1. Javascript Object Notation (JSON)
  - a UTF-8 encoded string of key-value pairs, where values may be lists
  - e.g. `{'a':24, 'b': ['x', 'y', 'z']}`
1. eXtensible Markup Language (XML)
  - a nested `<tag></tag>` hierarchy serving the same purpose

===

The header from Census says the content type is JSON.



~~~r
response$headers['content-type']
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


~~~
$`content-type`
[1] "application/json;charset=utf-8"
~~~
{:.output}


===

## Response Content

First, use `httr::content()` to retrieve
the JSON content of the response. Use `as = 'text'` to
get the content as a character vector. Then use
`jsonlite::fromJSON()` to convert to a matrix.



~~~r
library(jsonlite)
county_income <- response %>%
  content(as = 'text') %>%
  fromJSON()
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


===



~~~r
> county_income
~~~
{:title="Console" .input}


~~~
      [,1]                               [,2]          [,3]    [,4]    
 [1,] "NAME"                             "B19013_001E" "state" "county"
 [2,] "Howard County, Maryland"          "117730"      "24"    "027"   
 [3,] "Prince George's County, Maryland" "81969"       "24"    "033"   
 [4,] "Anne Arundel County, Maryland"    "97810"       "24"    "003"   
 [5,] "Baltimore County, Maryland"       "74127"       "24"    "005"   
 [6,] "Frederick County, Maryland"       "91999"       "24"    "021"   
 [7,] "Calvert County, Maryland"         "104301"      "24"    "009"   
 [8,] "Garrett County, Maryland"         "49619"       "24"    "023"   
 [9,] "Kent County, Maryland"            "56009"       "24"    "029"   
[10,] "Montgomery County, Maryland"      "106287"      "24"    "031"   
[11,] "Carroll County, Maryland"         "93363"       "24"    "013"   
[12,] "Queen Anne's County, Maryland"    "92167"       "24"    "035"   
[13,] "St. Mary's County, Maryland"      "90438"       "24"    "037"   
[14,] "Charles County, Maryland"         "95924"       "24"    "017"   
[15,] "Dorchester County, Maryland"      "52145"       "24"    "019"   
[16,] "Washington County, Maryland"      "59719"       "24"    "043"   
[17,] "Wicomico County, Maryland"        "56608"       "24"    "045"   
[18,] "Cecil County, Maryland"           "72845"       "24"    "015"   
[19,] "Caroline County, Maryland"        "54956"       "24"    "011"   
[20,] "Worcester County, Maryland"       "61145"       "24"    "047"   
[21,] "Talbot County, Maryland"          "67204"       "24"    "041"   
[22,] "Baltimore city, Maryland"         "48840"       "24"    "510"   
[23,] "Somerset County, Maryland"        "42165"       "24"    "039"   
[24,] "Harford County, Maryland"         "85942"       "24"    "025"   
[25,] "Allegany County, Maryland"        "44065"       "24"    "001"   
~~~
{:.output}


Notice that the matrix created by `fromJSON()` does not recognize that the first
row is a header, resulting in all columns being classified as 
character. This is a typical situation when parsing Web content, and would require
additional data wrangling to fix.
{:.notes}

===

## API Keys & Limits

Most servers request good behavior, others enforce it.

- Size of single query
- Rate of queries (calls per second, or per day)
- User credentials specified by an API key

===

From the Census FAQ [What Are the Query Limits?](https://www.census.gov/data/developers/guidance/api-user-guide.Query_Components.html):

>You can include up to 50 variables in a single API query and can make
>up to 500 queries per IP address per day...  Please keep in mind that
>all queries from a business or organization having multiple employees
>might employ a proxy service or firewall. This will make all of the
>users of that business or organization appear to have the same IP
>address.
