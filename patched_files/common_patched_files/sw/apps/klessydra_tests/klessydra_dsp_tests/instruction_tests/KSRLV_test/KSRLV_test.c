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

uint8_t  vect8_1[NumOfElements];
uint16_t vect16_1[NumOfElements];
uint32_t vect32_1[NumOfElements];
uint8_t  scal8_2;
uint16_t scal16_2;
uint32_t scal32_2;
uint8_t  testres8[NumOfElements];
uint16_t testres16[NumOfElements];
uint32_t testres32[NumOfElements];
uint8_t  *res8;
uint16_t *res16;
uint32_t *res32;
uint8_t  result8[NumOfElements];
uint16_t result16[NumOfElements];
uint32_t result32[NumOfElements];
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

	scal8_2  = rand() % 8;
	scal16_2 = rand() % 16;
	scal32_2 = rand() % 32;

	
	int dsp_perf8  = 0;
	int dsp_perf16 = 0;
	int dsp_perf32 = 0;
	int test_perf_i = 0;
	int* dsp_ptr_perf8 = &dsp_perf8;
	int* dsp_ptr_perf16 = &dsp_perf16;
	int* dsp_ptr_perf32 = &dsp_perf32;
	int* test_ptr_perf = &test_perf_i;

	int srl_pass;
	/************************************ 8-bit SRLV Start ***************************************/
	CSR_MVTYPE(0);  // set data type to 8-bit

	// ENABLE COUNTING -------------------------------------------------------------------------
	__asm__("csrrw zero, mcycle, zero;"
			"csrrw zero, 0x7A0, 0x00000001");
	//------------------------------------------------------------------------------------------
	
	// TEST KSRLV8 ----------------------------------------------------------------------------	
	res8=kless_vector_right_shift_logic((void*) result8, (void*) vect8_1, (void*) scal8_2,  size8);
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
	
	// Test 8-bit srlv result -----------------------------------------------------------------
	srl_pass = 0;
	if (Klessydra_get_coreID()==1)
	{
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<NumOfElements; i++)
		{
			testres8[i] = vect8_1[i]>>scal8_2;
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
				srl_pass++;
			}
			else 
			{
				goto FAIL_VECT_SRL_8;
			}
		}
		if (srl_pass==NumOfElements)
		{
			printf("\nPASSED KSRLV8  8-bit  right logic shift");
		}
	}

	// -----------------------------------------------------------------------------------------
	
	/************************************ 8-bit SRLV END *****************************************/

	/************************************ 16-bit SRLV Start **************************************/
	VECT_SRL_16:
	CSR_MVTYPE(1);  // set data type to 16-bit

	srl_pass = 0;
	
	// ENABLE COUNTING -------------------------------------------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000001");
	//------------------------------------------------------------------------------------------

	// TEST KSRLV16 ---------------------------------------------------------------------------
	res16=kless_vector_right_shift_logic((void*) result16, (void*) vect16_1, (void*) scal16_2, size16);
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
	
	// Test 16-bit srlv result ----------------------------------------------------------------
	if (Klessydra_get_coreID()==1)
	{
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<NumOfElements; i++)
		{
			testres16[i] = vect16_1[i]>>scal16_2;
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
				srl_pass++;
			}
			else 
			{
				goto FAIL_VECT_SRL_16;
			}
		}
		if (srl_pass==NumOfElements)
		{
			printf("\nPASSED KSRLV16 16-bit right logic shift");
		}
	}
	// --------------------------------------------------------------------------------------------

	/************************************ 16-bit SRLV END ****************************************/		

	/************************************ 32-bit SEAV Start **************************************/
	VECT_SRL_32:
	CSR_MVTYPE(2);  // set data type to 16-bit

	srl_pass = 0;
	
	// ENABLE COUNTING ---------------------------------------------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000001");
	//--------------------------------------------------------------------------------------------
	
	// TEST KSRLV --------------------------------------------------------------------------------	
	res32=kless_vector_right_shift_logic((void*) result32, (void*) vect32_1, (void*) scal32_2, size32);
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
	
	// Test 32-bit SRLV result -------------------------------------------------------------------
	srl_pass = 0;
	if (Klessydra_get_coreID()==1)
	{
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<NumOfElements; i++)
		{
			testres32[i] = vect32_1[i]>>scal32_2;
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
				srl_pass++;
			}
			else 
			{
				goto FAIL_VECT_SRL_32;
			}
		}
		if (srl_pass==NumOfElements)
		{
			printf("\nPASSED KSRLV32 32-bit right logic shift\n\n");
		}
	}
	// -------------------------------------------------------------------------------------------
	
	/************************************ 32-bit SRLV END ***************************************/
	
	if (Klessydra_get_coreID()==1)
	{		
		printf("\nNumber of Elements: %d\n",NumOfElements);
		for(int i=0;i<3;i++)
		{
				printf("Th%d KSRLV8  Speed: %d Cycles\n",i, perf8[i]);
		}
		for(int i=0;i<3;i++)
		{
				printf("Th%d KSRLV16 Speed: %d Cycles\n",i, perf16[i]);
		}
		for(int i=0;i<3;i++)
		{
				printf("Th%d KSRLV32 Speed: %d Cycles\n",i, perf32[i]);
		}
		for(int i=0;i<3;i++)
		{
				printf("SRLV%d Speed: %d Cycles\n",8*power(2,i), testperf[i]);
		}
		return 0;
	}	

	__asm__("csrrw zero, mstatus, 8;" "wfi;");
	return 0;

	FAIL_VECT_SRL_8: 
	printf("\nFAILED KSRLV8  8-bit right logic shift");
	goto VECT_SRL_16;
	FAIL_VECT_SRL_16: 
	printf("\nFAILED KSRLV16 16-bit right logic shift");
	goto VECT_SRL_32;
	FAIL_VECT_SRL_32: 
	printf("\nFAILED KSRLV32 32-bit right logic shift\n");
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
