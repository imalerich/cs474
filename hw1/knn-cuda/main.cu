#include <cuda.h>
#include <cuda_runtime_api.h>
#include <float.h>
#include <stdio.h>
#include <stdlib.h>

#define RED		0
#define GREEN	1

const char * LABELS[] = {
	"Red",
	"Green"
};

/**
 * Computes the Euclidean distance between the input vector 'Y' and all
 * vectors in the array 'X'.
 * An array of size 'n' containing each distance will be returned on completion.
 * \param n		Number of entries in the data set 'X'.
 * \param d		Dimension of each vector.
 * \param Y		Input vector to compare against 'X' (array of size d).
 * \param X		Input list of vectors (array of size n * d).
 * \param DIST	Output array of distances (array of size n).
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
 * Sorts the input label array based on the input distances.
 * This is done with a parallel implementation of a selection sort,
 * which is fairly slow for a parallel sort, but should be faster 
 * than most serial sorts on large data sets.
 * \param n		The number of points in our data set.
 * \param DIST	Array if distances associated with our labels (array of size n).
 * \param L		List of class labels associated with distances (arry of size n).
 * \param OUT	Output copy of list L, sorted by correpsonding distances (array of size n).
 */
__global__ void findNearest(int n, float * DIST, int * L, int * OUT) {
	const int idx = blockIdx.x * blockDim.x + threadIdx.x;
	if (idx >= n) { return; } // Index is not in bounds of the data set.

	// This is the value we are sorting.
	float d = DIST[idx];
	int k = L[idx];

	// How many distances are smaller than the current one?
	int smaller = 0;
	for (int i=0; i<n; ++i) {
		if ((DIST[i] < d) ||
				// Break ties by index.
				(DIST[i] == d && i < idx)) {
			++smaller;
		}
	}

	// Set the output label.
	OUT[smaller] = k;
}

/**
 * Performs KNN on the given data.
 * \param n		Number of entries in the data set 'X'.
 * \param d		Dimension of each vector.
 * \param Y		Input vector to compare against 'X' (array of size d).
 * \param X		Input list of vectors (array of size n * d).
 * \param L		Labels coresponding to each of item of X (array of size n).
 * \param C		The number of classes that are valid in L.
 * \param Cstr	String representations for each class label (array of C strings).
 * \param k		How many neighbors to consider when making our assignment?
 */
void knn(int n, int d, float * Y, float * X, int * L, int C, const char ** Cstr, int k) {
	// Allocate the GPU arrays.
	float * cu_X, * cu_Y, * cu_DIST;
	int * cu_L, * cu_OUT;
	cudaMalloc(&cu_X, n * d * sizeof(float));
	cudaMalloc(&cu_Y, d * sizeof(float));
	cudaMalloc(&cu_DIST, n * sizeof(float));
	cudaMalloc(&cu_L, n * sizeof(int));
	cudaMalloc(&cu_OUT, n * sizeof(int));

	// Copy the provided data to the GPU.
	cudaMemcpy(cu_X, X, n * d * sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(cu_Y, Y, d * sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(cu_L, L, n * sizeof(int), cudaMemcpyHostToDevice);

	// Compute distances in parallel in 1 block of 256 threads.
	calcDistE<<<(n + 255)/256, 256>>>(n, d, cu_Y, cu_X, cu_DIST);
	findNearest<<<(n + 255)/256, 256>>>(n, cu_DIST, cu_L, cu_OUT);

	// Copy the sorted labels from our output
	int * OUT = (int *)malloc(n * sizeof(int));
	cudaMemcpy(OUT, cu_OUT, n * sizeof(int), cudaMemcpyDeviceToHost);

	// Count each class.
	int * count = (int *)malloc(C * sizeof(int));
	memset(count, 0, C * sizeof(int));
	for (int i=0; i<k; ++i) { ++count[OUT[i]]; }

	// Print the results.
	printf("knn: k=%d\n", k);
	for (int i=0; i<C; ++i) {
		printf("class %s:\t%d/%d\n", Cstr[i], count[i], k);
	}
	printf("\n");

	// Cleanup GPU...
	cudaFree(cu_X);
	cudaFree(cu_Y);
	cudaFree(cu_DIST);
	cudaFree(cu_L);
	cudaFree(cu_OUT);

	// Cleanup CPU...
	free(OUT);
	free(count);
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
	knn(n, d, Y, X, L, 2, LABELS, 1);
	knn(n, d, Y, X, L, 2, LABELS, 3);
}
