# Web Scraping Reference: Cheat Sheet for Web Scraping using R

Inspired by Hartley Brody, this cheat sheet is about web scraping with rvest,httr, and Rselenium. This is an r version of this blog https://blog.hartleybrody.com/web-scraping-cheat-sheet/. So the table of contents is similar.

While Hartley uses python's requests and beautifulsoup libraries. This cheat covers the usage of httr and rvest. While rvest is good enough for many scraping tasks, httr is required for more advanced techniques. Also, usage of Rselenium(web driver) is also covered.

This cheat sheet contains many examples with real websites. Thus, if any examples do not work anymore, it may result from the changes in their HTML.

# Talbe of Contents
1. <a href="#rvest">Web Scraping using rvest and httr</a>
    1. <a href="#rvest1">Useful Libraries and Resources</a>
    1. <a href="#rvest2">Making Simple Requests</a>
    1. <a href="#rvest3">Inspecting Response</a>
    1. <a href="#rvest4">Extracting Elements from HTML</a>
    1. <a href="#rvest5">Storing Data in R</a>
        1. <a href="#rvest5.1">Storing Data as list</a>
        1. <a href="#rvest5.2">Storing Data as data.frame</a>
    1. <a href="#rvest6">Saving Data to disk</a>
        1. <a href="#rvest6.1">Saving Data to csv</a>
        1. <a href="#rvest6.2">Saving Data to SQLite Database</a>
    1. <a href="#rvest7">More Advanced Topics</a>
        1. <a href="#rvest7.1">Javascript Heavy Websites</a>
        1. <a href="#rvest7.2">Content Inside iFrames</a>
        1. <a href="#rvest7.3">Sessions and Cookies</a>
        1. <a href="#rvest7.4">Delays and Backing Off</a>
        1. <a href="#rvest7.5">Spoofing the User Agent</a>
        1. <a href="#rvest7.6">Using Proxy Servers</a>
        1. <a href="#rvest7.7">Setting Timeouts</a>
        1. <a href="#rvest7.8">Handling Network Errors</a>
1. <a href="#rselenium">Web Scraping using Rselenium</a>
    1. <a href="#rselenium1">Useful Libraries and Resources</a>

# 1. <a name="rvest">Web Scraping using rvest and httr</a>
## 1.1. <a name="rvest1">Useful Libraries and Resources</a>

[rvest](https://github.com/hadley/rvest) is built upon the xml2 package and also accept config from the httr package. For the most part, we only need rvest. If we want to add extra configurations, we also need httr.

To install those two packages:

```r
install.packages("rvest")
install.packages("httr")
```

To load them:

```r
require(rvest)
require(httr)
```

There are many tutorials available online; these are what I found to be most useful:

[Tutorial by Justin Law and Jordan Rosenblum](https://stat4701.github.io/edav/2015/04/02/rvest_tutorial/)  
[Tutorial by  SAURAV KAUSHIK](https://www.analyticsvidhya.com/blog/2017/03/beginners-guide-on-web-scraping-in-r-using-rvest-with-hands-on-knowledge/)  
[Tutorial by Hadley Wickham](http://blog.rstudio.com/2014/11/24/rvest-easy-web-scraping-with-r/)


## 1.2. <a name="rvest2">Making Simple Requests</a>

rvest provides two ways of making request: `read_html()` and `html_session()`  
`read_html()` can parse a HTML file or an url into xml document. `html_session()` is built on `GET()` from httr package and can accept configurations any additonal httr config.  

Reading a url:

```r
#making GET request andparse website into xml document
pagesource <- html_read("http://example.com/page")

#using html_session which creates a session and accept httr methods
my_session <- html_session("http://example.com/page")
```

Alternatively, GET and POST method are available in the httr package.

## 1.3. <a name="rvest3">Inspecting Response</a>

Check status code:

```r
status_code(my_session)
```

Get response and content:

```r
#response
response <- my_session$response
#retrieve content as raw
content_raw <- content(my_session$response,as = "raw")
#retrieve content as text
content_text <- content(my_session$response,as = "text")
#retrieve content as parsed
content_parsed <- content(my_session$response,as = "parsed")
```

Search for specific string:

```r
library(stringr)
#regular expression can b used here
if(str_detect(content_text,"blocked")){
    print("blocked from website")
    }
```

check content type:

```r
content_type <- response$headers$`content-type`
```

## 1.4. <a name="rvest4">Extracting Elements from HTML</a>

Using regular expression to scrape HTML is not a very good idea, but it does have it usage like scraping all eamails from websites, there is a detailed discussion about this topic on [stackoverflow](https://stackoverflow.com/questions/1732348/regex-match-open-tags-except-xhtml-self-contained-tags).  

**Using rvest:**

I will scrape https://scrapethissite.com/ for demonstration, since it has static HTML:  

For the purpose of extracting elements, using `read_html()` or `html_session()` are both fine. When using `read_html()`, it returns a xml_document. When using `html_session()`, it creates a session and the response is included.

```r
my_session <- html_session("https://scrapethissite.com/pages/simple/")
```

Look for nodes:

```r
my_nodes <- my_session %>% html_nodes(".country")
```

Look for attributes:

```r
my_attributes <- my_session %>% html_nodes(".country-capital") %>% html_attr("class")
```

Look for texts:

```r
my_texts <- my_session %>% html_nodes(".country-capital") %>% html_text()
```

## 1.5. <a name="rvest5">Storing Data in R</a>

rvest can return a vector of elements or even table of elements, so it's  easy to store it in R.

### 1.5.1. <a name="rvest5.1">Storing Data as list</a>

Normally, rvest can return a vector, so it's very easy to store it.

```r
my_texts <- my_session %>% html_nodes(".country-capital") %>% html_text()
```

### 1.5.2. <a name="rvest5.2">Storing Data as data.frame</a>

We can concatenate vectors in a table or using `html_table()` to extract a HTML table directly into a data.frame.

```r
my_country <- my_session %>% html_nodes(".country-name") %>% html_text()
my_capitals <- my_session %>% html_nodes(".country-capital") %>% html_text()
my_table <- data.frame(country = my_country, capital = my_capitals)
```

## 1.6. <a name="rvest6">Saving Data to disk</a>
### 1.6.1. <a name="rvest6.1">Saving Data to csv</a>

If the data is already stored as a data.frame:

```r
write.csv(my_table,file="my_table.csv")
```

### 1.6.2. <a name="rvest6.2">Saving Data to SQLite Database</a>

After creating the database "webscrape.db":

```r
library(RSQLite)
connection <- dbConnect(SQLite(),"webscrape.db")
dbWriteTable(conn = connection,name = "country_capital",value = my_table)
dbDisconnect(conn = connection)
```

## 1.7. <a name="rvest7">More Advanced Topics</a>
### 1.7.1. <a name="rvest7.1">Javascript Heavy Websites</a>
### 1.7.2. <a name="rvest7.2">Content Inside iFrames</a>
### 1.7.3. <a name="rvest7.3">Sessions and Cookies</a>
### 1.7.4. <a name="rvest7.4">Delays and Backing Off</a>
### 1.7.5. <a name="rvest7.5">Spoofing the User Agent</a>
### 1.7.6. <a name="rvest7.6">Using Proxy Servers</a>
### 1.7.7. <a name="rvest7.7">Setting Timeouts</a>
### 1.7.8. <a name="rvest7.8">Handling Network Errors</a>
# 2. <a name="rselenium">Web Scraping using Rselenium</a>
## 2.1. <a name="rselenium1">Useful Libraries and Resources</a>
