#include<stdlib.h>

#define SIZE (8*1024)

// char mem[SIZE];
int perform[NumOfThreads];

int main()
{
	char mem[SIZE];
	char *ptr;
	int perf = 0;
	int* ptr_perf = &perf;

	// ENABLE COUNTING -------------------------------------------------------------------------
	__asm__("csrrw zero, mcycle, zero;"
			"csrrw zero, 0x7A0, 0x00000001");
	//------------------------------------------------------------------------------------------
	ptr = 0x1FF000;
	for (int i = 0; i < SIZE; i++) 
	{
		mem[i] = i;
		asm
		(
		"sb %[i], 0(%[ptr])"
                :
                : [i] "r" (i), [ptr] "r" (ptr)
		);
		ptr++;
	}
	ptr = mem;
	for (int i = 0; i < SIZE; i++) 
	{
		asm
		(
		"lbu t3, 0(%[ptr])"
                :
		: [ptr] "r" (ptr)
		);
		ptr++;
	}
	// DISABLE COUNTING AND SAVE MCYCLE OF EACH THREAD -----------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[perf], mcycle, zero;"
			"sw %[perf], 0(%[ptr_perf]);"
			:
			:[perf] "r" (perf), [ptr_perf] "r" (ptr_perf)
			);
	//------------------------------------------------------------------------------------------
	if (Klessydra_get_coreID()==0) perform[0]=perf;
	if (Klessydra_get_coreID()==1) perform[1]=perf;
	if (Klessydra_get_coreID()==2) perform[2]=perf;
	
	for(int i=0;i<3;i++)
	{
		printf("Th%d Speed: %d Cycles\n",i, perform[i]);
	}
	
return 0;
}
