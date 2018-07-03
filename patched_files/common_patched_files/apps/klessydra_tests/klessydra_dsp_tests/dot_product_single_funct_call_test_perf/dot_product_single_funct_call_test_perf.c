#include"dsp_functions.h"

#define NumOfElements 20

int vect1[NumOfElements];
int vect2[NumOfElements];
int result[NumOfElements];
int size=NumOfElements*sizeof(int);

int main()
{	
        __asm__("csrrw zero, mcycle, zero");
	kless_dot_product((void*)result, (void*)vect1, (void*)vect2, size);
}


