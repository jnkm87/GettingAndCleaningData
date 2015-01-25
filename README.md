#Cleaning and Getting Data Course Project
The dataset is obtained from the URL:
[https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)
Unzipping the file will give a folder **UCI HAR Dataset**. The R script is saved as *run\_analysis\.R* in the **UCI HAR Dataset** folder. The location of the file *run\_analysis\.R* is the working directory for the script.

##Codebook
A brief background of the features is provided in the file *features\_info\.txt*. The variables for analysis are derived from the file *features\.txt*. 

##Description of Script
####Load dplyr package
The dplyr package is required for the script operations.
```r
require(dplyr)
```
###Reading Data and Merging Datasets
####Read features dataset
The features are read from *features\.txt*. The *make\.names* function is used to create valid names of the features which can subsequently be used as column names.
```r
features <- read.table("./features.txt", header=F, sep="", stringsAsFactors=F, col.names=c("FeatureID", "Feature.Name"))
Feature.Names <- make.names(features$Feature.Name, unique=T)
```
####Read activity labels
The activity labels are read from the file *activity\_labels*. Each activity ID has a corresponding activity name.
```r
activity_labels <- read.table("./activity_labels.txt", header=F, sep="", stringsAsFactors=T, col.names = c("ActID", "Activity"))
```
####Read train dataset
The train dataset is read from the files within the train folder using the *read\.table* function. The activity names from the previous step are combined with the train dataset by activity ID using the *left\_join* function from the *dplyr* package.
```r
x_train <- read.table("./train/X_train.txt", header=F, sep="", stringsAsFactors=F, col.names=Feature.Names)
y_train <- read.table("./train/Y_train.txt", header=F, sep="", stringsAsFactors=F, col.names="ActID")
y_train <- left_join(y_train, activity_labels, by="ActID")
subject_train <- read.table("./train/subject_train.txt", header=F, sep="", stringsAsFactors=F, col.names="SubjID")
subject_train$Dataset <- as.factor("train")
```
The components of the train dataset (subject\_train, y\_train, x\_train) are joined to give the train dataset.
```r
train<-cbind(subject_train, y_train, x_train)
```
####Read test dataset
The test dataset is read using a similar approach to the train dataset.
```r
x_test <- read.table("./test/X_test.txt", header=F, sep="", stringsAsFactors=F, col.names=Feature.Names)
y_test <- read.table("./test/Y_test.txt", header=F, sep="", stringsAsFactors=F, col.names="ActID")
y_test <-left_join(y_test, activity_labels, by="ActID")
subject_test <- read.table("./test/subject_test.txt", header=F, sep="", stringsAsFactors=F, col.names="SubjID")
subject_test$Dataset <- as.factor("test")
```
The components of the test dataset (subject\_test, y\_test, x\_test) are joined to give the test dataset
```r
test<-cbind(subject_test, y_test, x_test)
```
####Combine test and train datasets
Test and train datasets are combined using *rbind* to give a complete dataset *fulldata*.
```r
fulldata <- rbind(test, train)
head(fulldata)
```
###Creating Subsets
####Extract only measurements on mean and standard deviation of each measurement
The mean and standard measurements, along with subject IDs and activity names are extracted from the *fulldata* dataset by matching strings using the *grepl* function. The resulting data subset *fulldata\.subs* is obtained.
```r
slct.feat <- grepl("mean|std|Mean|Std", colnames(fulldata))
slct.feat <- colnames(fulldata)[slct.feat]
fulldata.subs <- fulldata[,c("SubjID", "Activity", slct.feat)]
```
####Create independent tidy dataset with average for each activity and each subject
The *fulldata.subs* dataset is grouped by subject ID, then by activity, and the mean of each variable is obtained. These are done by chaining using the *group\_by* and *summarise\_each* functions in the *dplyr* package. The resulting dataset is named as *tidyset*
```r
tidyset <- fulldata.subs %>% 
  group_by(SubjID, Activity) %>%
  summarise_each(funs(mean))
```
###Exporting Data
####Export the tidy dataset into a .txt file
The *tidyset* dataset is exported into a .txt file using the *write\.table* function
```r
write.table(tidyset, file="tidyset.txt", row.names=F)
```