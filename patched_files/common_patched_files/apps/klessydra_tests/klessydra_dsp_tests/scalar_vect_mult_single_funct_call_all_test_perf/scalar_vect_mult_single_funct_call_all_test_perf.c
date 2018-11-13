#include <stdio.h>
#include "dsp_functions.h"
#include "functions.h"
#include "klessydra_defs.h"

#define NumOfThreads 3
#define NumOfElements 8

unsigned char  vect8_1[NumOfElements] = {0xFF, 0xEE, 0xDD, 0xCC, 0xBB, 0xAA, 0x99, 0x88};
unsigned char  scal8_2 = 0x77;
unsigned short vect16_1[NumOfElements] = {0xFFFF, 0xEEEE, 0xDDDD, 0xCCCC, 0xBBBB, 0xAAAA, 0x9999, 0x8888};
unsigned short scal16_2 = 0x7777;
unsigned int   vect32_1[NumOfElements] = {0xFFFFFFFF, 0xEEEEEEEE, 0xDDDDDDDD, 0xCCCCCCCC, 0xBBBBBBBB, 0xAAAAAAAA, 0x99999999, 0x88888888};
unsigned int   scal32_2 = 0x77777777;
unsigned short  testres8[NumOfElements];
unsigned int testres16[NumOfElements];
unsigned int testres32[NumOfElements];
unsigned short *res8;
unsigned int   *res16;
unsigned int   *res32;
unsigned char  result8[NumOfElements];
unsigned short result16[NumOfElements];
unsigned int   result32[2*NumOfElements];
int testperf[NumOfThreads], perf8[NumOfThreads], perf16[NumOfThreads], perf32[NumOfThreads];
int size8=NumOfElements*sizeof(char);
int size16=NumOfElements*sizeof(short);
int size32=NumOfElements*sizeof(int);

