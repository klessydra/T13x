#include <stdio.h>
#include <stdint.h>
#include "dsp_functions.h"
#include "functions.h"
#include "klessydra_defs.h"

#define NumOfThreads 3
#define NumOfElements 17
#define scalar_size 4 

unsigned char vect8_1[NumOfElements] = {0xFF, 0xEE, 0xDD, 0xCC, 0xBB, 0xAA, 0x99, 0x88, 0xFF, 0xEE, 0xDD, 0xCC, 0xBB, 0xAA, 0x99, 0x88, 0xff};
unsigned char vect8_2[NumOfElements] = {0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11, 0x00, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11, 0x00, 0xcc};
unsigned short vect16_1[NumOfElements] = {0xFFFF, 0xEEEE, 0xDDDD, 0xCCCC, 0xBBBB, 0xAAAA, 0x9999, 0x8888, 0xFFFF, 0xEEEE, 0xDDDD, 0xCCCC, 0xBBBB, 0xAAAA, 0x9999, 0x8888};
unsigned short vect16_2[NumOfElements] = {0x7777, 0x6666, 0x5555, 0x4444, 0x3333, 0x2222, 0x1111, 0x0000, 0x7777, 0x6666, 0x5555, 0x4444, 0x3333, 0x2222, 0x1111, 0x0000};
unsigned int vect32_1[NumOfElements] = {0xFFFFFFFF, 0xEEEEEEEE, 0xDDDDDDDD, 0xCCCCCCCC, 0xBBBBBBBB, 0xAAAAAAAA, 0x99999999, 0x88888888, 0xFFFFFFFF, 0xEEEEEEEE, 0xDDDDDDDD, 0xCCCCCCCC, 0xBBBBBBBB, 0xAAAAAAAA, 0x99999999, 0x88888888};
unsigned int vect32_2[NumOfElements] = {0x77777777, 0x66666666, 0x55555555, 0x44444444, 0x33333333, 0x22222222, 0x11111111, 0x00000000, 0x77777777, 0x66666666, 0x55555555, 0x44444444, 0x33333333, 0x22222222, 0x11111111, 0x00000000};
int testres8, testres16, testres32;
int *res8, *res16, *res32;
int result8[scalar_size], result16[scalar_size], result32[scalar_size];
int size8=NumOfElements*sizeof(char);
int size16=NumOfElements*sizeof(short);
int size32=NumOfElements*sizeof(int);
int testperf[NumOfThreads], perf8[NumOfThreads], perf16[NumOfThreads], perf32[NumOfThreads];

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

	/************************************ 8-bit DOTP Start *************************************/
	testres8 = 0;
	
	
	// ENABLE COUNTING -------------------------------------------------------------------------
	__asm__("csrrw zero, mcycle, zero;"
			"csrrw zero, 0x7A0, 0x00000001");
	//------------------------------------------------------------------------------------------
	
	// TEST KDOTP8 -----------------------------------------------------------------------------	
    res8=kless_dot_product_8((void*) result8, (void*) vect8_1, (void*) vect8_2,  size8);
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

	// Test 8-bit dot-product result -----------------------------------------------------------
	if (Klessydra_get_coreID()==1)
	{
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<NumOfElements; i++)
		{
			testres8 += (char)vect8_1[i]*(char)vect8_2[i];     

		}
		__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[test_perf_i], mcycle, zero;"
			"sw %[test_perf_i], 0(%[test_ptr_perf]);"
			:
			:[test_perf_i] "r" (test_perf_i), [test_ptr_perf] "r" (test_ptr_perf)
			);
		testperf[0]=test_perf_i;
		if (*res8==testres8)
		{
			printf("\nPASSED 8-bit  vector dot product");
		}
		else 
		{
			goto FAIL_VECT_DOTP_8;
		}
	}
	// -----------------------------------------------------------------------------------------
	
	/************************************ 8-bit DOTP END ***************************************/

	/************************************ 16-bit DOTP Start ************************************/
	VECT_DOTP_16:
	testres16 = 0;
	
	// ENABLE COUNTING -------------------------------------------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000001");
	//------------------------------------------------------------------------------------------

	// TEST KDOTP16 ----------------------------------------------------------------------------	
	res16=kless_dot_product_16((void*) result16, (void*) vect16_1, (void*) vect16_2, size16);
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

	// Test 16-bit dot-product result ----------------------------------------------------------
	if (Klessydra_get_coreID()==1)
	{
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<NumOfElements; i++)
		{
			testres16 += vect16_1[i]*vect16_2[i];     

		}
		__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[test_perf_i], mcycle, zero;"
			"sw %[test_perf_i], 0(%[test_ptr_perf]);"
			:
			:[test_perf_i] "r" (test_perf_i), [test_ptr_perf] "r" (test_ptr_perf)
			);
		testperf[1]=test_perf_i;
		if (*res16==testres16)
		{
			printf("\nPASSED 16-bit vector dot product");
		}
		else 
		{
			goto FAIL_VECT_DOTP_16;
		}
	}
	// -----------------------------------------------------------------------------------------

	/************************************ 16-bit DOTP END **************************************/		

	/************************************ 32-bit DOTP Start ************************************/
	VECT_DOTP_32:
	testres32 = 0;
	
	// ENABLE COUNTING -------------------------------------------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000001");
	//------------------------------------------------------------------------------------------
	
	// TEST KDOTP32 ----------------------------------------------------------------------------	
	res32=kless_dot_product_32((int*) result32, (void*) vect32_1, (void*) vect32_2, size32);
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
	
	// Test 32-bit dot-product result ----------------------------------------------------------
	if (Klessydra_get_coreID()==1)
	{
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<NumOfElements; i++)
		{
			testres32 += vect32_1[i]*vect32_2[i];     

		}
		__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[test_perf_i], mcycle, zero;"
			"sw %[test_perf_i], 0(%[test_ptr_perf]);"
			:
			:[test_perf_i] "r" (test_perf_i), [test_ptr_perf] "r" (test_ptr_perf)
			);
		testperf[2]=test_perf_i;
		if (*res32==testres32)
		{
			printf("\nPASSED 32-bit vector dot product\n\n");
		}
		else 
		{
			goto FAIL_VECT_DOTP_32;
		}
	}
	// -----------------------------------------------------------------------------------------
	
	/************************************ 32-bit DOTP END *************************************/
	
	if (Klessydra_get_coreID()==1)
	{		
		printf("\nNumber of Elements: %d\n",NumOfElements);
		for(int i=0;i<3;i++)
		{
				printf("Th%d KDOTP8  Speed: %d Cycles\n",i, perf8[i]);
		}
		for(int i=0;i<3;i++)
		{
				printf("Th%d KDOTP16 Speed: %d Cycles\n",i, perf16[i]);
		}
		for(int i=0;i<3;i++)
		{
				printf("Th%d KDOTP32 Speed: %d Cycles\n",i, perf32[i]);
		}
		for(int i=0;i<3;i++)
		{
				printf("DOTP%d Speed: %d Cycles\n",8*(2^i), testperf[i]);
		}
		return 0;
	}	

	__asm__("csrrw zero, mstatus, 8;" "wfi;");
	return 0;

	FAIL_VECT_DOTP_8: 
	printf("\nFAILED 8-bit  vector dot product");
	goto VECT_DOTP_16;
	FAIL_VECT_DOTP_16: 
	printf("\nFAILED 16-bit vector dot product");
	goto VECT_DOTP_32;
	FAIL_VECT_DOTP_32: 
	printf("\nFAILED 32-bit vector dot product\n\n");
    return 1;
}


