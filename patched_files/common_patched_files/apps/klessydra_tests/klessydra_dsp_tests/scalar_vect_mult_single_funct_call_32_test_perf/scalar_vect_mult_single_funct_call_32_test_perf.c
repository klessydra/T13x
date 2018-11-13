#include"dsp_functions.h"

#define NumOfElements 8

int vect32_1[NumOfElements] = {0xFFFFFFFF, 0xEEEEEEEE, 0xDDDDDDDD, 0xCCCCCCCC, 0xBBBBBBBB, 0xAAAAAAAA, 0x99999999, 0x88888888};
int scal32_2 = 0x77777777;
int result[NumOfElements];
int size=NumOfElements*sizeof(int);

int main()
{	
        __asm__("csrrw zero, mcycle, zero");
	kless_scalar_vect_mult_32((void*)result, (void*)vect32_1, (void*) scal32_2, size);
	return 0;
}


