#########
# Setup #
#########

library('foreach')
library('doParallel')
library('ggplot2')

# Read, scale, & center our data.
data <- read.csv("magic04.data", header=F, sep=",")
data[1:nrow(data), 1:10] <- scale(data[1:nrow(data), 1:10], center=T, scale=T)
train.size <- 13000 # Given by homework specification
start.time <- proc.time()

#######
# KNN #
#######
 
# Try a bunch of different K-values,

err <- foreach (K=seq(137,261,2), .combine = c) %do% {

    # Need to load the library for knn on each thread.
    registerDoParallel(cores=4)

    # Run KNN 100 times for each K value.
    # Each run is independent, so we can speed things up a little
    # bit by running it in parallel.
    k.err <- foreach (i=1:50, .combine = c) %dopar% {

	library(class)

	data <- data[sample(nrow(data)),] # Randomize the data set
	cols = c(1:3, 6:9) # A perform every so slightly better without these.

	train <- data[1:train.size, cols]
	test <- data[(train.size+1):nrow(data), cols]
	train.cl <- factor(data[1:train.size, 11])
	test.cl <- factor(data[(train.size+1):nrow(data), 11]);

	predict.cl <- knn(train, test, train.cl, k=K)
	sum(test.cl != predict.cl) / nrow(test)
    }

    stopImplicitCluster()
    mean(k.err)
}

plot(seq(13,137,2), err)
 
# This was our best performing k value.
k <- which.min(err)
min.err <- min(err)
acc <- 1.0 - min.err
# 
# K = 13
print(paste("Min K: ", 13 + (k-1)*2))
# About 83.813%
print(paste("KNN - Accuracy: ", acc))
# 2243.040s ~ 37m
print(proc.time() - start.time)
