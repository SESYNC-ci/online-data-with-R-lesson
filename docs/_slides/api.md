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

===

Inspect [this URL](https://api.census.gov/data/2015/acs5?get=NAME&for=county&in=state:24#irrelephant){:target="_blank"} in your browser.

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
| `/data/2015/acs5` | **path** to a resource within a hierarchy |
|---+---|
| `?`          | beginning of the **query** component of a URL |
| `get=NAME`   | first query parameter |
| `&`          | query parameter separator |
| `for=county` | second query parameter |
| `&`          | query parameter separator |
| `in=state:*` | third query parameter |
|---+---|
| `#`          | beginning of the **fragment** component of a URL |
| `irrelephant` | a document section, it isn't even sent to the server |

===



~~~r
path <- 'https://api.census.gov/data/2017/acs/acs5'
query_params <- list('get' = 'NAME,B19013_001E', 
                     'for' = 'tract:*',
                     'in' = 'state:24')

response = GET(path, query = query_params)
response
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


~~~
Response [https://api.census.gov/data/2017/acs/acs5?get=NAME%2CB19013_001E&for=tract%3A%2A&in=state%3A24]
  Date: 2020-06-18 01:38
  Status: 200
  Content-Type: application/json;charset=utf-8
  Size: 115 kB
[["NAME","B19013_001E","state","county","tract"],
["Census Tract 105.01, Wicomico County, Maryland","68652","24","045","010501"],
["Census Tract 5010.02, Carroll County, Maryland","75069","24","013","501002"],
["Census Tract 5077.04, Carroll County, Maryland","88306","24","013","507704"],
["Census Tract 5061.02, Carroll County, Maryland","84810","24","013","506102"],
["Census Tract 5061.01, Carroll County, Maryland","95075","24","013","506101"],
["Census Tract 5052.06, Carroll County, Maryland","91908","24","013","505206"],
["Census Tract 5052.08, Carroll County, Maryland","106116","24","013","505208"],
["Census Tract 5081.02, Carroll County, Maryland","76083","24","013","508102"],
["Census Tract 5081.01, Carroll County, Maryland","84821","24","013","508101"],
...
~~~
{:.output}


===

## Response Header

The response from the API is a bunch of 0s and 1s, but part of the
HTTP protocol is to include a "header" with information about how
to decode the body of the response.

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
the JSON content of the response as a character vector, then
`jsonlite::fromJSON()` to convert it to a data frame.



~~~r
library(jsonlite)
maryland_income <- response %>%
  content(as = 'text') %>%
  fromJSON()

head(maryland_income)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


~~~
     [,1]                                             [,2]          [,3]   
[1,] "NAME"                                           "B19013_001E" "state"
[2,] "Census Tract 105.01, Wicomico County, Maryland" "68652"       "24"   
[3,] "Census Tract 5010.02, Carroll County, Maryland" "75069"       "24"   
[4,] "Census Tract 5077.04, Carroll County, Maryland" "88306"       "24"   
[5,] "Census Tract 5061.02, Carroll County, Maryland" "84810"       "24"   
[6,] "Census Tract 5061.01, Carroll County, Maryland" "95075"       "24"   
     [,4]     [,5]    
[1,] "county" "tract" 
[2,] "045"    "010501"
[3,] "013"    "501002"
[4,] "013"    "507704"
[5,] "013"    "506102"
[6,] "013"    "506101"
~~~
{:.output}


The data frame extracted here does not recognize that the first
row is a header, resulting in all columns being classified as 
character. This is a typical situation when parsing Web content. 
You can try to fix this problem as an optional exercise.
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
