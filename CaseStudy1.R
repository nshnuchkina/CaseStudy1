## Part 2: Cleaning, Merging and Analysing the data
# Install libraries required
install.packages("knitr")
install.packages("markdown")
install.packages("downloader")
install.packages("lattice")
install.packages("survival")
install.packages("Formula")
install.packages("ggplot2")
install.packaged("Hmisc")
install.packages("repmis")
install.packages("RCurl")
install.packages("plyr")
install.packages("reshape2")

# Install Libraries needed for this case study
library(knitr)
library(markdown)
library(downloader)
library(lattice)
library(survival)
library(Formula)
library(ggplot2)
library(Hmisc)
library(repmis)
library(bitops)
library(RCurl)
library(plyr)
library(reshape2)

# Gather data
gdpURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv"
eduURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FEDSTATS_Country.csv"
gdpFile <- tempfile()
eduFile <- tempfile()
download.file(gdpURL, gdpFile)
download.file(eduURL, eduFile)

## Question 1: Read and match the data based on the country shortcode.
# Tidy/Clean the data
gdpData <- read.csv(gdpFile, skip = 5, nrows = 190, stringsAsFactors = F, header = F)
eduData <- read.csv(eduFile, stringsAsFactors = F)

# Bring in the columns we need
gdpData <- gdpData[, c(1, 2, 4, 5)]

# Name the columns appropriately
colnames(gdpData) <- c("CountryCode", "Rank", "Country.Name", "GDP.Value")

# Set FDp value to numeric
gdpData$GDP.Value <- as.numeric(gsub(",", "", gdpData$GDP.Value))

# Merge the data based on country codes
matchedData <- merge(gdpData, eduData, by.x = "CountryCode", by.y = "CountryCode")

# Are there any missing data?
sum(is.na(matchedData))

# How many ID's match?
dim(matchedData)

## Question 2: Sort the data frame in ascending order by GDP rank. What is the 13th country in the resulting data frame?
arrange(matchedData, Rank)[13, 3]

## Question 3: What is the average GDP ranking for the "High income: OECD" and "High income: nonOECD" group?
# High income: OECD
mean(subset(matchedData, Income.Group %in% "High income: OECD", select = c(Rank))$Rank)

# High income: nonOECD
mean(subset(matchedData, Income.Group %in% "High income: nonOECD", select = c(Rank))$Rank)

## Question 4: Plot the GDP for all of the countries. Use ggplot2 to color your plot by Income Group.
ggplot(matchedData,aes(y = GDP.Value, x = Income.Group, fill=Income.Group)) + scale_y_log10() + geom_point(pch = 21, size = 8)

## Question 5: Cut the GDP ranking into 5 separate quantile groups. Make a table versus Income.Group. How many countries are Lower middle income but among the 38 nations with highest GDP?
breaks <- quantile(matchedData$Rank,seq(0, 1, 0.2))
head(cut(matchedData$Rank, breaks = breaks))

matchedData$quantile<-cut(matchedData$Rank,breaks=breaks)
table(matchedData$Income.Group, matchedData$quantile)

