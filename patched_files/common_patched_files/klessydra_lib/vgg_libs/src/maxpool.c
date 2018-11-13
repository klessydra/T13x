#include"definitions_data_test.h"

void maxpool(int size_i, float *input, int size_o, float *output)
{
        float max;
        float temp[size_o*size_o];
        int i;
        int j;
        int h = 0;

        for (int m = 0; m < size_i; m+=2)
        {
                for (int n = 0; n < size_i; n+=2)
                {
                        max = input[n + size_i*m];

                        for (i = m; i < m+2; i++)
                        {
                                for (j = n; j < n+2; j++)
                                {
                                        if (input[j + size_i*i] > max)
                                        {
                                                max = input[j + size_i*i];
                                        }
                                }
                        }

                        output[h] = max;
                        h++;
                }
        }
}

