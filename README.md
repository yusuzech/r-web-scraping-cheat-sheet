# Web Scraping Reference: Cheat Sheet for Web Scraping using R

Inspired by Hartley Brody, this cheat sheet is about web scraping with rvest,httr, and Rselenium. This is an r version of this blog https://blog.hartleybrody.com/web-scraping-cheat-sheet/.

While Hartley uses python's requests and beautifulsoup libraries. This cheatsheet covers the usage of httr and rvest. While rvest is good enough for many scraping tasks, httr is required for more advanced techniques. Also, usage of Rselenium(web driver) is also covered.

This cheat sheet contains many examples with real websites in [example_script](https://github.com/yusuzech/r-web-scraping-cheat-sheet/tree/master/example_script). Thus, if any examples do not work anymore, it may result from the changes in their HTML.

I also recommend the book [The Ultimate Guide to Web Scraping](https://blog.hartleybrody.com/guide-to-web-scraping/) by Hartley Brody. Though it uses Python libraries, the underlying logic of web scraping are the same. The same strategies can be applied using any languages including R.

**Why using R:**  

While Python has complete web scraping libraries like *beautiful soup*,*requests*,*scrapy*, etc, learning R libraries such as rvest/httr/Rselenium is much easier for most R users. Besides, one can make use of all other great R packages.

If you only need to scrape less than a couple hundreds of pages, the tutorials should be enough. However, if you need to scrape more pages, then you need to learn more about the advanced topics such as using user agent, using proxies, etc.

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
1. <a href="#other_topics">Uncovered Topics</a>

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

1. [Tutorial by Justin Law and Jordan Rosenblum](https://stat4701.github.io/edav/2015/04/02/rvest_tutorial/): web-scraping tutorial using rvest
2. [Tutorial by  SAURAV KAUSHIK](https://www.analyticsvidhya.com/blog/2017/03/beginners-guide-on-web-scraping-in-r-using-rvest-with-hands-on-knowledge/)  : web-scraping tutorial using rvest
3. [Tutorial by Hadley Wickham](http://blog.rstudio.com/2014/11/24/rvest-easy-web-scraping-with-r/)  : web-scraping tutorial using rvest  
4. [w3schools CSS selectors reference](https://www.w3schools.com/CSSref/css_selectors.asp) : if you forget CSS syntax, just check it here
5. [CSS Diner](https://flukeout.github.io/) : the easiest way to learn and understand CSS by playing games.

**Funtions and classes in rvest/httr:**
![](resources/functions_and_classes.png)



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

```r
library(httr)
response <- GET("http://example.com/page")
#or
response <- POST("http://example.com/page",
    body = list(a=1,b=2))
```

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
#retrieve content as parsed(parsed automatically)
content_parsed <- content(my_session$response,as = "parsed")
```

\*\*note:

Content maybe parsed incorrectly sometimes. For those situations, you can parse the content to text or raw and use other libraries or functions to parsed it correctly.

Search for specific string:

```r
library(stringr)
#regular expression can also be used here
if(str_detect(content_text,"blocked")){
    print("blocked from website")
    }
```

check content type:

```r
response$headers$`content-type`
```

check html structure:

```r
my_structure <- html_structure(content_parsed)
```

## 1.4. <a name="rvest4">Extracting Elements from HTML</a>

Using regular expression to scrape HTML is not a very good idea, but it does have its usage like scraping all emails from websites, there is a detailed discussion about this topic on [stackoverflow](https://stackoverflow.com/questions/1732348/regex-match-open-tags-except-xhtml-self-contained-tags).  

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

rvest can return a vector of elements or even table of elements, so it's easy to store it in R.

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

rvest and httr package provides some very useful functions, but they lack the function of:

+ prevent errors from breaking loops
+ auto retry requests
+ keep record of failed requests

So I wrote a wrapper function on html_session which can deal with the issues above and make web scraping scripts much more robust. The function and usage can be found in this [repository](https://github.com/yusuzech/r-web-scraping-template). 


### 1.7.1. <a name="rvest7.1">Javascript Heavy Websites</a>

For javascript heavy websites, there are three possible solutions:

1. Execute javascript in R
2. Use Developer tools(e.g. [Network in Chrome](https://developers.google.com/web/tools/chrome-devtools/network-performance/))
3. Using Rselenium or other web driver

There are pros and cons for each method:  
1. Executing Javascript in R is the most difficult one, since it requires some knowledge of Javascript, but it makes web-scraping javascript heavy websites possible with rvest.  
2. Using Developer tools is not difficult. The pro is that you only need to learn some examples and you can then work on it by yourself. The con is that if the website structure gets more completed, it require more knowledge of HTTP.
3. The Rselenium is absolutely the easiest solution. The pro is it's easy to learn and use. The con is that it can be unstable sometimes and related resources is very limited online. In many situations, you may need to refer to python codes with selenium package.

#### 1.Execute javascript

I'm not very familiar with Javascript, I learnt how to use it with this [post](https://datascienceplus.com/scraping-javascript-rendered-web-content-using-r/) 

#### 2.Use Developer tools

I learnt this trick fomr Hartley's blog, the following section are copied from his [post](https://blog.hartleybrody.com/web-scraping-cheat-sheet/):

>Contrary to popular belief, you do not need any special tools to scrape websites that load their content via Javascript. In order for the information to get from their server and show up on a page in your browser, that information had to have been returned in an HTTP response somewhere.
>
>It usually means that you won’t be making an HTTP request to the page’s URL that you see at the top of your browser window, but instead you’ll need to find the URL of the AJAX request that’s going on in the background to fetch the data from the server and load it into the page.
>
>There’s not really an easy code snippet I can show here, but if you open the Chrome or Firefox Developer Tools, you can load the page, go to the “Network” tab and then look through the all of the requests that are being sent in the background to find the one that’s returning the data you’re looking for. Start by filtering the requests to only XHR or JS to make this easier.
>
>Once you find the AJAX request that returns the data you’re hoping to scrape, then you can make your scraper send requests to this URL, instead of to the parent page’s URL. If you’re lucky, the response will be encoded with JSON which is even easier to parse than HTML.

So, as Hartley said, basically, everything displayed on your browser must be sent to you through JSON,HTML or other formats. What you need to do is to capture this file. 

The following link shows how to do this:

#### 3.Using Rselenium or other web driver

Rselenium launches a Chrome/Firefox/IE browser where you can simulate human actions like clicking on links, scrolling up or down.  

It is a very convenient tool and it will render JavaScript and Interactive content automatically, so you don't need to worry about the complex HTTP and AJAX stuff. But there are also some limitations to it:  

1. The first limitation is that:  it is very slow. Depending on the complexity of the websites, it could take seconds to render one page while using httr/rvest takes less than one second. It is fine if you only want to scrape several hundred pages. However, if you want scrape thousands or ten thousands of pages, the speed will become an issue.
2. The second limitation is that: There is little online resources on Rselenium. In many situations, you can't find related posts on Stack Overflow that solve your problem. You may need to refer to Python/Java Selenium posts for answers and sometimes answers can't be applied in R.

More detailed usage will be explained in **Web Scraping using Rselenium**.

### 1.7.2. <a name="rvest7.2">Content Inside iFrames</a>
### 1.7.3. <a name="rvest7.3">Sessions and Cookies</a>
### 1.7.4. <a name="rvest7.4">Delays and Backing Off</a>
### 1.7.5. <a name="rvest7.5">Spoofing the User Agent</a>
### 1.7.6. <a name="rvest7.6">Using Proxy Servers</a>
### 1.7.7. <a name="rvest7.7">Setting Timeouts</a>
### 1.7.8. <a name="rvest7.8">Handling Network Errors</a>
# 2. <a name="rselenium">Web Scraping using Rselenium</a>
## 2.1. <a name="rselenium1">Useful Libraries and Resources</a>
