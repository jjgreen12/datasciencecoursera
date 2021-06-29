#created 20190311 by J.Green


# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average 
#    of each variable for each activity and each subject.

# Please upload your data set as a txt file created with write.table() using row.name=FALSE 
# (do not cut and paste a dataset directly into the text box, as this may cause errors saving your submission).


#------read labels------
featureLabels <- read.table("./UCI HAR Dataset/features.txt",sep="")
featureLabels <- featureLabels[2]
names(featureLabels)[1]<-"Name"
featureLabels[1] <- lapply(featureLabels[1],as.character)


activityLabels <- read.table("./UCI HAR Dataset/activity_labels.txt",sep="")
names(activityLabels)[1:2]<-c("ActivityLabel","Activity")

#-------read test data------
test_x <- read.table("./UCI HAR Dataset/test/X_test.txt", sep="")
names(test_x)<-featureLabels[[1]]
test_y <- read.table("./UCI HAR Dataset/test/y_test.txt", sep="")
names(test_y)[1]<-"ActivityLabel"
subjectTest <- read.table("./UCI HAR Dataset/test/subject_test.txt",sep="")
#^needs to be a column added to the test_x with label "subjectID"
names(subjectTest)[1]<-"subjectID"

library(plyr)
test_y <- join(test_y,activityLabels)
test <- test_y$Activity
test <- cbind(subjectTest,test,test_x)
names(test)[1:2]<-c("SubjectID","Activity")
rm(test_x,test_y)
#^summary calculations performed on each observation of the intertial signal data

#-------read train data------
train_x <- read.table("./UCI HAR Dataset/train/X_train.txt", sep="")
names(train_x)<-featureLabels[[1]]
train_y <- read.table("./UCI HAR Dataset/train/y_train.txt", sep="")
names(train_y)<-"ActivityLabel"
subjectTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt",sep="")
names(subjectTrain)[1]<-"subjectID"

library(plyr)
train_y <- join(train_y,activityLabels)
train <- train_y$Activity
train <- cbind(subjectTrain,train,train_x)
names(train)[1:2]<-c("SubjectID","Activity")
rm(train_x,train_y)

#------combine test and train-----
dataset <- rbind(test,train)

datset2 <- dataset[,grepl("mean",names(dataset))]
dataset3 <- dataset[,grepl("std",names(dataset))]

dataset4 <- cbind(dataset[1:2],datset2,dataset3)

#---filter for averge values----
library(data.table)

datatable <- data.table(dataset4)

answer <- datatable[,lapply(.SD,mean),by=.(Activity,SubjectID)]
write.table(answer,"tidygyrodata.txt",sep="\t",row.names=FALSE)
