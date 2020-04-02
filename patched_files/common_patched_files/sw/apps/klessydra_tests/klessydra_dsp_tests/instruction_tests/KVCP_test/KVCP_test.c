#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include "dsp_functions.h"
#include "functions.h"
#include "klessydra_defs.h"

#define NumOfThreads 3

#ifndef NumOfElements
	#define NumOfElements 10
#endif


#ifndef TIME
	#define TIME 10
#endif

#define SPMADDR 0x00201000

uint32_t  dest;
uint32_t  vect[NumOfElements];
uint32_t  testres[NumOfElements];
uint32_t  *res;                   // NNN Maybe change this to uint8_t if the scratchpad ever becomes byte addressable
uint32_t  result[NumOfElements];  // NNN Maybe change this to uint8_t if the scratchpad ever becomes byte addressable
int testperf, perf[NumOfThreads];
int size=NumOfElements*sizeof(int);


int main()
{
	srand (TIME);

	for (int i=0; i<NumOfElements; i++) 
	{ 
    	vect[i]  = rand()  % (0x100 - 0x1) +1;
	}

	dest = SPMADDR;
	int dsp_perf  = 0;
	int test_perf_i = 0;
	int* dsp_ptr_perf = &dsp_perf;
	int* test_ptr_perf = &test_perf_i;

	int vcp_pass;
	/************************************** VCP Start ******************************************/

	// ENABLE COUNTING -------------------------------------------------------------------------
	__asm__("csrrw zero, mcycle, zero;"
			"csrrw zero, 0x7A0, 0x00000001");
	//------------------------------------------------------------------------------------------
	
	// TEST KVCP ----------------------------------------------------------------------------	
	res=kless_vector_copy((void*) result, (void*) vect, size);
	//------------------------------------------------------------------------------------------

	// DISABLE COUNTING AND SAVE MCYCLE OF EACH THREAD -----------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[dsp_perf], mcycle, zero;"
			"sw %[dsp_perf], 0(%[dsp_ptr_perf]);"
			:
			:[dsp_perf] "r" (dsp_perf), [dsp_ptr_perf] "r" (dsp_ptr_perf)
			);
	if (Klessydra_get_coreID()==0) {perf[0]=dsp_perf;} //printf("Speed: %d Cycles\n", perf[0]);}
	if (Klessydra_get_coreID()==1) {perf[1]=dsp_perf;} //printf("Speed: %d Cycles\n", perf[1]);}
	if (Klessydra_get_coreID()==2) {perf[2]=dsp_perf;} //printf("Speed: %d Cycles\n", perf[2]);}
	//------------------------------------------------------------------------------------------
	
	// Test vcp result -------------------------------------------------------------------------
	vcp_pass = 0;
	if (Klessydra_get_coreID()==1)
	{
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<NumOfElements; i++)
		{
			testres[i] = vect[i];
		}
		__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[test_perf_i], mcycle, zero;"
			"sw %[test_perf_i], 0(%[test_ptr_perf]);"
			:
			:[test_perf_i] "r" (test_perf_i), [test_ptr_perf] "r" (test_ptr_perf)
			);
		testperf=test_perf_i;
		/*
		for (int i=0; i<NumOfElements; i++)
		{
			printf("\ntestres: %x",testres[i]);
			printf("\nres: %x",res[i]);
		}
		*/
		for (int i=0; i<NumOfElements; i++)
		{
			if (res[i]==testres[i])
			{
				vcp_pass++;
			}
			else 
			{
				goto FAIL_VCP;
			}
		}
		if (vcp_pass==NumOfElements)
		{
			printf("\nPASSED KVCP Vector Copy\n\n");
		}
	}

	// -----------------------------------------------------------------------------------------
	
	/************************************* *VCP END ************************************************/

	
	if (Klessydra_get_coreID()==1)
	{		
		printf("\nNumber of Elements: %d\n",NumOfElements);
		for(int i=0;i<3;i++)
		{
			printf("Th%d KVCP  Speed: %d Cycles\n",i, perf[i]);
		}
		printf("VCP Speed: %d Cycles\n", testperf);

		return 0;
	}	

	__asm__("csrrw zero, mstatus, 8;" "wfi;");
	return 0;

	FAIL_VCP: 
	printf("\nFAILED KVCP Vector Copy");
	if (Klessydra_get_coreID()==1)
	{		
		printf("\nNumber of Elements: %d\n\n",NumOfElements);
	}
 	return 1;
}

int power(int a,int b)
{
	int i=0,pow_int=1;
	for(i=0;i<b;i++)
	{
	 pow_int=pow_int*a;
	}
	return pow_int;
}
