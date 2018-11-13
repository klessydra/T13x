#include"definitions_data_test.h"

void relu(int size, float *input)
{
	for (int i = 0; i < size; i++)
	{
		for (int j = 0; j < size; j++)
		{
			if (input[j + size*i] < 0) {
				input[j + size*i] = 0;
			}
		}
	}
}

void reluVect(int size, float *input)
{
         for (int i = 0; i < size; i++)
         {
         	if (input[i] < 0) input[i] = 0;
         }

}

