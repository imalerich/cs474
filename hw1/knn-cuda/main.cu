#include <cuda.h>
#include <cuda_runtime_api.h>
#include <float.h>
#include <stdio.h>
#include <stdlib.h>

#define RED		0
#define GREEN	1

/**
 * Computes the Euclidean distance between the input vector 'Y' and all
 * vectors in the array 'X'.
 * An array of size 'n' containing each distance will be returned on completion.
 * \param n Number of entries in the data set 'X'.
 * \param d Dimension of each vector.
 * \param Y Input vector to compare against 'X' (array of size d).
 * \param X Input list of vectors (array of size n * d).
 * \param D Output array of distances (array of size n).
 */
__global__ void calcDistE(int n, int d, float * Y, float * X, float * DIST) {
	const int idx = blockIdx.x * blockDim.x + threadIdx.x;
	if (idx >= n) { return; } // Index is not in bounds of the data set.

	float * x = &X[idx * d];
	float sum = 0.0f;

	// Compute the sum of squares over each dimmension...
	for (int i=0; i<d; ++i) {
		sum += pow(x[i] - Y[i], 2.0f);
	}

	// The distance will be the square root of that value.
	DIST[idx] = sqrt(sum);
}

/**
 * Performs KNN on the given data.
 * \param n Number of entries in the data set 'X'.
 * \param d Dimension of each vector.
 * \param Y Input vector to compare against 'X' (array of size d).
 * \param X Input list of vectors (array of size n * d).
 * \param L Labels coresponding to each of item of X (array of size n).
 * \param C The number of classes that are valid in L.
 * \param k How many neighbors to consider when making our assignment?
 */
void knn(int n, int d, float * Y, float * X, int * L, int C, int k) {
	// Allocate the GPU arrays.
	float * cu_X, * cu_Y, * cu_DIST;
	cudaMalloc(&cu_X, n * d * sizeof(float));
	cudaMalloc(&cu_Y, d * sizeof(float));
	cudaMalloc(&cu_DIST, n * sizeof(float));

	// Copy the provided data to the GPU.
	cudaMemcpy(cu_X, X, n * d * sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(cu_Y, Y, d * sizeof(float), cudaMemcpyHostToDevice);

	// Compute distances in parallel in 1 block of 256 threads.
	calcDistE<<<(n + 255)/256, 256>>>(n, d, cu_Y, cu_X, cu_DIST);

	// Copy the distances back from the GPU to the CPU.
	float * dist = (float *)malloc(n * sizeof(float));
	cudaMemcpy(dist, cu_DIST, n * sizeof(float), cudaMemcpyDeviceToHost);

	// Count the number of occurences of each label.
	int * labels = (int *)malloc(C * sizeof(int));
	for (int i=0; i<C; ++i) { labels[i] = 0; }

	// This is horribly ineficient [O(n^2) when k=n].
	// would be much better to keep cu_DIST on the GPU
	// (and associate labels with it), sort it there
	// then just read data from that array.
	for (int i=0; i<k; i++) {
		int least = -1;
		for (int j=0; j<n; j++) {
			if (least < 0 || dist[j] < dist[least]) {
				least = j;
			}
		}

		dist[least] = FLT_MAX; // Ignore this value on the next pass.
		++labels[ L[least] ]; // Increment the label given for this element.
	}

	// Print the results.
	printf("knn: k=%d\n", k);
	for (int i=0; i<C; i++) {
		printf("class %d:\t%d/%d\n", i, labels[i], k);
	}
	printf("\n");

	// Cleanup...
	cudaFree(cu_X);
	cudaFree(cu_Y);
	cudaFree(cu_DIST);
	free(dist);
	free(labels);
}

int main(int argc, const char ** argv) {
	const int d = 3; // 3-dimmensional data set
	const int n = 6; // with 6 elements.

	float Y[] = {0, 0, 0};
	float X[] = {
		2, 3, 0,	// 1
		2, 0, 1,	// 2
		0, 1, 3,	// 3
		0, 1, 2,	// 4
		-1, 0, 1,	// 5
		1, -1, 1	// 6
	};
	int L[] = {
		RED,		// 1
		RED,		// 2
		RED,		// 3
		GREEN,		// 4
		GREEN,		// 5
		RED			// 6
	};

	// Run k-nearest neighbors for k=1 and k=3.
	knn(n, d, Y, X, L, 2, 1);
	knn(n, d, Y, X, L, 2, 3);
}
