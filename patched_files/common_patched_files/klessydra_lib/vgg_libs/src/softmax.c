#include"definitions_data_test.h"

void softmax (int dim, float *vect, float *softmax)
{
 	float cost = 0;
	int i;

	for (i = 0; i < dim; i++)
	{
		cost = cost + exp(vect[i]);
	}

	for (i = 0; i < dim; i++)
	{
		softmax[i] = (exp(vect[i])/cost);
	}
}

