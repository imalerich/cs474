#########
# Setup #
#########

library('foreach')
library('doParallel')

# Read, scale, & center our data.
data <- read.csv("magic04.data", header=F, sep=",")
data[1:nrow(data), 1:10] = scale(data[1:nrow(data), 1:10], center=T, scale=T)
train.size <- 13000 # Given by homework specification
start.time <- proc.time()

#######
# KNN #
#######
 
# Try a bunch of different K-values,
registerDoParallel(cores=8)

err <- foreach (K=1:50, .combine = c) %dopar% {

    # Need to load the library for knn on each thread.
    library(class)

    # Run KNN 100 times for each K value.
    # Each run is independent, so we can speed things up a little
    # bit by running it in parallel.
    k.err <- foreach (i=1:100, .combine = c) %do% {

	data <- data[sample(nrow(data)),] # Randomize the data set

	train <- data[1:train.size, 1:10]
	test <- data[(train.size+1):nrow(data), 1:10]
	train.cl <- factor(data[1:train.size, 11])
	test.cl <- factor(data[(train.size+1):nrow(data), 11]);

	predict.cl <- knn(train, test, train.cl, k=((K*2)+1))
	sum(test.cl != predict.cl) / nrow(test)
    }
}

stopImplicitCluster()

plot(1:50, err)

# This was our best performing k value.
k <- which.min(err)
min.err <- min(err)
acc <- 1.0 - min.err

# K = 13
print(paste("Min K: ", (k*2)+1))
# About 83.813%
print(paste("KNN - Accuracy: ", acc))
# 2243.040s ~ 37m
print(proc.time() - start.time)
