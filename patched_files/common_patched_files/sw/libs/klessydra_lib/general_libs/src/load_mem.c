#include"functions.h"

void load_mem(int data_send, int store_addr)
{
	__asm__(	
		"sw %0, (%1);"
		:/*no output register*/
		:"r"(data_send), "r"(store_addr)
		:/*no clobbered register*/
	);
}
