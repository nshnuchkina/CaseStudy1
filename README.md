---
title: "Case Study 1"
author: "Michael Crowder, Nadya Green, Jonathan Knowles"
date: "2/28/2017"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

# R Markdown

R Code for Case Study 1
R version 1.0.136 (2017-03-01)

## Part 1: Introduction
This is a case study for cleaning, merging and analysing data. The data is downloaded from the web and represents 2 data sets:
1. Gross Domestic Product data for the 190 ranked countries (GDP.csv)
2. Educational Data (EDU.csv)

The case study produces the answers and plots for the following questions:

1. Merge the data based on the country shortcode. How many IDs match?
2. Sort the data frame in ascending order by GDP (so United States is last). What is the 13th Country in the resultig data frame?
3. What are the average GDP rankings for the "High income: OECD" and "High income: nonOECD" groups?
4. Plot the GDP for all of the countries. Use ggplot2 to color your plot by Income Group.
5. Cut the GDP ranking into 5 separate qunatile groups. Make a table versus Income.Group. How many countries are Lower middle income but among the 38 nations with highest GDP?

The final RMarkdown file should be readable in GitHub.

## Part 2: Cleaning, Merging and Analysing the data

Install libraries required
```{r}
install.packages("knitr", repos="https://cloud.r-project.org")
install.packages("markdown", repos="https://cloud.r-project.org")
install.packages("downloader", repos="https://cloud.r-project.org")
install.packages("lattice", repos="https://cloud.r-project.org")
install.packages("survival", repos="https://cloud.r-project.org")
install.packages("Formula", repos="https://cloud.r-project.org")
install.packages("ggplot2", repos="https://cloud.r-project.org")
install.packages("Hmisc", repos="https://cloud.r-project.org")
install.packages("repmis", repos="https://cloud.r-project.org")
install.packages("bitops", repos="https://cloud.r-project.org")
install.packages("RCurl", repos="https://cloud.r-project.org")
install.packages("plyr", repos="https://cloud.r-project.org")
install.packages("reshape2", repos="https://cloud.r-project.org")
```
Load libraries needed for this case study
```{r}
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
```
Gather data
```{r}
gdpURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv"
eduURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FEDSTATS_Country.csv"
gdpFile <- tempfile()
eduFile <- tempfile()
download.file(gdpURL, gdpFile)
download.file(eduURL, eduFile)
```
Tidy/Cean the data
```{r}
gdpData <- read.csv(gdpFile, skip = 5, nrows = 190, stringsAsFactors = F, header = F)
eduData <- read.csv(eduFile, stringsAsFactors = F)
```
Bring in the columns we need
```{r}
gdpData <- gdpData[, c(1, 2, 4, 5)]
```
Name the columns appropriately
```{r}
colnames(gdpData) <- c("CountryCode", "Rank", "Country.Name", "GDP.Value")
```
Set GDP value to numeric
```{r}
gdpData$GDP.Value <- as.numeric(gsub(",", "", gdpData$GDP.Value))
```
Merge the data based on country code
```{r}
matchedData <- merge(gdpData, eduData, by.x = "CountryCode", by.y = "CountryCode")
```
### Answer to question #1 - Number of countries that match:
```{r}
dim(matchedData)
```
### Answer to question #2 - Sort the data frame in ascending order, then What is the 13th country in the resulting data frame:
```{r}
arrange(matchedData, Rank)[13, 3]
```
### Answers to question #3 - 3	What are the average GDP rankings for the "High income: OECD" and "High income: nonOECD" groups? 

High income: OECD
```{r}
mean(subset(matchedData, Income.Group %in% "High income: OECD", select = c(Rank))$Rank)
```
High income: nonOECD
```{r}
mean(subset(matchedData, Income.Group %in% "High income: nonOECD", select = c(Rank))$Rank)
```
### Answer to question #4
```{r}
ggplot(matchedData,aes(y = GDP.Value, x =Income.Group, fill=Income.Group)) + scale_y_log10()+ geom_point(pch = 21, size = 8)
```
### Answer to question #5
```{r}
breaks <- quantile(matchedData$Rank,seq(0, 1, 0.2))
head(cut(matchedData$Rank, breaks = breaks))


matchedData$quantile<-cut(matchedData$Rank,breaks=breaks)
table(matchedData$Income.Group, matchedData$quantile)
```