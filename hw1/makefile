EXE = knn-cuda
OBJ = main.o
LIB = -lcuda

all: $(OBJ)
	nvcc -o $(EXE) $(OBJ) $(LIB)

main.o: main.cu
	nvcc -c main.cu

clean:
	rm -rf $(EXE)
	rm -rf *.o
