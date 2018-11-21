#include"definitions_data_test.h"

void addBias(int size, float *matrix, float bias)
{
	for (int i = 0; i < size; i++)
	{
		for (int j = 0; j < size; j++)
		{
			matrix[j + size*i] += bias;
		}
	}
}

