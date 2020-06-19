---
---

## Acquiring Online Data

Data is available on the web in many different forms. How difficult is it to 
acquire that data to run analyses? It depends which of three approaches
the data source requires:

- Web scraping
- Web service (API)
- Specialized package (API wrapper)

===

## Web Scraping 🙁

A web browser reads HTML and JavaScript and displays a human readable page. In
contrast, a web scraper is a program (a "bot") that reads HTML and JavaScript 
and stores the data.

===

## Web Service (API) 😉

API stands for Application Programming Interface (API, as opposed to GUI) that is compatible
with passing data around the internet using HTTP (Hyper-text Transfer Protocol).
This is not the fastest protocol for moving large datasets, but it is universal
(it underpins web browsers, after all).

===

## Specialized Package 😂

Major data providers can justify writing a "wrapper" package for their API, 
specific to yourlanguage of choice (e.g. Python or R), that facilitates accessing the
data they provide through a web service. Sadly, not all do so.