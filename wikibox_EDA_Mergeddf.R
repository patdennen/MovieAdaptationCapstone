library(rvest)
library(glue)
library(janitor)
library(tidyverse)

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
nrow(movies)

movies$worldwide <- parse_number(movies$worldwide)
movies$domestic <- parse_number(movies$domestic)

movies2 <- movies[!is.na(movies$domestic) & !is.na(movies$worldwide),]

ggplot(data = movies2) +
  geom_point(mapping = aes(x = movies2$year, y = movies2$worldwide)) +
  labs(x = "Year of Movie Release", y = "Worldwide Revanue ($)",
       title = "Worldwide Revanue for Movies By Release Year")

ggplot(data = movies2) +
  geom_histogram(aes(x = worldwide), bins = 60) +
  labs(title = "How Much did Movies Make", x = "Worldwide Revanue", y = "Frequency")

buckets <- movies2 |>
  group_by(year) |>
  summarize(summed = sum(worldwide))

ggplot(data = buckets) +
  geom_line(aes(x = year, y = summed)) +
  labs(x = "Year", y = "Total Worldwide Revanue", title = 
         "Total Worldwide Revanue Over Time")

wiki <- read_csv("wiki_books.csv")

#gets the numbers within the parentheses
hits <- regmatches(wiki$Book, gregexpr("\\([^()]*\\)", wiki$Book, perl = TRUE))
hits_movie <- regmatches(wiki$Movie, gregexpr("\\([^()]*\\)", wiki$Movie, perl = TRUE))

# Helper: from the vector of "(...)" chunks in one row, find the first plausible year
extract_year <- function(vec) {
  if (length(vec) == 0) return(NA_integer_)
  # find 4-digit year 1400–2099 inside the parentheses text (first occurrence wins)
  m <- unlist(regmatches(vec, gregexpr("(?<!\\d)(1[4-9]\\d{2}|20\\d{2})(?!\\d)", vec, perl = TRUE)))
  if (!length(m)) return(NA_integer_)
  as.integer(m[1])
}

wiki$book_year <- vapply(hits, extract_year, integer(1))
wiki$movie_year <- vapply(hits_movie, extract_year, integer(1))
wiki$time_diff <- wiki$movie_year-wiki$book_year

wiki = wiki[!is.na(wiki$time_diff),]

sum(wiki$time_diff ==0)

ggplot(data = wiki) +
  geom_bar(aes(x = time_diff)) +
  labs(x = "Time Difference (Years)",
       y = "Frequency",
       title = "Time Difference Between Book and Movie Release")


#weird books
wiki[190,2] #would probably need to take special care of a few

wiki[865,2] #some dont have date

#weird movies
wiki[1,3]

#___________________________________________________________________________
wiki$Movie <- if_else(grepl("(", wiki$Movie, fixed = TRUE), 
                      trimws(unlist(str_split(wiki$Movie, "\\(", simplify = T)
                                    [,1])), wiki$Movie)


#vapply(wiki$Movie, strsplit(wiki$Movie, "\\(")[1], integer(1))


merged_df <- merge(movies2, wiki, on = 'Movie')
View(merged_df)

#7 times - where it is split and it isn't a date
#manually checked and these were not in the wiki df
movies2[grepl("(", movies2$Movie, fixed = TRUE),]

ggplot(data = merged_df) +
  geom_point(mapping = aes(x = time_diff, y = worldwide), color = "purple") +
  labs(x = "Difference in Time (Years)", y = "World Wide Revanue ($)",
       title = "World Wide Revanue Depending on the Difference Between Book Relaese and Movie Release")

