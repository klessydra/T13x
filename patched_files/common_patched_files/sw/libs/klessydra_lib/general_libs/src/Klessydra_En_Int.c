#include"functions.h"

void Klessydra_En_Int()
{
	__asm__("csrs 0x300, 0x8;");
}
