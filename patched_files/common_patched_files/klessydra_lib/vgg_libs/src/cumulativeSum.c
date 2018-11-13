#include"definitions_data_test.h"

void cumulativeSum(int size, float *dest, float *source)
{
	for (int i = 0; i < size; i++)
	{
		for (int j = 0; j < size; j++)
		{
			dest[j + size*i] += source[j + size*i];
		}
	}
}