int main()
{	

	int dsp_perf8  = 0;
	int dsp_perf16 = 0;
	int dsp_perf32 = 0;
	int test_perf_i = 0;
	int* dsp_ptr_perf8 = &dsp_perf8;
	int* dsp_ptr_perf16 = &dsp_perf16;
	int* dsp_ptr_perf32 = &dsp_perf32;
	int* test_ptr_perf = &test_perf_i;

	int mult_pass;
	/************************************ 8-bit SVMUL Start ************************************/

	// ENABLE COUNTING -------------------------------------------------------------------------
	__asm__("csrrw zero, mcycle, zero;"
			"csrrw zero, 0x7A0, 0x00000001");
	//------------------------------------------------------------------------------------------
	
	// TEST KSVMUL8 ----------------------------------------------------------------------------	
	res8=kless_scalar_vect_mult_8((void*) result8, (void*) vect8_1, (void*) scal8_2,  size8);
	//------------------------------------------------------------------------------------------

	// DISABLE COUNTING AND SAVE MCYCLE OF EACH THREAD -----------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[dsp_perf8], mcycle, zero;"
			"sw %[dsp_perf8], 0(%[dsp_ptr_perf8]);"
			:
			:[dsp_perf8] "r" (dsp_perf8), [dsp_ptr_perf8] "r" (dsp_ptr_perf8)
			);
	if (Klessydra_get_coreID()==0) {perf8[0]=dsp_perf8; } //printf("Speed: %d Cycles\n", perf8[0]);}
	if (Klessydra_get_coreID()==1) {perf8[1]=dsp_perf8; }//printf("Speed: %d Cycles\n", perf8[1]);}
	if (Klessydra_get_coreID()==2) {perf8[2]=dsp_perf8; } //printf("Speed: %d Cycles\n", perf8[2]);}
	//------------------------------------------------------------------------------------------
	
	// Test 8-bit svmul result -----------------------------------------------------------------
	mult_pass = 0;
	if (Klessydra_get_coreID()==1)
	{
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<NumOfElements; i++)
		{
			testres8[i] = vect8_1[i]*scal8_2;
			//printf("\ntestres8: %x",testres8[i]);
			//printf("\nres8: %x",res8[i]);
		}
		__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[test_perf_i], mcycle, zero;"
			"sw %[test_perf_i], 0(%[test_ptr_perf]);"
			:
			:[test_perf_i] "r" (test_perf_i), [test_ptr_perf] "r" (test_ptr_perf)
			);
		testperf[0]=test_perf_i;
		for (int i=0; i<NumOfElements; i++)
		{
			if (res8[i]==testres8[i])
			{
				mult_pass++;
			}
			else 
			{
				goto FAIL_VECT_SVMUL_8;
			}
		}
		if (mult_pass==NumOfElements)
		{
			printf("\nPASSED 8-bit  svmul");
		}
	}

	// -----------------------------------------------------------------------------------------
	
	/************************************ 8-bit SVMUL END **************************************/

	/************************************ 16-bit SVMUL Start ***********************************/
	VECT_SVMUL_16:
	mult_pass = 0;
	
	// ENABLE COUNTING -------------------------------------------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000001");
	//------------------------------------------------------------------------------------------

	// TEST KSVMUL16 ---------------------------------------------------------------------------
	res16=kless_scalar_vect_mult_16((void*) result16, (void*) vect16_1, (void*) scal16_2, size16);
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
	
	// Test 16-bit svmul result ----------------------------------------------------------------
	if (Klessydra_get_coreID()==1)
	{
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<NumOfElements; i++)
		{
			testres16[i] = vect16_1[i]*scal16_2;
			//printf("\ntestres16: %x",testres16[i]);
			//printf("\nres16: %x",res16[i]);
		}
		__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[test_perf_i], mcycle, zero;"
			"sw %[test_perf_i], 0(%[test_ptr_perf]);"
			:
			:[test_perf_i] "r" (test_perf_i), [test_ptr_perf] "r" (test_ptr_perf)
			);
		testperf[1]=test_perf_i;
		for (int i=0; i<NumOfElements; i++)
		{
			if (res16[i]==testres16[i])
			{
				mult_pass++;
			}
			else 
			{
				goto FAIL_VECT_SVMUL_16;
			}
		}
		if (mult_pass==NumOfElements)
		{
			printf("\nPASSED 16-bit svmul");
		}
	}
	// -----------------------------------------------------------------------------------------

	/************************************ 16-bit SVMUL END *************************************/		

	/************************************ 32-bit SVMUL Start ***********************************/
	VECT_SVMUL_32:
	mult_pass = 0;
	
	// ENABLE COUNTING -------------------------------------------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000001");
	//------------------------------------------------------------------------------------------
	
	// TEST KSVMUL32 ---------------------------------------------------------------------------	
	res32=kless_scalar_vect_mult_32((void*) result32, (void*) vect32_1, (void*) scal32_2, size32);
	//------------------------------------------------------------------------------------------
	
	// DISABLE COUNTING AND SAVE MCYCLE OF EACH THREAD -----------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000000;"
	    	"csrrw %[dsp_perf32], mcycle, zero;"
			"sw %[dsp_perf32], 0(%[dsp_ptr_perf32]);"
			:
			:[dsp_perf32] "r" (dsp_perf32), [dsp_ptr_perf32] "r" (dsp_ptr_perf32)
			);
	if (Klessydra_get_coreID()==0) perf32[0]=dsp_perf32;
	if (Klessydra_get_coreID()==1) perf32[1]=dsp_perf32;
	if (Klessydra_get_coreID()==2) perf32[2]=dsp_perf32;
	//------------------------------------------------------------------------------------------
	
	// Test 32-bit svmul result ----------------------------------------------------------------
	mult_pass = 0;
	if (Klessydra_get_coreID()==1)
	{
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<NumOfElements; i++)
		{
			testres32[i] = vect32_1[i]*scal32_2;
			//printf("\ntestres32: %x",testres32[i]);
			//printf("\nres32: %x",res32[2*i]);
		}
		__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[test_perf_i], mcycle, zero;"
			"sw %[test_perf_i], 0(%[test_ptr_perf]);"
			:
			:[test_perf_i] "r" (test_perf_i), [test_ptr_perf] "r" (test_ptr_perf)
			);
		testperf[2]=test_perf_i;
		for (int i=0; i<NumOfElements; i++)
		{
			if (res32[2*i]==testres32[i])  // Change if the multiplier max result width chnages in the future
			{
				mult_pass++;
			}
			else 
			{
				goto FAIL_VECT_SVMUL_32;
			}
		}
		if (mult_pass==NumOfElements)
		{
			printf("\nPASSED 32-bit svmul\n\n");
		}
	}
	// -----------------------------------------------------------------------------------------
	
	/************************************ 32-bit DOTP END *************************************/
	
	if (Klessydra_get_coreID()==1)
	{		
		printf("\nNumber of Elements: %d\n",NumOfElements);
		for(int i=0;i<3;i++)
		{
				printf("Th%d KSVMUL8  Speed: %d Cycles\n",i, perf8[i]);
		}
		for(int i=0;i<3;i++)
		{
				printf("Th%d KSVMUL16 Speed: %d Cycles\n",i, perf16[i]);
		}
		for(int i=0;i<3;i++)
		{
				printf("Th%d KSVMUL32 Speed: %d Cycles\n",i, perf32[i]);
		}
		for(int i=0;i<3;i++)
		{
				printf("SVMUL%d Speed: %d Cycles\n",8*(2^i), testperf[i]);
		}
		return 0;
	}	

	__asm__("csrrw zero, mstatus, 8;" "wfi;");
	return 0;

	FAIL_VECT_SVMUL_8: 
	printf("\nFAILED 8-bit  svmul");
	goto VECT_SVMUL_16;
	FAIL_VECT_SVMUL_16: 
	printf("\nFAILED 16-bit svmul");
	goto VECT_SVMUL_32;
	FAIL_VECT_SVMUL_32: 
	printf("\nFAILED 32-bit svmul\n\n");
 	return 1;
}

