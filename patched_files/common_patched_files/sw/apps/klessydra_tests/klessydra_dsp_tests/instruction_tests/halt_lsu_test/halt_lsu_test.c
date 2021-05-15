#include"dsp_functions.h"
#include"functions.h"

#define NumOfElements 50
#define TIME 10

int vect1[NumOfElements];
int vect2[NumOfElements];
int result[NumOfElements];
int size=NumOfElements*sizeof(int);
int size2=200;

int main()
{
	srand (TIME);
	for (int i=0; i<NumOfElements; i++) 
	{ 
		vect1[i] = rand()  % (0x80000000 - 0x1) +1;
		vect2[i] = rand()  % (0x80000000 - 0x1) +1;
	}
	/* operative section*/
     __asm__("csrrw zero, mcycle, zero");
	if (Klessydra_get_coreID()==0)
	{
		kmemld((void*)spmaddrA, (void*)vect1, size);
		kmemld((void*)spmaddrA, (void*)vect1, size);
		CSR_MVSIZE(size);
		kdotp32((void*)spmaddrC, (void*)spmaddrA, (void*)spmaddrB);
		kmemld((void*)spmaddrA, (void*)vect1, size);
	}
	else
	{
		Klessydra_WFI();
	}
	
	return 0;
}
