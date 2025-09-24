# Data scrape for wikipedia list

library(rvest)
library(tibble)
library(dplyr)

#Gather Data
##########
#Numbers - C
url1 <- "https://en.wikipedia.org/wiki/List_of_fiction_works_made_into_feature_films_(0%E2%80%939,_A%E2%80%93C)"
webpage <- read_html(url1)

MoviesA_C <- webpage %>%
  html_element("#mw-content-text :nth-child(1)") %>% # <-- This came directly from SelectorGadget!
  html_table()


#D-J
url2 <- "https://en.wikipedia.org/wiki/List_of_fiction_works_made_into_feature_films_(D%E2%80%93J)"
webpage <- read_html(url2)

MoviesD_J <- webpage %>%
  html_element("#mw-content-text :nth-child(1)") %>%
  html_table()


#K-R
url3 <- "https://en.wikipedia.org/wiki/List_of_fiction_works_made_into_feature_films_(K%E2%80%93R)"
webpage <- read_html(url3)

MoviesK_R <- webpage %>%
  html_element("#mw-content-text :nth-child(1)") %>%
  html_table()


#K-R
url4 <- "https://en.wikipedia.org/wiki/List_of_fiction_works_made_into_feature_films_(S%E2%80%93Z)"
webpage <- read_html(url4)

MoviesS_Z <- webpage %>%
  html_element("#mw-content-text :nth-child(1)") %>%
  html_table()
#######

#concat
df<-tibble(rbind(MoviesA_C,MoviesD_J,MoviesK_R,MoviesS_Z))

#rename columns
df %>%
  rename(
    Book = X1,
    Movie = X2
  )

#remove blanks
df <- df[df$X1 != "", ]

#remove header
wikiDF <- df[df$X1 != "Fiction work(s)", ]

#download file
write.csv(wikiDF, "/Users/patrickdennen/Desktop/capstone/df_clean.csv", row.names = FALSE)







