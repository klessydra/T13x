#include"KlessydraSPM.h"

int main()
{
	int vect[7] = {1, 2, 3, 4, 5, 6, 7};

	Klessydra_spmcpy_in((void*) vect, sizeof(vect), (void*)SPMADDR1);
}
