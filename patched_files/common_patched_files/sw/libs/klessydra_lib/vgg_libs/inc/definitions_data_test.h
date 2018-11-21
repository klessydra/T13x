#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#define INPUT_SIZE 32
#define CHANNEL_SIZE 3
#define SIZE_L1_2 INPUT_SIZE
#define SIZE_L3_5 INPUT_SIZE/2
#define SIZE_L6_9 INPUT_SIZE/4
#define SIZE_L10_13 INPUT_SIZE/8
#define SIZE_L14_17 INPUT_SIZE/16
#define SIZE_L18 INPUT_SIZE/32
#define OUTPUT_SIZE 10
//#include <time.h>

extern const float testo[2][2];

extern const float input[3][32][32];
extern const float layer0_bias[];

extern const float layer1_filters[];
extern const float layer1_bias[];

extern const float layer2_filters[];
extern const float layer2_bias[];   

// extern const float layer4_filters[];  
// extern const float layer4_bias[];     

// extern const float layer5_filters[]; 
// extern const float layer5_bias[];

// extern const float layer7_filters[];
// extern const float layer7_bias[];

// extern const float layer8_filters[];
// extern const float layer8_bias[];

// extern const float layer9_filters[];
// extern const float layer9_bias[];

// extern const float layer11_filters[];
// extern const float layer11_bias[];

// extern const float layer12_filters[];
// extern const float layer12_bias[];
     
// extern const float layer13_bias[];
// extern const float layer13_filters[];  

  
// extern const float layer15_filters[];  
// extern const float layer15_bias[]; 

// extern const float layer16_filters[];  
// extern const float layer16_bias[]; 
  
// extern const float layer17_filters[];
// extern const float layer17_bias[];

// extern const float layer19_filters[];
// extern const float layer19_bias[];

// extern const float layer20_filters[];  
// extern const float layer20_bias[];
 
// extern const float layer21_filters[]; 
// extern const float layer21_bias[];     

///////////////////////////////////
void convolution2D(int size, const float (*matrix)[size], float *kernel, float *out);
void convolution2D_KE(int size, const float (*matrix)[size], float *kernel, float *out);
void convolution2D_KF(int size, const float (*matrix)[size], float *kernel, float *out);
void convolution2D_KD(int size, const float (*matrix)[size], float *kernel, float *out);
void convolution2D_KB(int size, const float (*matrix)[size], float *kernel, float *out);
void convolution2D_KH(int size, const float (*matrix)[size], float *kernel, float *out);

/*
 * Function that receives a pointer to a square matrix of size 'size'
 * and analyzes each element: if an element is less than 0, then it
 * forces it to 0; otherwise it returns that element as it is.
 */
void relu(int size, float *input);

/*
 * Function that receives a pointer to a vector of length 'size'
 * and analyzes each element: if an element is less than 0, then it
 * forces it to 0; otherwise it returns that element as it is.
 */
void reluVect(int size, float *input);

/*
 * Function that receives a pointer to an 'input' square matrix of size 'size_i'
 * and returns a square matrix of size 'size_o' (possibly a vector) whose elements are the maximum element
 * of each submatrix of size 'size_o' within 'input' (stride = 2, pad = 2).
 */
void maxpool(int size_i, float *input, int size_o, float *output);

/*
 * Function that returns the product between two vectors 'a' and 'b' of length 'dim'.
 */
float fullyconnect(int dim, float *a, float *b);

/*
 * Function that receives a pointer to a vector 'vect' and returns a vector 'softmax' whose
 * elements are a normalization of the original ones. 'dim' is the vector length.
 */
void softmax(int dim, float *vect, float *softmax);

/*
 * Function that takes two square matrixes of size 'size' as input
 * and puts into 'dest' the sum of 'dest' itself and 'source.
 */
void cumulativeSum(int size, float *dest, float *source);

/*
 * Function that reads the file pointed by 'fp', and put 'num_param' parameters into 'kernel' starting from the 'i'-th row
 * and the 'k'-th row. The inputs 'maxColumn' and 'maxRow' are respectively the number of parameters in the current filter,
 * and the numer of filters in the current layer.
 * es: in conv2 there are 64 filters (maxRow=63) and each filter has 3x3x64=576 (maxColumn= 575) parameters.
*/


//void getWeights(FILE *fp, int num_param, int i, int k, int maxColumn, int maxRow, float *Kernel);
void getWeights(const float *fp, int num_param, float *kernel, int cont);


/*
 * Function that initialize each element of a matrix 'matrix' of size 'size' to 0.
 */
void matrixReset(int size, float *matrix);

/*
 * Function that receives a pointer to a matrix of size 'size' and
 * adds a bias to each element belonging to that matrix.
 */
void addBias(int size, float *matrix, float bias);

/*
 * Function that reads the file pointed by 'fp' and returns a floating number
 * to be used later as a bias.
 */
float getBias(const float *ptb,int cont);

/*
 * Function that reads the file containing the classes recognized by the network
 * and, receiving an integer representing the position of the result in the softmax vector,
 * displays on screen the name of the class recognized.
 */
void displayResult(FILE *fp, int pos);

