#include"dsp_functions.h"

void mcycle_reset(void) 
{
	asm volatile(
		"csrrw zero, mcycle,    zero;"
		"csrrw zero, mcycleh,   zero;"
	);
}
/*
int* mcycle_save(void* ptr_mcycle) 
{
	int perf = 0;
	asm volatile(
		"csrrw %[perf], mcycle, zero;"
		"sw %[perf], 0(%[ptr_mcycle]);"
		"csrrw %[perf], mcycleh, zero;"
		"sw %[perf], 4(%[ptr_mcycle]);"
		:
		:[perf]        "r" (perf),
		 [ptr_mcycle]  "r" (ptr_mcycle)
		);
	return ptr_mcycle;
}
*/
void minstret_reset(void) 
{
	asm volatile(
		"csrrw zero, minstret,    zero;"
		"csrrw zero, minstreth,   zero;"
	);
}

int* minstret_save(void* ptr_perf) 
{
	int perf = 0;
	asm volatile(
		"csrrw %[perf], mcycle, zero;"
		"sw %[perf], 0(%[ptr_perf]);"
		"addi %[ptr_perf], %[ptr_perf], 4;"
		"csrrw %[perf], mcycleh, zero;"
		"sw %[perf], 0(%[ptr_perf]);"
		:
		:[perf]      "r" (perf),
		 [ptr_perf]  "r" (ptr_perf)
		);
	return ptr_perf;
}
