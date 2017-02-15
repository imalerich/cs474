#########
# Setup #
#########

library(foreach)
library(doParallel)
library(MVN)

data <- read.csv("magic04.data", header=F, sep=",")
train.size <- 13000 # Given by homework specification
start.time <- proc.time()

########################
# Naive Bayes (Normal) #
########################

cl <- makeCluster(4)
registerDoParallel(cl)

err <- foreach (i=1:100, .combine = c) %dopar% {
    library(klaR)
    library(caret)

    data <- data[sample(nrow(data)),] # Randomize the data set

    train <- data[1:train.size, 1:10]
    test <- data[(train.size+1):nrow(data), 1:10]
    train.cl <- factor(data[1:train.size, 11])
    test.cl <- factor(data[(train.size+1):nrow(data), 11]);

    model <- NaiveBayes(x = train, grouping = train.cl, usekernel=FALSE)
    predict.cl <- predict(model, test)$class
    sum(test.cl != predict.cl) / nrow(test)
}

stopCluster(cl)
acc <- 1.0 - mean(err)

# About 72.6714%
print(paste("Naive Bayes (Normal) - Accuracy: ", acc))
print(proc.time() - start.time)
