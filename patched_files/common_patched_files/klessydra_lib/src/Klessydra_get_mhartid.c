#include"functions.h"

int Klessydra_get_mhartid()
{
	int mhartid_value;

	__asm__(
		"CSRR %0, 0xF10;" 
		:"=r"(mhartid_value)
		:/*no input register*/
		:/*no clobbered register*/
	);
	
	return mhartid_value;
}
