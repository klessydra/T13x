#include<stdio.h>
#include"functions.h"

int *plock;	
int lock_value = 0;		

int main()
{
	plock = &(lock_value);
	klessydra_lock_acquire(plock);
	
	__asm__(
		"ADDI x13, x13, 255;"
	);
	
	klessydra_lock_release(plock);
	
	if(Klessydra_get_coreID() == 0)
	{
	
		__asm__("j 0x90000");
	
	}

	return 0;
}
