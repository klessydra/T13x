#include"definitions_data_test.h"

float fullyconnect(int dim, float *a, float *b)
{
	float temp_sum = 0.0;
	//float  product;

		for(int i=0; i<dim ; i++){
			temp_sum += a[i]*b[i];
		}

		//product = temp_sum;

	return temp_sum;
}

