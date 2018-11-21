#include"klessydraCfunctions.h"
#include"KlessydraSPM.h"

int vect1[] = {0, 1, 2, 3};
int vect2[] = {3, 2, 1, 0};
int CompVect[] = {0, 0, 0, 0};
int vSum[4];
int size = sizeof(vect1);

int main()
{

	sync_barrier_reset();
	sync_barrier_thread_registration();

	/* operative section*/
	
	Klessydra_MultFunct_vadd((void*) vSum, (void*) vect1, (void*) vect2, size);
	
	sync_barrier();
	
	/* debug section */
	
	int i=0;
	int MySize = size/32;
	int cnt=0;
	
	for(i=0; i<MySize; i++)				// check how much elements of vect1 are the same as those of vect2
	{
		if(CompVect[i]==vSum[i]) cnt++;
	}
	
	if(cnt==MySize)	__asm__("j 0x90000");		// if they are all equal jump to pass
	else __asm__("j 0x90004");
}
