#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include "dsp_functions.h"
#include "functions.h"
#include "klessydra_defs.h"

#define NumOfThreads 3
#define scalar_size 4 

#ifndef NumOfElements
	#define NumOfElements 10
#endif


#ifndef TIME
	#define TIME 10
#endif

int8_t  vect8_1[NumOfElements];
int16_t vect16_1[NumOfElements];
int32_t vect32_1[NumOfElements];
int8_t  testres8;
int16_t testres16;
int32_t testres32;
int8_t  *res8;
int16_t *res16;
int32_t *res32;
int result8[scalar_size], result16[scalar_size], result32[scalar_size];
int testperf[NumOfThreads], perf8[NumOfThreads], perf16[NumOfThreads], perf32[NumOfThreads];
int size8=NumOfElements*sizeof(char);
int size16=NumOfElements*sizeof(short);
int size32=NumOfElements*sizeof(int);

int power(int a,int b);

int main()
{
	srand (TIME);
	for (int i=0; i<NumOfElements; i++) 
	{ 
    	vect8_1[i]  = rand()  % (0x100 - 0x1) +1;
    	vect16_1[i] = rand()  % (0x10000 - 0x1) +1;
    	vect32_1[i] = rand()  % (0x80000000 - 0x1) +1;
	}

	
	int dsp_perf8  = 0;
	int dsp_perf16 = 0;
	int dsp_perf32 = 0;
	int test_perf_i = 0;
	int* dsp_ptr_perf8 = &dsp_perf8;
	int* dsp_ptr_perf16 = &dsp_perf16;
	int* dsp_ptr_perf32 = &dsp_perf32;
	int* test_ptr_perf = &test_perf_i;

	/************************************ 8-bit VRED Start ***************************************/
	CSR_MVTYPE(0);  // set data type to 8-bit

	// ENABLE COUNTING -------------------------------------------------------------------------
	__asm__("csrrw zero, mcycle, zero;"
			"csrrw zero, 0x7A0, 0x00000001");
	//------------------------------------------------------------------------------------------
	
	// TEST KVRED8 ----------------------------------------------------------------------------	
	res8=kless_vector_reduction((void*) result8, (void*) vect8_1, size8);
	//------------------------------------------------------------------------------------------

	// DISABLE COUNTING AND SAVE MCYCLE OF EACH THREAD -----------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[dsp_perf8], mcycle, zero;"
			"sw %[dsp_perf8], 0(%[dsp_ptr_perf8]);"
			:
			:[dsp_perf8] "r" (dsp_perf8), [dsp_ptr_perf8] "r" (dsp_ptr_perf8)
			);
	if (Klessydra_get_coreID()==0) {perf8[0]=dsp_perf8; } //printf("Speed: %d Cycles\n", perf8[0]);}
	if (Klessydra_get_coreID()==1) {perf8[1]=dsp_perf8; } //printf("Speed: %d Cycles\n", perf8[1]);}
	if (Klessydra_get_coreID()==2) {perf8[2]=dsp_perf8; } //printf("Speed: %d Cycles\n", perf8[2]);}
	//------------------------------------------------------------------------------------------
	
	// Test 8-bit vred result -----------------------------------------------------------------
	if (Klessydra_get_coreID()==1)
	{
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<NumOfElements; i++)
		{
			testres8 += vect8_1[i];
		}
		__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[test_perf_i], mcycle, zero;"
			"sw %[test_perf_i], 0(%[test_ptr_perf]);"
			:
			:[test_perf_i] "r" (test_perf_i), [test_ptr_perf] "r" (test_ptr_perf)
			);
		testperf[0]=test_perf_i;
		/*
		printf("\ntestres8: %x",testres8);
		printf("\nres8: %x",*res8);
		*/
		if (*res8==testres8)
		{
			printf("\nPASSED KVRED8  8-bit vector reduction");
		}
		else 
		{
			goto FAIL_VRED_8;
		}
	}

	// -----------------------------------------------------------------------------------------
	
	/************************************ 8-bit VRED END *****************************************/

	/************************************ 16-bit VRED Start **************************************/
	VRED_16:
	CSR_MVTYPE(1);  // set data type to 16-bit

	// ENABLE COUNTING -------------------------------------------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000001");
	//------------------------------------------------------------------------------------------

	// TEST KVRED16 ---------------------------------------------------------------------------
	res16=kless_vector_reduction((void*) result16, (void*) vect16_1, size16);
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
	
	// Test 16-bit vred result -----------------------------------------------------------------
	if (Klessydra_get_coreID()==1)
	{
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<NumOfElements; i++)
		{
			testres16 += vect16_1[i];
		}
		__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[test_perf_i], mcycle, zero;"
			"sw %[test_perf_i], 0(%[test_ptr_perf]);"
			:
			:[test_perf_i] "r" (test_perf_i), [test_ptr_perf] "r" (test_ptr_perf)
			);
		testperf[1]=test_perf_i;
		/*
		printf("\ntestres16: %x",testres16);
		printf("\nres16: %x",*res16);
		*/

		if (*res16==testres16)
		{
			printf("\nPASSED KVRED16 16-bit vector reduction");
		}
		else 
		{
			goto FAIL_VRED_16;
		}
	}
	// --------------------------------------------------------------------------------------------

	/************************************ 16-bit VRED END ****************************************/		

	/************************************ 32-bit SEAV Start **************************************/
	VRED_32:
	CSR_MVTYPE(2);  // set data type to 32-bit

	// ENABLE COUNTING ---------------------------------------------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000001");
	//--------------------------------------------------------------------------------------------
	
	// TEST KVRED --------------------------------------------------------------------------------	
	res32=kless_vector_reduction((void*) result32, (void*) vect32_1, size32);
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
	
	// Test 32-bit vred result -------------------------------------------------------------------
	if (Klessydra_get_coreID()==1)
	{
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<NumOfElements; i++)
		{
			testres32 += vect32_1[i];
		}
		__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[test_perf_i], mcycle, zero;"
			"sw %[test_perf_i], 0(%[test_ptr_perf]);"
			:
			:[test_perf_i] "r" (test_perf_i), [test_ptr_perf] "r" (test_ptr_perf)
			);
		testperf[2]=test_perf_i;
		/*
		printf("\ntestres32: %x",testres32);
		printf("\nres32: %x",*res32);
		*/
		if (*res32==testres32)
		{
			printf("\nPASSED KVRED32 32-bit vector reduction\n\n");
		}
		else 
		{
			goto FAIL_VRED_32;
		}
	}
	// -------------------------------------------------------------------------------------------
	
	/************************************ 32-bit VRED END ***************************************/
	
	if (Klessydra_get_coreID()==1)
	{		
		printf("\nNumber of Elements: %d\n",NumOfElements);
		for(int i=0;i<3;i++)
		{
				printf("Th%d KVRED8  Speed: %d Cycles\n",i, perf8[i]);
		}
		for(int i=0;i<3;i++)
		{
				printf("Th%d KVRED16 Speed: %d Cycles\n",i, perf16[i]);
		}
		for(int i=0;i<3;i++)
		{
				printf("Th%d KVRED32 Speed: %d Cycles\n",i, perf32[i]);
		}
		for(int i=0;i<3;i++)
		{
				printf("VRED%d Speed: %d Cycles\n",8*power(2,i), testperf[i]);
		}
		return 0;
	}	

	__asm__("csrrw zero, mstatus, 8;" "wfi;");
	return 0;

	FAIL_VRED_8: 
	printf("\nFAILED KVRED8  8-bit vector reduction");
	goto VRED_16;
	FAIL_VRED_16: 
	printf("\nFAILED KVRED16 16-bit vector reduction");
	goto VRED_32;
	FAIL_VRED_32: 
	printf("\nFAILED KVRED32 32-bit vector reduction\n");
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
