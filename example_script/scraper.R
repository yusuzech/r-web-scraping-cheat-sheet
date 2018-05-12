#This script does the hardest part:
#1.work with iframe
#2.simulating clicks on webpage or on iframe(where web url doesn't change)
#3.scrape javascript generated values
#4.use CSS selector
#A solution using seleniumPipes package: install phantomjs ,unzip it and put in in your R working directory
#More features could be added(e.g. loop all pages, add more information like names, company names and etc.)
library(tidyverse)
library(rvest)
library(RSelenium) # start a server with utility function
library(seleniumPipes)
rD <- rsDriver (browser = 'chrome',chromever = "latest",port = 4445L)
#open browser
remDr <- remoteDr(browserName = "chrome",port = 4445L)

main_page_url <- "http://www.napo.net/search/newsearch.asp"
#go to home page
remDr %>% go(main_page_url)
#switch to iframe
remDr %>% switchToFrame(Id = "SearchResultsFrame")
#get all relative path
relative_path <- remDr %>% getPageSource() %>% html_nodes(".lineitem a[href]") %>% html_attr("href")
#all individual urls:
full_paths <- paste0("http://www.napo.net",relative_path)
#scrape email from each page
email_address <- list()
global_counter <- 1
#Retrieve email adress from the first three results
for(i in seq_along(full_paths)){
    remDr %>% go(full_paths[i])
    email_adress <- remDr %>% getPageSource()  %>% html_nodes('a[href^="mailto"]') %>% html_text()
    temp_list <- list(NULL)
    names(temp_list) <- global_counter
    temp_list[[as.character(global_counter)]]$ind <- global_counter
    temp_list[[as.character(global_counter)]]$email <- email_adress
    email_address <- c(email_address,temp_list)
    global_counter <<- global_counter + 1
    Sys.sleep(3)
}
#Turn page ------------------
#Above are all for page one, if you want to turn to page two:
remDr %>% go(main_page_url)
remDr %>% switchToFrame(Id = "SearchResultsFrame")
#click on page two on iframe to turn to page 2:
remDr %>% findElement(using = "css selector",value = ".DotNetPager a:nth-child(2)") %>% elementClick()
#get relative and full path again
relative_path <- remDr %>% getPageSource() %>% html_nodes(".lineitem a[href]") %>% html_attr("href")
full_paths <- paste0("http://www.napo.net",relative_path)
#And you can do the for loop again
for(i in seq_along(full_paths)){
    remDr %>% go(full_paths[i])
    email_adress <- remDr %>% getPageSource()  %>% html_nodes('a[href^="mailto"]') %>% html_text()
    temp_list <- list(NULL)
    names(temp_list) <- global_counter
    temp_list[[as.character(global_counter)]]$ind <- global_counter
    temp_list[[as.character(global_counter)]]$email <- email_adress
    email_address <- c(email_address,temp_list)
    global_counter <<- global_counter + 1
    Sys.sleep(3)
}
#-----
#delete session and close server
remDr %>% deleteSession()
rD[["server"]]$stop() 

#result
result <- email_address
for(i in 1: length(result)){
    result[[i]]$email <- ifelse(identical(result[[i]]$email,character(0)),NA,result[[i]]$email)
}

info <- result %>% map_df(as.data.frame)

#save result

write.csv(info,"result.csv",row.names = FALSE) 
