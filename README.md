# Web Scraping Reference: Cheat Sheet for Web Scraping using R

Inspired by Hartley Brody, this cheat sheet is about web scraping with rvest,httr, and Rselenium. This is an r version of this blog https://blog.hartleybrody.com/web-scraping-cheat-sheet/.

While Hartley uses python's requests and beautifulsoup libraries, this cheat sheet covers the usage of httr and rvest. While rvest is good enough for many scraping tasks, httr is required for more advanced techniques. Also, usage of Rselenium(web driver) is also covered.

This cheat sheet contains many examples with real websites in [example_script](https://github.com/yusuzech/r-web-scraping-cheat-sheet/tree/master/example_script). Thus, if any examples do not work anymore, it may result from the changes in their HTML.

I also recommend the book [The Ultimate Guide to Web Scraping](https://blog.hartleybrody.com/guide-to-web-scraping/) by Hartley Brody. Though it uses Python libraries, the underlying logic of web scraping is the same. The same strategies can be applied using any languages including R.

In [some web scraping projects I did in R](https://github.com/yusuzech/web-scraping-projects), I used many stratigies as explained in the contents. If you don't know what to do with your web scraping project, you can definitely get some ideas from the projects.

# Table of Contents
1. <a href="#rvest">Web Scraping using rvest and httr</a>
    1. <a href="#rvest1">Useful Libraries and Resources</a>
    2. <a href="#rvest2">Making Simple Requests</a>
    3. <a href="#rvest3">Inspecting Response</a>
    4. <a href="#rvest4">Extracting Elements from HTML</a>
    5. <a href="#rvest5">Storing Data in R</a>
        1. <a href="#rvest5.1">Storing Data as list</a>
        2. <a href="#rvest5.2">Storing Data as data.frame</a>
    6. <a href="#rvest6">Saving Data to disk</a>
        1. <a href="#rvest6.1">Saving Data to csv</a>
        2. <a href="#rvest6.2">Saving Data to SQLite Database</a>
    7. <a href="#rvest7">More Advanced Topics</a>
        1. <a href="#rvest7.1">Javascript Heavy Websites</a>
        2. <a href="#rvest7.2">Content Inside iFrames</a>
        3. <a href="#rvest7.3">Sessions and Cookies</a>
        4. <a href="#rvest7.4">Delays and Backing Off</a>
        5. <a href="#rvest7.5">Spoofing the User Agent</a>
        6. <a href="#rvest7.6">Using Proxy Servers</a>
        7. <a href="#rvest7.7">Setting Timeouts</a>
        8. <a href="#rvest7.8">Handling Network Errors</a>
2. <a href="#rselenium">Web Scraping using Rselenium</a>
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

1. [Tutorial by Justin Law and Jordan Rosenblum](https://stat4701.github.io/edav/2015/04/02/rvest_tutorial/): web-scraping tutorial using rvest
2. [Tutorial by  SAURAV KAUSHIK](https://www.analyticsvidhya.com/blog/2017/03/beginners-guide-on-web-scraping-in-r-using-rvest-with-hands-on-knowledge/)  : web-scraping tutorial using rvest
3. [Tutorial by Hadley Wickham](http://blog.rstudio.com/2014/11/24/rvest-easy-web-scraping-with-r/)  : web-scraping tutorial using rvest 
4. [w3schools CSS selectors reference](https://www.w3schools.com/CSSref/css_selectors.asp) : if you forget CSS syntax, just check it here
5. [CSS Diner](https://flukeout.github.io/) : the easiest way to learn and understand CSS by playing games.
6. [Chrome CSS selector plugin](https://selectorgadget.com/): the best tool to use for choosing CSS selector.
7. [Stack Overflow](https://stackoverflow.com/) : You can find answers to most of your problems, no matter it's web scraping, rvest or CSS.

**Functions and classes in rvest/httr:**

Sometimes you may get confused about all the functions and classes you have. You can review this image at the moment.
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
#html_session is built upon httr, you can also get response with a session
response <- my_session$response
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
status_code(response)
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

Content may be parsed incorrectly sometimes. For those situations, you can parse the content to text or raw and use other libraries or functions to parse it correctly.

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

Using the regular expression to scrape HTML is not a very good idea, but it does have its usage like scraping all emails from websites, there is a detailed discussion about this topic on [stackoverflow](https://stackoverflow.com/questions/1732348/regex-match-open-tags-except-xhtml-self-contained-tags).  

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

Usually, rvest can return a vector, so it's very easy to store it.

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

<!-- 
rvest and httr package provides some handy functions, but they lack the function of:

+ prevent errors from breaking loops
+ auto retry requests
+ keep the record of failed requests

So I wrote a wrapper function on html_session which can deal with the issues above and make web scraping scripts much more robust. The function and usage can be found in this [repository](https://github.com/yusuzech/r-web-scraping-template). 
-->

### 1.7.1. <a name="rvest7.1">Javascript Heavy Websites</a>

For javascript heavy websites, there are three possible solutions:

1. Execute javascript in R
2. Use Developer tools(e.g. [Network in Chrome](https://developers.google.com/web/tools/chrome-devtools/network-performance/))
3. Using Rselenium or other web drivers

There are pros and cons of each method:  
1. Executing Javascript in R is the most difficult one since it requires some knowledge of Javascript, but it makes web-scraping javascript heavy websites possible with rvest.  
2. Using Developer tools is not difficult. The pro is that you only need to learn some examples and you can then work on it by yourself. The con is that if the website structure gets more completed, it requires more knowledge of HTTP.
3. The Rselenium is absolutely the easiest solution. The pro is it's easy to learn and use. The con is that it can be unstable sometimes and related resources are very limited online. In many situations, you may need to refer to python codes with selenium package.

#### 1.Execute javascript

I'm not very familiar with Javascript, and I learned how to use it with this [post](https://datascienceplus.com/scraping-javascript-rendered-web-content-using-r/) 

#### 2.Use Developer tools

I learned this trick from Hartley's blog; the following section is quoted from his [post](https://blog.hartleybrody.com/web-scraping-cheat-sheet/):

>Contrary to popular belief, you do not need any special tools to scrape websites that load their content via Javascript. For the information to get from their server and show up on a page in your browser, that information had to have been returned in an HTTP response somewhere.
>
>It usually means that you won’t be making an HTTP request to the page’s URL that you see at the top of your browser window, but instead you’ll need to find the URL of the AJAX request that’s going on in the background to fetch the data from the server and load it into the page.
>
>There’s not really an easy code snippet I can show here, but if you open the Chrome or Firefox Developer Tools, you can load the page, go to the “Network” tab and then look through the all of the requests that are being sent in the background to find the one that’s returning the data you’re looking for. Start by filtering the requests to only XHR or JS to make this easier.
>
>Once you find the AJAX request that returns the data you’re hoping to scrape, then you can make your scraper send requests to this URL, instead of to the parent page’s URL. If you’re lucky, the response will be encoded with JSON which is even easier to parse than HTML.

So, as Hartley said, basically, everything displayed on your browser must be sent to you through JSON, HTML or other formats. What you need to do is to capture this file. 

The following link shows how to do this:

#### 3.Using Rselenium or other web driver

Rselenium launches a Chrome/Firefox/IE browser where you can simulate human actions like clicking on links, scrolling up or down.  

It is a very convenient tool, and it renders JavaScript and Interactive content automatically, so you don't need to worry about the complex HTTP and AJAX stuff. However, there are also some limitations to it:  

1. The first limitation is that:  it is very slow. Depending on the complexity of the websites, it could take seconds to render a single page while using httr/rvest takes less than one second. It is fine if you only want to scrape several hundred pages. However, if you want scrape thousands or ten thousands of pages, then the speed will become an issue.
2. The second limitation is that: There are little online resources on Rselenium. In many situations, you can't find related posts on Stack Overflow that solve your problem. You may need to refer to Python/Java Selenium posts for answers, and sometimes answers can't be applied in R.

More detailed usage is explained in **Web Scraping using Rselenium**.

### 1.7.2. <a name="rvest7.2">Content Inside iFrames</a>

Iframes are other websites embedded in the websites you are viewing as explained on [Wikipedia](https://en.wikipedia.org/wiki/HTML_element#Frames):

> Frames allow a visual HTML Browser window to be split into segments, each of which can show a different document. This can lower bandwidth use, as repeating parts of a layout can be used in one frame, while variable content is displayed in another. This may come at a certain usability cost, especially in non-visual user agents,[[51\]](https://en.wikipedia.org/wiki/HTML_element#cite_note-58) due to separate and independent documents (or websites) being displayed adjacent to each other and being allowed to interact with the same parent window. Because of this cost, frames (excluding the `<iframe>` element) are only allowed in HTML 4.01 Frame-set. Iframes can also hold documents on different servers. In this case, the interaction between windows is blocked by the browser. 



Therefore, to extract content in an iframe, you need to find the link to that HTML.

```r
#example script
link_to_iframe <- my_session("www.example.com") %>%
    html_node("css to locate the iframe") %>%
    html_attr("src")
#make another request to the iframe and use this session to extract information
iframe_session <- html_session(link_to_iframe)
```



Here is a tutorial about iframes using [scrapethissite](https://blog.hartleybrody.com/web-scraping-cheat-sheet/#content-inside-iframes):

In this tutorial, we will get information embedded in an iframe: [**Tutorial Link**](example_script/iframe_tutorial.md)  



### 1.7.3. <a name="rvest7.3">Sessions and Cookies</a>

`rvest::html_session()` creates a session automatically, you can use `jump_to()` and `follow_link` to navigate to other web pages using the same session.



```r
library(rvest)
url1 <- "https://scrapethissite.com/"
url2 <- "https://scrapethissite.com/pages/simple/"
my_session <- html_session(url1)
my_session <- my_session %>% jump_to(url2) # navigate to another url
```



you can check session history:



```
> session_history(my_session)
  https://scrapethissite.com/
- https://scrapethissite.com/pages/simple/
```



 you can access the cookies:

```
library(httr)
cookies(my_session)
```



### 1.7.4. <a name="rvest7.4">Delays and Backing Off</a>

You can slow down your requests by pausing between requests:



```R
library(httr)
for(my_url in my_urls){
    response <- httr::GET(my_url)
    #do something
    Sys.sleep(5) # sleep 5 seconds
}
```



You can also decide how you wait by measuring how long the site took to respond. So why should you do it, as Hartley says:

> Some also recommend adding a backoff that’s proportional to how long the site took to respond to your request. That way if the site gets overwhelmed and starts to slow down, your code will automatically back off. 



```R
library(httr)
for(my_url in my_urls){
    t0 <- Sys.time()
    response <- httr::GET(my_url)
    t1 <- Sys.time()
    #do something
    response_delay <- as.numeric(t1-t0)
    Sys.sleep(10*response_delay) # sleep 10 times longer than response_delay
}

```



### 1.7.5. <a name="rvest7.5">Spoofing the User Agent</a>

**First of all, what is a user agent?**

> In computing, a user agent is software (a software agent) that is acting on behalf of a user. One common use of the term refers to a web browser telling a website information about the browser and operating system. This allows the website to customize content for the capabilities of a particular device, but also raises privacy issues.

In short, a user agent is a string that identifies you, and you can search "most popular browser user agents" on google to get a rough idea.

**So why should I use spoof user agent?**  

* You want to make your scraper look like a real user instead of a script. Some websites even don't allow an uncommon user agent to access.

```R
library(rvest)
my_session <- html_session("https://scrapethissite.com/")
# if you don't use custom user agent, your user agent will be something like:
# RUN: my_session$response$request$options$useragent
"libcurl/7.59.0 r-curl/3.2 httr/1.3.1"
```

**So how can I spoof it?**

```R
library(rvest)
library(httr)
#1.spoof it with common user agent
ua <- user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36")
seesion_with_ua <- html_session("https://scrapethissite.com/",ua)
#2.fill your contact information in user agent if you want the website owner to contact you
ua_string <- "Contact me at xyz123@gmail.com"
seesion_with_ua <- html_session("https://scrapethissite.com/",user_agent(ua_string))
```

### 1.7.6. <a name="rvest7.6">Using Proxy Servers</a>

Some servers automatically ban an IP if it sees abnormal traffic from that IP. The way to avoid it is to use proxies, so you can spread your requests among different IPs and reduce the chance of the server banning you. 

Though there are many free proxies available, paid ones are usually more reliable. One provider I use is "Proxy Bonanza."

Once you have free or paid proxies, you can use them when you make requests:

```R
library(rvest)
library(httr)
my_proxy <- use_proxy(url="http://example.com",
                     user_name = "myusername",
                     password = "mypassword",
                     auth = "one of basic, digest, digest_ie, gssnegotiate, ntlm, any")
#use it in html_session(),POST() or GET()
my_session <- html_session("https://scrapethissite.com/",my_proxy)
my_response <- GET("https://scrapethissite.com/",my_proxy)
```

### 1.7.7. <a name="rvest7.7">Setting Timeouts</a>

Sometimes you may encounter slow connections and want to move to other jobs instead of waiting. You can set timeout if you don't receive a response.    

```R
library(rvest)
library(httr)
my_session <- html_session("https://scrapethissite.com/",time(5)) # if you don't receive reponse within 5 seconds, it will throw an error

#you can use try() or tryCatch() to continue if the error occured
for(my_url in my_urls){
    try(GET(my_url,timeout(5)))
}
```

For detailed usage of `try()` and `tryCatch()`, you can check the following posts:

https://stackoverflow.com/questions/12193779/how-to-write-trycatch-in-r

### 1.7.8. <a name="rvest7.8">Handling Network Errors</a>

You can use `try()` or `tryCatch()` to handle unpredictable network issues.

You can retry if an error occurs. For more details, you can check the following posts:

https://stackoverflow.com/questions/20770497/how-to-retry-a-statement-on-error

# 2. <a name="rselenium">Web Scraping using Rselenium(In Progress)</a>
## 2.1. <a name="rselenium1">Useful Libraries and Resources</a>
