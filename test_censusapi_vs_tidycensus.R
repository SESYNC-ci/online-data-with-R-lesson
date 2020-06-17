# Compare code from tidycensus and censusapi

#1
library(censusapi)
source('api_key.R')

#2
variables <- c('NAME', 'B19013_001E')

#3
maryland_income_by_tract <- getCensus(name = 'acs/acs5', 
                                      vintage = 2017, 
                                      vars = variables, 
                                      region = 'tract:*', 
                                      regionin = 'state:24+county:*')

head(maryland_income_by_tract)

#4
library(ggplot2)

maryland_income_by_tract <- maryland_income_by_tract %>%
  rename(median_household_income = B19013_001E) %>%
  filter(median_household_income > 0) 

ggplot(maryland_income_by_tract, aes(x = county, y = median_household_income)) +
  geom_boxplot()

### tidycensus

#1
library(tidycensus)
source('api_key.R')

#2
variables <- c('NAME', 'B19013_001E')

#3
maryland_income_by_county <- get_acs(geography = 'county',
                                    variables = variables,
                                    state = 'MD',
                                    year = 2018,
                                    geometry = TRUE,
                                    key = Sys.getenv('CENSUS_KEY'))


library(ggplot2)

ggplot(maryland_income_by_county) + 
  geom_sf(aes(fill = estimate), color = NA) + 
  coord_sf() + 
  theme_minimal() + 
  scale_fill_viridis_c()
