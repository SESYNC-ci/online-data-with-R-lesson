pdo_url <- "http://jisao.washington.edu/pdo/PDO.latest"
pdo_raw <- xml2::read_html(pdo_url)
pdo_node <- rvest::html_node(pdo_raw, "p")
pdo_text <- rvest::html_text(pdo_node)

library(stringr)

# Use gsub with a regular expression that gets all the text between 2017 and 2018
pdo_text_2017 <- gsub(".*2017|2018.*", "", pdo_text)

# In str_replace_all version
str_replace_all(pdo_text, '^(.*2017)', '')

pdo_text_2017 <- str_match(pdo_text, "(?<=2017).*.(?=\\n2018)")

# Use str_extract_all to separate each of the 12 numeric values from the string.
str_extract_all(pdo_text_2017[1], "[0-9-.]+")
