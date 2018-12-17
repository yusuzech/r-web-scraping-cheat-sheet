# Speed Comparison between `for` and `foreach` loop



## Prepare the data

Let's get a list of URLs to start with:

```R
library(rvest)
library(stringr)
library(doParallel)
url_wiki <- "https://en.wikipedia.org/wiki/List_of_most_popular_websites"
my_css <- "td:nth-child(2)"
wikipedia <- html_session(url_wiki)

#get top 20 websites
urls <- wikipedia %>%
    html_nodes(my_css) %>%
    html_text() %>%
    str_trim() %>%
    .[1:20]
```



Let's display top twenty websites:

```R
urls
```



The result is:

```R
 [1] "google.com"    "youtube.com"   "facebook.com"  "baidu.com"     "wikipedia.org" "reddit.com"    "yahoo.com"     "qq.com"        "taobao.com"    "google.co.in" 
[11] "amazon.com"    "tmall.com"     "twitter.com"   "sohu.com"      "instagram.com" "vk.com"        "live.com"      "jd.com"        "sina.com.cn"   "weibo.com"   
```



## Making requests and compare speed

To compare the speed, we will extract title from each website.

**Using `foreach` loop for web scraping in parallel**

```R
cl <- makeCluster(detectCores()-1)
registerDoParallel(cl)
t1 <- Sys.time()
result <- foreach(i = seq_along(urls),
                  .packages = "rvest",
                  .combine = "c",
                  .errorhandling='pass') %dopar% {
                      # get the header for each page
                      title <- html_session(urls[i]) %>% 
                          html_node("head") %>% 
                          html_node("title") %>% 
                          html_text()
                      return(list(title))
                  }
t2 <- Sys.time()
t_parallel <- t2 - t1
```

**Using `for` loop**

```R
result2 <- list()
t1 <- Sys.time()
for(url in urls){
    title <- try(html_session(url) %>% 
        html_node("head") %>% 
        html_node("title") %>% 
        html_text())
    result2 <- append(result2,list(title))
}
t2 <- Sys.time()
t_for <- t2 - t1
```



**Difference in speed between parallel and non-parallel**

````R
> data.frame(t_parallel,t_for)
     t_parallel         t_for
1 5.357209 secs 20.48356 secs
````



In this example, `foreach` loop is about 4 times faster than `for` loop. The exact speed will differ depending on number of cores on your machine and network connection. But by using multiple cores, you can definitely speed up your requests.
