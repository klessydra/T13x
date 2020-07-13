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

#define SPMADDR spmaddrA

int32_t dest;
int8_t  scal8;
int16_t scal16;
int32_t scal32;
int8_t  testres8[NumOfElements];
int16_t testres16[NumOfElements];
int32_t testres32[NumOfElements];
int8_t  *res8;
int16_t *res16;
int32_t *res32;
int8_t  result8[NumOfElements];
int16_t result16[NumOfElements];
int32_t result32[NumOfElements];
int testperf[NumOfThreads], perf8[NumOfThreads], perf16[NumOfThreads], perf32[NumOfThreads];
int size8=NumOfElements*sizeof(char);
int size16=NumOfElements*sizeof(short);
int size32=NumOfElements*sizeof(int);

int power(int a,int b);

int main()
{
	srand (TIME);

	scal8  = rand() % 8;
	scal16 = rand() % 16;
	scal32 = rand() % 32;
	
	dest = SPMADDR;
	int dsp_perf8  = 0;
	int dsp_perf16 = 0;
	int dsp_perf32 = 0;
	int test_perf_i = 0;
	int* dsp_ptr_perf8 = &dsp_perf8;
	int* dsp_ptr_perf16 = &dsp_perf16;
	int* dsp_ptr_perf32 = &dsp_perf32;
	int* test_ptr_perf = &test_perf_i;

	int bcast_pass;
	CSR_MVTYPE(0);  // set data type to 9-bit
	/************************************ 8-bit BCAST Start ***************************************/

	// ENABLE COUNTING -------------------------------------------------------------------------
	__asm__("csrrw zero, mcycle, zero;"
			"csrrw zero, 0x7A0, 0x00000001");
	//------------------------------------------------------------------------------------------
	
	// TEST KBCAST8 ----------------------------------------------------------------------------	
	res8=kless_scalar_broadcast((void*) result8, (void*) dest, (void*) scal8, size8);
	//------------------------------------------------------------------------------------------

	// DISABLE COUNTING AND SAVE MCYCLE OF EACH THREAD -----------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[dsp_perf8], mcycle, zero;"
			"sw %[dsp_perf8], 0(%[dsp_ptr_perf8]);"
			:
			:[dsp_perf8] "r" (dsp_perf8), [dsp_ptr_perf8] "r" (dsp_ptr_perf8)
			);
	if (Klessydra_get_coreID()==0) {perf8[0]=dsp_perf8;} //printf("Speed: %d Cycles\n", perf8[0]);}
	if (Klessydra_get_coreID()==1) {perf8[1]=dsp_perf8;} //printf("Speed: %d Cycles\n", perf8[1]);}
	if (Klessydra_get_coreID()==2) {perf8[2]=dsp_perf8;} //printf("Speed: %d Cycles\n", perf8[2]);}
	//------------------------------------------------------------------------------------------
	
	// Test 8-bit bcast result -----------------------------------------------------------------
	bcast_pass = 0;
	if (Klessydra_get_coreID()==1)
	{
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<NumOfElements; i++)
		{
			testres8[i] = scal8;
		}
		__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[test_perf_i], mcycle, zero;"
			"sw %[test_perf_i], 0(%[test_ptr_perf]);"
			:
			:[test_perf_i] "r" (test_perf_i), [test_ptr_perf] "r" (test_ptr_perf)
			);
		testperf[0]=test_perf_i;
		/*
		for (int i=0; i<NumOfElements; i++)
		{
			printf("\ntestres8: %x",testres8[i]);
			printf("\nres8: %x",res8[i]);
		}
		*/
		for (int i=0; i<NumOfElements; i++)
		{
			if (res8[i]==testres8[i])
			{
				bcast_pass++;
			}
			else 
			{
				goto FAIL_SCAL_BCAST_8;
			}
		}
		if (bcast_pass==NumOfElements)
		{
			printf("\nPASSED KBCAST8  8-bit  scalar broadcast");
		}
	}

	// -----------------------------------------------------------------------------------------
	
	/************************************ 8-bit BCAST END *****************************************/

	/************************************ 16-bit BCAST Start **************************************/
	SCAL_BCAST_16:
	CSR_MVTYPE(1);  // set data type to 16-bit
	bcast_pass = 0;
	
	// ENABLE COUNTING -------------------------------------------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000001");
	//------------------------------------------------------------------------------------------

	// TEST KBCAST16 ---------------------------------------------------------------------------
	res16=kless_scalar_broadcast((void*) result16, (void*) dest, (void*) scal16, size16);
	//------------------------------------------------------------------------------------------
	// DISABLE COUNTING AND SAVE MCYCLE OF EACH THREAD ////////
	__asm__("csrrw zero, 0x7A0, 0x00000000;"
	    	"csrrw %[dsp_perf16], mcycle, zero;"
			"sw %[dsp_perf16], 0(%[dsp_ptr_perf16]);"
			:
			:[dsp_perf16] "r" (dsp_perf16), [dsp_ptr_perf16] "r" (dsp_ptr_perf16)
			);
	if (Klessydra_get_coreID()==0) perf16[0]=dsp_perf16;
	if (Klessydra_get_coreID()==1) perf16[1]=dsp_perf16;
	if (Klessydra_get_coreID()==2) perf16[2]=dsp_perf16;
	//------------------------------------------------------------------------------------------
	
	// Test 16-bit BCAST result ----------------------------------------------------------------
	if (Klessydra_get_coreID()==1)
	{
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<NumOfElements; i++)
		{
			testres16[i] = scal16;
		}
		__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[test_perf_i], mcycle, zero;"
			"sw %[test_perf_i], 0(%[test_ptr_perf]);"
			:
			:[test_perf_i] "r" (test_perf_i), [test_ptr_perf] "r" (test_ptr_perf)
			);
		testperf[1]=test_perf_i;
		/*
		for (int i=0; i<NumOfElements; i++)
		{
			printf("\ntestres16: %x",testres16[i]);
			printf("\nres16: %x",res16[i]);
		}
		*/
		for (int i=0; i<NumOfElements; i++)
		{
			if (res16[i]==testres16[i])
			{
				bcast_pass++;
			}
			else 
			{
				goto FAIL_SCAL_BCAST_16;
			}
		}
		if (bcast_pass==NumOfElements)
		{
			printf("\nPASSED KBCAST16 16-bit scalar broadcast");
		}
	}
	// --------------------------------------------------------------------------------------------

	/************************************ 16-bit BCAST END ****************************************/		

	/************************************ 32-bit BCAST Start **************************************/
	SCAL_BCAST_32:
	CSR_MVTYPE(2);  // set data type to 32-bit
	bcast_pass = 0;
	
	// ENABLE COUNTING ---------------------------------------------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000001");
	//--------------------------------------------------------------------------------------------
	
	// TEST KBCAST --------------------------------------------------------------------------------	
	res32=kless_scalar_broadcast((void*) result32, (void*) dest, (void*) scal32, size32);
	//--------------------------------------------------------------------------------------------
	
	// DISABLE COUNTING AND SAVE MCYCLE OF EACH THREAD -------------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000000;"
	    	"csrrw %[dsp_perf32], mcycle, zero;"
			"sw %[dsp_perf32], 0(%[dsp_ptr_perf32]);"
			:
			:[dsp_perf32] "r" (dsp_perf32), [dsp_ptr_perf32] "r" (dsp_ptr_perf32)
			);
	if (Klessydra_get_coreID()==0) perf32[0]=dsp_perf32;
	if (Klessydra_get_coreID()==1) perf32[1]=dsp_perf32;
	if (Klessydra_get_coreID()==2) perf32[2]=dsp_perf32;
	//--------------------------------------------------------------------------------------------
	
	// Test 32-bit BCAST result -------------------------------------------------------------------
	bcast_pass = 0;
	if (Klessydra_get_coreID()==1)
	{
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<NumOfElements; i++)
		{
			testres32[i] = scal32;
		}
		__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[test_perf_i], mcycle, zero;"
			"sw %[test_perf_i], 0(%[test_ptr_perf]);"
			:
			:[test_perf_i] "r" (test_perf_i), [test_ptr_perf] "r" (test_ptr_perf)
			);
		testperf[2]=test_perf_i;
		/*
		for (int i=0; i<NumOfElements; i++)
		{
			printf("\ntestres32: %x",testres32[i]);
			printf("\nres32: %x",res32[i]);
		}
		*/
		for (int i=0; i<NumOfElements; i++)
		{
			if (res32[i]==testres32[i])
			{
				bcast_pass++;
			}
			else 
			{
				goto FAIL_SCAL_BCAST_32;
			}
		}
		if (bcast_pass==NumOfElements)
		{
			printf("\nPASSED KBCAST32 32-bit scalar broadcast\n\n");
		}
	}
	// -------------------------------------------------------------------------------------------
	
	/************************************ 32-bit BCAST END ***************************************/
	
	if (Klessydra_get_coreID()==1)
	{		
		printf("\nNumber of Elements: %d\n",NumOfElements);
		for(int i=0;i<3;i++)
		{
				printf("Th%d KBCAST8  Speed: %d Cycles\n",i, perf8[i]);
		}
		for(int i=0;i<3;i++)
		{
				printf("Th%d KBCAST16 Speed: %d Cycles\n",i, perf16[i]);
		}
		for(int i=0;i<3;i++)
		{
				printf("Th%d KBCAST32 Speed: %d Cycles\n",i, perf32[i]);
		}
		for(int i=0;i<3;i++)
		{
				printf("BCAST%d Speed: %d Cycles\n",8*power(2,i), testperf[i]);
		}
		return 0;
	}	

	__asm__("csrrw zero, mstatus, 8;" "wfi;");
	return 0;

	FAIL_SCAL_BCAST_8: 
	printf("\nFAILED KBCAST8  8-bit scalar broadcast");
	goto SCAL_BCAST_16;
	FAIL_SCAL_BCAST_16: 
	printf("\nFAILED KBCAST16 16-bit scalar broadcast");
	goto SCAL_BCAST_32;
	FAIL_SCAL_BCAST_32: 
	printf("\nFAILED KBCAST32 32-bit scalar broadcast\n");
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
