options(java.parameters = "- Xmx4096m")

# --------------------------------Loading----------------------------------------------- 

# source file https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip

# read files

unzip(zipfile = "Coursera-SwiftKey.zip")
file_names <- list.files("final/en_US") 

for (i in 1:3){
  path <- paste("final/en_US/",file_names[[i]], sep = "")
  con <- file(path,open = "rb")
  assign(paste(file_names[[i]], sep = ""), readLines(con))
  close(con)
}

# --------------------------------Sampling----------------------------------------------- 

#sampling 15% of each source file

# to save to samples subfolder
setwd("./samples")

#en_US.blogs.txt
ln <- length(en_US.blogs.txt)
set.seed(111)
r <- rbinom(ln, size = 1, prob = 0.15)
sample <- cbind(en_US.blogs.txt, r)
sample <- subset(sample, sample[,2] == 1)
sample <- sample[,1]
write(sample, file ="en_sample.txt" )
#en_US.news.txt"
ln <- length(en_US.news.txt)
set.seed(111)
r <- rbinom(ln, size = 1, prob = 0.15)
sample <- cbind(en_US.news.txt, r)
sample <- subset(sample, sample[,2] == 1)
sample <- sample[,1]
write(sample, file ="en_sample.txt", append = TRUE )
#en_US.twitter.txt
ln <- length(en_US.twitter.txt)
set.seed(111)
r <- rbinom(ln, size = 1, prob = 0.15)
sample <- cbind(en_US.twitter.txt, r)
sample <- subset(sample, sample[,2] == 1)
sample <- sample[,1]
write(sample, file ="en_sample.txt",append = TRUE )
#moving back to main WD
setwd("../")


# --------------------------------Building Corpus----------------------------------------------- 

#loading yto corpus all samples
library(tm)
all_samples <-VCorpus(DirSource('C:/Users/aspen/Desktop/R_projects/NLP_Capstone/samples', encoding ="UTF-8"))

#cleaning 
all_samples <- tm_map(all_samples, removeNumbers)
all_samples <- tm_map(all_samples, removePunctuation)
# to correct: all_samples <- tm_map(all_samples, toSpace,"[^[:graph:]]")
removeSpecialChars <- function(x) gsub("[^a-zA-Z0-9 ]","",x)
all_samples <- tm_map(all_samples, removeSpecialChars)
all_samples <- tm_map(all_samples, PlainTextDocument)
all_samples <- tm_map(all_samples, content_transformer(tolower))
# remove single letter and extar white spaces
all_samples <- tm_map(all_samples, removeWords, letters)
all_samples <- tm_map(all_samples, stripWhitespace)
# stop words may be useful to have in the final tool so not removed 
# all_samples <- tm_map(all_samples, removeWords, stopwords("en"))

# create a Term matrix
dtm <- DocumentTermMatrix(all_samples)
freq_dtm <- findMostFreqTerms(dtm, n = ncol(dtm))
freq_dtm <- as.data.frame(freq_dtm)
freq_dtm <- tibble::rownames_to_column(freq_dtm, "term")
freq_dtm <- subset(freq_dtm, freq_dtm$character.0. > 2)
freq_dtm <- freq_dtm$term

all_samples_small <- all_samples


# --------------------------------Building n-grams data----------------------------------------------- 

library(RWeka)
library(dplyr)

# 2-grams
BigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min=2, max=2))
aTDM2 <- TermDocumentMatrix(all_samples, control=list(tokenize=BigramTokenizer))
freqTerms2 <- findMostFreqTerms(aTDM2, n = 1000000)
freqTerms2 <- as.data.frame(freqTerms2)
freqTerms2 <- tibble::rownames_to_column(freqTerms2, "term")
freqTerms2 <- freqTerms2[order(-freqTerms2$character.0.),]


# 3-grams
BigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min=3, max=3))
aTDM3 <- TermDocumentMatrix(all_samples, control=list(tokenize=BigramTokenizer))
freqTerms3 <- findMostFreqTerms(aTDM3, n = 1000000)
freqTerms3 <- as.data.frame(freqTerms3)
freqTerms3 <- tibble::rownames_to_column(freqTerms3, "term")
freqTerms3 <- freqTerms3[order(-freqTerms3$character.0.),]
freqTerms3 <- as.data.frame(freqTerms3)

# 4-grams
BigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min=4, max=4))
aTDM4 <- TermDocumentMatrix(all_samples, control=list(tokenize=BigramTokenizer))
freqTerms4 <- findMostFreqTerms(aTDM4, n = 1000000)
freqTerms4 <- as.data.frame(freqTerms4)
freqTerms4 <- tibble::rownames_to_column(freqTerms4, "term")
freqTerms4 <- freqTerms4[order(-freqTerms4$character.0.),]

# 5-grams
BigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min=5, max=5))
aTDM5 <- TermDocumentMatrix(all_samples, control=list(tokenize=BigramTokenizer))
freqTerms5 <- findMostFreqTerms(aTDM5, n = 1000000)
freqTerms5 <- as.data.frame(freqTerms5)
freqTerms5 <- tibble::rownames_to_column(freqTerms5, "term")
freqTerms5 <- freqTerms5[order(-freqTerms5$character.0.),]

#merging all n-grams data to one table and saving to file (later use a source for model)
freqTerms_sorted <- cbind(freqTerms2[,1], freqTerms3[,1], freqTerms4[,1], freqTerms5[,1])
saveRDS(freqTerms_sorted, file = "freqTerms_sorted.RData")


# --------------------------------Building model---------------------------------------------- 

#read model data
freqTerms_sorted <- readRDS("freqTerms_sorted.RData")

# input <- c("la la la la la what do you want") # this is test text to assign to input
 
number_of_words <- sapply(strsplit(input, " "), length)
i <- number_of_words

# cut longer then 4 strings - model has only 5-grams max
if (i > 4) { input_cut <- tail(strsplit(input, split=" ")[[1]],4)
            input <- paste(input_cut[1], input_cut[2], input_cut[3], input_cut[4], sep = " ")
            number_of_words <- sapply(strsplit(input, " "), length)
            i <- number_of_words
            }
# searching for all matches in DB
input_freq <- freqTerms_sorted[grep(paste("^", input, " .", sep=""), freqTerms_sorted[,i[1]]),]

# cutting first world if no matches in the longest gram
while (length(input_freq) < 1 && number_of_words > 1) {
  
  input <- sub(".*? ", "", input)
  number_of_words <- sapply(strsplit(input, " "), length)
  i <- number_of_words 
 input_freq <- freqTerms_sorted[grep(paste("^", input, " .", sep=""), freqTerms_sorted[,i[1]]),]
} 

# subseting top 3 matches
top_3 <- input_freq[1:3,i[1]]
# subseting last world from a match
top_3 <- sapply(strsplit(top_3, split = " "), last) 
# output
output1 <- top_3[1]
output2 <- top_3[2]
output3 <- top_3[3]



     
                     
                     
                     

