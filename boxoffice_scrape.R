library(rvest)
library(glue)
library(janitor)

all_tables <- list()

for (i in 1977:2025) {
  website <- glue("https://www.boxofficemojo.com/year/world/{i}/")
  
  message("Scraping year: ", i)
  page <- read_html(website)
  
  table <- page %>%
    html_element("table") %>%
    html_table(fill = TRUE)
  
  if (!is.null(table)) {
    table <- table %>%
      janitor::clean_names() %>%
      dplyr::mutate(year = i)   # add the year so you know where it came from
    
    all_tables[[as.character(i)]] <- table
  }
}

# bind them into one big dataframe
movies <- dplyr::bind_rows(all_tables)

head(movies)


