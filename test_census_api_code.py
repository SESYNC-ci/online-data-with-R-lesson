from census import Census

# Not sure what this is doing
key = None
c = Census(key, year=2017)
c.acs5

# Define variables to extract (name and median household income) and get them for all counties and tracts in state 24
variables = ('NAME', 'B19013_001E')

response = c.acs5.state_county_tract(
  variables,
  state_fips='24',
  county_fips=Census.ALL,
  tract=Census.ALL,
)
response[0]

# Convert to dataframe while also subsetting by income greater than zero
df = (
  pd
  .DataFrame(response)
  .query("B19013_001E >= 0")
)

# just make a boxplot by county
import seaborn as sns

sns.boxplot(
  data = df,
  x = 'county',
  y = 'B19013_001E',
)
