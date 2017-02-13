#########
# Setup	#
#########

library(foreach)
library(doParallel)

data <- read.csv("magic04.data", header=F, sep=",")
train.size <- 13000 # Given by homework specification

######################
# Develpoment Sample #
######################
# data <- data[sample(nrow(data)),] # Randomize the data set
# data <- data[1:1000,]
# train.size <- nrow(data) * 0.65

#######
# KNN #
#######
 
# # Try a bunch of different K-values,
# err <- foreach (K=1:50, .combine = c) %do% {
#     cl <- makeCluster(4)
#     registerDoParallel(cl)
# 
#     # Run KNN 100 times for each K value.
#     # Each run is independent, so we can speed things up a little
#     # bit by running it in parallel.
#     k.err <- foreach (i=1:100, .combine = c) %dopar% {
# 	# Need to load the library for knn on each thread.
# 	library(class)
# 
# 	data <- data[sample(nrow(data)),] # Randomize the data set
# 
# 	train <- data[1:train.size, 1:10]
# 	test <- data[(train.size+1):nrow(data), 1:10]
# 	train.cl <- factor(data[1:train.size, 11])
# 	test.cl <- factor(data[(train.size+1):nrow(data), 11]);
# 
# 	predict.cl <- knn(train, test, train.cl, k=K)
# 	sum(test.cl != predict.cl) / nrow(test)
#     }
# 
#     stopCluster(cl)
#     mean(k.err)
# }
# 
# # This was our best performing k value.
# k <- which.min(err)
# min.err <- min(err)
# acc <- 1.0 - min.err
# 
# # About 80.975%
# print(paste("KNN - Accuracy: ", acc))
 
#######
# LDA #
#######

# cl <- makeCluster(4)
# registerDoParallel(cl)
# 
# err <- foreach (i=1:100, .combine = c) %dopar% {
#     library(MASS)
# 
#     data <- data[sample(nrow(data)),] # Randomize the data set
# 
#     train <- data[1:train.size, 1:10]
#     test <- data[(train.size+1):nrow(data), 1:10]
#     train.cl <- factor(data[1:train.size, 11])
#     test.cl <- factor(data[(train.size+1):nrow(data), 11]);
# 
#     model <- lda(x = train, grouping = train.cl)
#     predict.cl <- predict(model, test)$class
#     sum(test.cl != predict.cl) / nrow(test)
# }
# 
# stopCluster(cl)
# acc <- 1.0 - mean(err)
# 
# # About 78.429%
# print(paste("LDA - Accuracy: ", acc))

#######
# QDA #
#######

# cl <- makeCluster(4)
# registerDoParallel(cl)
# 
# err <- foreach (i=1:100, .combine = c) %dopar% {
#     library(MASS)
# 
#     data <- data[sample(nrow(data)),] # Randomize the data set
# 
#     train <- data[1:train.size, 1:10]
#     test <- data[(train.size+1):nrow(data), 1:10]
#     train.cl <- factor(data[1:train.size, 11])
#     test.cl <- factor(data[(train.size+1):nrow(data), 11]);
# 
#     model <- qda(x = train, grouping = train.cl)
#     predict.cl <- predict(model, test)$class
#     sum(test.cl != predict.cl) / nrow(test)
# }
# 
# stopCluster(cl)
# acc <- 1.0 - mean(err)
# 
# # About 78.4276%
# print(paste("QDA - Accuracy: ", acc))

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

    model <- train(train, train.cl, 'nb')
    predict(model)
    predict.cl <- predict(model$finalModel, test)$class
    sum(test.cl != predict.cl) / nrow(test)
}

stopCluster(cl)
acc <- 1.0 - mean(err)

print(paste("Naive Bayes - Accuracy: ", acc))

########################
# Naive Bayes (Kernel) #
########################
