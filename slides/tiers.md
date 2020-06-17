---
---

## Acquiring Online Data

Data is available on the web in many different forms. How difficult is it to 
acquire that data to run analyses? It depends which of three approaches
the data source requires:

- Web scraping
- Web service or API
- API wrapper

===

## Web Scraping 🙁

If a web browser can read HTML and JavaScript and display a human readable page,
why can't you write a program (a "bot") to read HTML and JavaScript and store the
data?

===

## Web Service or API 😉

An Application Programming Interface (API, as opposed to GUI) that is compatible
with passing data around the internet using HTTP (Hyper-text Transfer Protocol).
This is not the fastest protocol for moving large datasets, but it is universal
(it underpins web browsers, after all).

===

## API Wrapper 😂

Major data providers can justify writing a package, specific to your
language of choice (e.g. Python or R), that facilitates accessing the
data they provide through a web service. Sadly, not all do so.