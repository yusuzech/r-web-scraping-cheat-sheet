#This function is not vectorized, use for loop for multiple key words
#keyword_search: keyword
#image_num: return how many pictures, may return less than this number.
#scroll_times: how many times should scroll down,default 1
#css_searchbox: css selector for searchbox
#css_clicksearch: css selector for search button
#css_img_src: css selector for image source
#try_times: how many times to try to get missed images
download_google_img <- function(keyword_search,image_num = 50,scroll_times = 1,
                                css_searchbox = "#lst-ib",css_clicksearch = "#_fZl",css_img_src = ".rg_i",
                                try_times = 1){
    #download pictures from google
    #chenck if all packages installed
    required_packages <- c("rvest","RSelenium","seleniumPipes","dplyr","stringr","magick")
    for (packge in required_packages) {
        if (packge %in% rownames(installed.packages())) {
            require(packge, character.only = TRUE)
        } else {
            install.packages(packge)
        }
    }
    #create tmp_img folder if doesn't exist, create one
    if(!file.exists("tmp_img")){
        dir.create("tmp_img")
    }
    #start server-----
    rD <- rsDriver (browser = 'chrome',chromever = "latest",port = 4445L)
    #open browser
    remDr <- remoteDr(browserName = "chrome",port = 4445L)
    #use google image search
    web_url <- "https://www.google.com/search?q=fd&source=lnms&tbm=isch&sa=X&ved=0ahUKEwjto6G9pKTZAhVdVWMKHZHWAr8Q_AUIDSgE&biw=1920&bih=900"
    #go to url
    remDr %>% go(web_url)
    
    #clear search box and clear it ------------
    remDr %>% findElement(using = "css selector",value = css_searchbox) %>% elementClear() %>% elementSendKeys(keyword_search)
    #click to search pictures
    remDr %>% findElement(using = "css selector",value = css_clicksearch) %>% elementClick()
    #Optional---------------
    #scroll down to get more images
    if(scroll_times == 0){
        
    } else {
        for (i in 1:scroll_times){
            remDr %>% executeScript("window.scrollTo(0,document.body.scrollHeight);")
        }
    }
    #optional ends-----------------------
    #after scrolling, wait a certain time for pictures to load
    Sys.sleep(scroll_times*5)
    #get picture source urls
    img_href <- remDr %>% getPageSource() %>% html_nodes(css_img_src) %>% html_attr("src")
    #remove NAs in img_href
    img_href <- img_href[!is.na(img_href)]
    #how many images to return?
    r_img_num <- min(image_num,length(img_href))
    img_href <- img_href[1:r_img_num]
    #save image one by one
    missed_imgs <- numeric(0)
    for(i in seq_along(img_href)){
        tryCatch({
            remDr %>% go(img_href[i])
            #take screenshot
            temp_img <- remDr %>% takeScreenshot(returnPNG = TRUE)
            #render image
            cropped_img <- image_trim(image_read(temp_img))
            #save image in tmp_img file
            image_write(cropped_img,path = str_c("tmp_img/",keyword_search,"_",i,".png"),format = "png")
            message("process:",i,"/",r_img_num)
            Sys.sleep(round(runif(1,min = 2, max = 4)))
        },
        error = function(x){
            x <- i
            missed_imgs <<- append(missed_imgs,x)
            message(keyword_search," image ",x," missing")
            Sys.sleep(10)
            remDr <- remoteDr(browserName = "chrome",port = 4445L)
            message("server restarted")
        })
        
    }
    remDr %>% deleteSession()
    rD[["server"]]$stop() 
}





