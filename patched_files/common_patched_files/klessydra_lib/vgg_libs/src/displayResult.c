#include"definitions_data_test.h"

void displayResult(FILE *fp, int pos)
{
	char name;
	int i = 0;

	printf("What I recognized is: ");

	while (fscanf(fp, "%c", &name) > 0)
	{
        	if (i == pos)
		{
                	printf("%c", name);
        	}
        	if (name == '\n')
		{
                	i++;
        	}
	}
	printf("\n");
}

