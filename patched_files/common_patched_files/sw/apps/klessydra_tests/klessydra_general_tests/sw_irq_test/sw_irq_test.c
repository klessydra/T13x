#include"functions.h"

int main()
{ 
	__asm__(	
		"csrw 0x300, 0x8;" 	// each thread enables it's own interrupt
	);
	
	if(Klessydra_get_coreID() == 0) // thread number 0 sends a sw_irq to thread number 3
	{
		send_sw_irq(1);
	}
	
	int a = 0;
	
	for(int i=0; i<100; i++) a++;	// do something while sw_irq routine finishes

	return 0;
}
