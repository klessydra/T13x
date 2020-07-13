#include"functions.h"

int main()
{

	if(Klessydra_get_coreID() == 1)
	{
		asm( "EBREAK;");
	}
	else {
		asm( "WFI;");
	}
	return 0;
}
