# Web Scraping Reference: Cheat Sheet for Web Scraping using R

inspired by Hartley Brody, this cheat sheet is about web scraping with rvest,httr and Rselenium. This is a r version of this blog https://blog.hartleybrody.com/web-scraping-cheat-sheet/. So the table of contents is similar.

While Hartley uses python's requests and beautifulsoup libraries. This cheat covers the usage of httr and rvest. In addition, usage of Rselenium(web driver) is also covered.

# Talbe of Contents
## <a href="#rvest">1.Web Scraping using rvest and httr</a>
### <a href="#rvest1">1.1.Useful Libraries</a>
### <a href="#rvest2">1.2.Making Simple Requests</a>
### <a href="#rvest3">1.3.Inspecting Response</a>
### <a href="#rvest4">1.4.Extracting Elements from HTML</a>
### <a href="#rvest5">1.5.Storing Data in R</a>
#### <a href="#rvest5.1">1.5.1.Storing Data as list</a>
#### <a href="#rvest5.2">1.5.2.Storing Data as data.frame</a>
### <a href="#rvest6">1.6.Saving Data to disk</a>
#### <a href="#rvest6.1">1.6.1.Saving Data to csv</a>
#### <a href="#rvest6.2">1.6.2.Saving Data to SQLite Database</a>
### <a href="#rvest7">1.7.More Advanced Topics</a>
#### <a href="#rvest7.1">1.7.1.Javascript Heavy Websites</a>
#### <a href="#rvest7.2">1.7.2.Content Inside iFrames</a>
#### <a href="#rvest7.3">1.7.3.Sessions and Cookies</a>
#### <a href="#rvest7.4">1.7.4.Delays and Backing Off</a>
#### <a href="#rvest7.5">1.7.5.Spoofing the User Agent</a>
#### <a href="#rvest7.6">1.7.6.Using Proxy Servers</a>
#### <a href="#rvest7.7">1.7.7.Setting Timeouts</a>
#### <a href="#rvest7.8">1.7.8.Handling Network Errors</a>
## <a href="#rselenium">2.Web Scraping using Rselenium</a>




Javascript Heavy Websites
Content Inside iFrames
Sessions and Cookies
Delays and Backing Off
Spoofing the User Agent
Using Proxy Servers
Setting Timeouts
Handling Network Errors
