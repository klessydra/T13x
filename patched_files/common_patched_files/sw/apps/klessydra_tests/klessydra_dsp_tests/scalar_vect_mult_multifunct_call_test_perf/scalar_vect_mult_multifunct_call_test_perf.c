#include"dsp_functions.h"
#include"functions.h"

#define NumOfElements 20

int vect1[NumOfElements];
int vect2[NumOfElements];
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
