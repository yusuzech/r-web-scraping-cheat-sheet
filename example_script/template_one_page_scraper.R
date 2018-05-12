Sys.setlocale("LC_ALL","English") #change system locale to ensure consistency
library(rvest) # web scraping library
library(RSelenium) # used for starting server
library(seleniumPipes) # use Selenium in a pipable way, can be used with rvest

rD <- rsDriver (browser = 'chrome',chromever = "latest",port = 4445L) #start the server, use port 4445 since port 4444 could be used by other softwares sometimes
remDr <- remoteDr(browserName = "chrome",port = 4445L) #open browser with seleniumPipes packge to use %>%

page_url <- "https://www.douyu.com/57321" # current page url

remDr %>% go(page_url) # navigate browser to current page

current_page_source <- remDr %>% 
    getPageSource() # get page source

# Do something here
#html_nodes(pagesource,"something")  css selector of the element
#html_text(node(s)  to extract text
#html_attr(node(s),"something")  to extract attributes
#html_attrs(node(s)) to extract all attributes
#html_name(nodes) to extract tags/names
#html_table to extract tables
    



remDr %>% deleteSession() #close current session
rD[["server"]]$stop()  # stop the server
    
