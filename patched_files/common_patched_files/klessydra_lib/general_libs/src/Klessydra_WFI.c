#include"functions.h"

void Klessydra_WFI()
{
	__asm__(
		"csrw 0x300, 0x8;"
		"WFI;"
	);
}



