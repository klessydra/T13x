#include"functions.h"

int main()
{
	Klessydra_get_coreID();
	if(Klessydra_get_coreID()==0)	Klessydra_WFI();
}
