library(rvest)
library(RCurl)
library(lubridate)
library(data.table)

setwd("~/Documents/projects/endurance_data")

###


# 1) scrape race results

# try out for Lake Placid 2022

eventid <- 702

out <- list()

eventurl <- paste("https://www.endurance-data.com/en/results/", eventid, "/all/", sep="")

pages <- read_html(eventurl) %>%  html_node(".pagination") %>% html_text2()  # get max page number
pages <- as.numeric(gsub(".*\\.\\.\\.\\\n", "", pages))

for (i in 1:pages){
  
  url <- paste(eventurl, i, sep="")

  grab <- read_html(url)
  table <- html_nodes(grab, xpath = "//table")[[1]] %>% html_table(fill=TRUE)

  colnames(table) <- c("rank_overall", "rank_gender", "rank_division", "name", "bib", "ag", "country", "swim", "bike", "run", "total")

  out[[i]] <- table
  
}

results <- rbindlist(out)

results$gender <- ifelse(substr(results$ag, 1, 1) == "M", "m", "f")

save(results, file = "results_lakeplacid2022.Rdata")
write.csv(results, "results_lakeplacid2022.csv")

#######

# 2) scrape Kona times per age group and race

# eventid <- 702   # same id for Lake Placid


url <- paste("https://www.endurance-data.com/en/hawaii-qualification/", eventid, sep="")

grab <- read_html(url)
kq <- html_nodes(grab, xpath = "//table")[[1]] %>% html_table(fill=TRUE)
  
colnames(kq) <- c("ag", "ag_slots", "first", "last", "average", "started", "finished")

kq$gender <- ifelse(substr(kq$ag, 1, 1) == "M", "m", "f")

save(kq, file = "kq_lakeplacid2022.Rdata")
write.csv(kq, "kq_lakeplacid2022.csv")



