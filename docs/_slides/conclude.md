---
---

## Takeaway

- Web scraping is hard and unreliable, but sometimes there is no other option.
  
- Web services are the most common resource.

- Use a package specific to your API if one is available.

Web services do not always have great documentation---what parameters are
acceptable or necessary may not be clear. Some may even be poorly documented on
purpose if the API wasn't designed for public use! Even if you plan to acquire
data using the "raw" web service, try a search for a relevant package on CRAN.
The package documentation could help.
{:.notes}

**A final note on U.S. Census packages**: In this lesson, we use Kyle Walker's [tidycensus](){:.rlib}
package, but you might also want to take a look at Hannah Recht's
[censusapi](){:.rlib} or Ezra Glenn's [acs](){:.rlib}. All three
packages take slightly different approaches to obtaining data from the U.S.
Census API.
{:.notes}