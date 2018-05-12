#scrape table
library(rvest)
library(stringr)
library(RSelenium) # start a server with utility function
library(seleniumPipes)

url <- "https://coinmarketcap.com/coins/views/all/"
#key is to get the correct node
result <- read_html(url) %>% html_nodes("#currencies-all") %>% html_table()
df <- result[[1]]

#do some cleaning on the table: remove white space on name column
df$Name <- str_extract("(?<= ).*$",string = df$Name) %>% str_trim()
#trim white space on on circulating supply column
df$`Circulating Supply` <- df$`Circulating Supply` %>% 
    str_replace_all(pattern = fixed(","),replacement = "") %>% #delete comma
    str_extract("[0-9]+") # only keep numbers
    
head(df)
write.csv(df,"MISC/output/scraped_table.csv")
