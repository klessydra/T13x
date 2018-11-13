#include"dsp_functions.h"
#include"functions.h"

#define NumOfElements 20

int vect1[NumOfElements] = {0xFFFFFFFF, 0xEEEEEEEE, 0xDDDDDDDD, 0xCCCCCCCC, 0xBBBBBBBB, 0xAAAAAAAA, 0x99999999, 0x88888888};
int vect2[NumOfElements] = {0x77777777, 0x66666666, 0x55555555, 0x44444444, 0x33333333, 0x22222222, 0x11111111, 0x00000000};
int result[NumOfElements];
int size=NumOfElements*sizeof(int);

int main()
{
	/* operative section*/
        __asm__("csrrw zero, mcycle, zero");
	if (Klessydra_get_coreID()==0)
	{
		kmemld((void*)spmaddrA, (void*)vect1, size);
		Klessydra_WFI();
	}
	else if(Klessydra_get_coreID()==1)								
	{
		kmemld((void*)spmaddrB, (void*)vect2, size);
	}
	
	else	Klessydra_WFI();
	
	CSR_MVSIZE(size);
	
	kaddv32((void*)spmaddrC, (void*)spmaddrA, (void*)spmaddrB);
	
	kmemstr((void*)result, (void*)spmaddrC, size);
}
