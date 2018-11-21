// OK

#include"KlessydraSPM.h"
#include"klessydraCfunctions.h"

int vect1[4] = {1, 2, 3, 4};
int vect2[4] = {0, 0, 0, 0};	

int main()
{
	if(Klessydra_get_coreID()==0)
	{
		Klessydra_spmcpy_in((void*) vect1, sizeof(vect1), (void*)SPMADDR1);
		Klessydra_spmcpy_out((void*)SPMADDR1, sizeof(vect1), (void*) vect2);
	
		int i=0;
		int MyCount=0;
	
		for(i=0; i<sizeof(vect1); i++)
		{
			if(vect2[i]==vect1[i]) MyCount++;
		}
	
		if(MyCount==sizeof(vect1) && sizeof(vect1)==sizeof(vect2)) __asm__("j 0x90000");
		else __asm__("j 0x90004");
	}
	else Klessydra_WFI();
}
