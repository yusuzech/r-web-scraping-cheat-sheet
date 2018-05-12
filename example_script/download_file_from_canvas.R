download_from_canvas <- function(username,password,course_number,canvas_url="https://canvas.ucdavis.edu"){
    #ckeck for required packages
    required_packages <- c("rvest","RSelenium","stringr")
    for(package in required_packages){
        if (package %in% installed.packages()[,"Package"]) {
            require(package,character.only = T)
        } else {
            message("install required package:",package)
            install.packages(package)
            require(package)
        }
    }
    
    #start server
    rD <- rsDriver (browser = 'chrome',chromever = "latest",port = 4445L)
    chrome_client <-rD$client
    #go to canvas 
    cat("default canvas url set to"," https://canvas.ucdavis.edu\n")
    chrome_client$navigate(canvas_url)
    #login
    ele_login <- chrome_client$findElement(using = "css",value = "p~ p+ .marketing-highlight__cta--btn")
    ele_login$clickElement()
    #enter username and password
    ele_username <- chrome_client$findElement(using = "css",value = "#username")
    ele_username$sendKeysToElement(list(username))
    ele_password <- chrome_client$findElement(using = "css",value = "#password")
    ele_password$sendKeysToElement(list(password))
    #click login
    ele_login <- chrome_client$findElement(using = "css",value = "#submit")
    ele_login$clickElement()
    
    #All visible text .ic-DashboardCard__header-subtitle
    Sys.sleep(2)
    dashboard_pagesource <- unlist(chrome_client$getPageSource())
    Sys.sleep(2)
    visible_text <- read_html(dashboard_pagesource) %>% html_nodes(".ic-DashboardCard__header-subtitle") %>% html_text()
    #loop over courses
    for(course in course_number){
        #the course material I want to download
        link_text <- visible_text[str_detect(visible_text,pattern = as.character(course))]
        #the course material I want to download:
        ele_course <- chrome_client$findElement(using = "partial",value = link_text)
        ele_course$clickElement()
        
        #click files .files
        ele_file <- chrome_client$findElement(using = "css",value = ".files")
        ele_file$clickElement()
        Sys.sleep(2)
        #all items to click
        ele_folders <- chrome_client$findElements(using = "css",value = ".ef-item-row")
        
        #hold control key
        chrome_client$sendKeysToActiveElement(list(key = "control"))
        for(ele_folder in ele_folders){
            chrome_client$mouseMoveToLocation(webElement = ele_folder) 
            chrome_client$click(0) 
        }
        #press again to release keypress
        chrome_client$sendKeysToActiveElement(list(key = "control"))
        #press download button icon-download
        ele_download <- chrome_client$findElement(using = "css",value = ".icon-download")
        ele_download$clickElement()
        #goback twice
        Sys.sleep(10)
        replicate(2,chrome_client$goBack())
    }
    
    #stop server
    #wait to complete downloading
    Sys.sleep(60)
    chrome_client$close()
    rD$server$stop()
}
