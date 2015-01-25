# Load dplyr package
require(dplyr)
# Read features dataset
features <- read.table("./features.txt", header=F, sep="", stringsAsFactors=F, col.names=c("FeatureID", "Feature.Name"))
Feature.Names <- make.names(features$Feature.Name, unique=T)
# Read activity labels
activity_labels <- read.table("./activity_labels.txt", header=F, sep="", stringsAsFactors=T, col.names = c("ActID", "Activity"))
# Read train dataset and include activity labels
x_train <- read.table("./train/X_train.txt", header=F, sep="", stringsAsFactors=F, col.names=Feature.Names)
y_train <- read.table("./train/Y_train.txt", header=F, sep="", stringsAsFactors=F, col.names="ActID")
y_train <- left_join(y_train, activity_labels, by="ActID")
subject_train <- read.table("./train/subject_train.txt", header=F, sep="", stringsAsFactors=F, col.names="SubjID")
subject_train$Dataset <- as.factor("train")
# Join train dataset
train<-cbind(subject_train, y_train, x_train)

# Read test dataset and include activity labels
x_test <- read.table("./test/X_test.txt", header=F, sep="", stringsAsFactors=F, col.names=Feature.Names)
y_test <- read.table("./test/Y_test.txt", header=F, sep="", stringsAsFactors=F, col.names="ActID")
y_test <-left_join(y_test, activity_labels, by="ActID")
subject_test <- read.table("./test/subject_test.txt", header=F, sep="", stringsAsFactors=F, col.names="SubjID")
subject_test$Dataset <- as.factor("test")
# Join test dataset
test<-cbind(subject_test, y_test, x_test)

# Combine test and train datasets using rbind to give a full dataset
fulldata <- rbind(test, train)
head(fulldata)

# Extract only measurements on mean and standard deviation of each measurement using the grepl function
slct.feat <- grepl("mean|std|Mean|Std", colnames(fulldata))
slct.feat <- colnames(fulldata)[slct.feat]
fulldata.subs <- fulldata[,c("SubjID", "Activity", slct.feat)]

# Create second independent tidy dataset with average for each activity and each subject
tidyset <- fulldata.subs %>% 
  group_by(SubjID, Activity) %>%
  summarise_each(funs(mean))