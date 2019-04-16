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

int8_t  vect8_1[NumOfElements];
int16_t vect16_1[NumOfElements];
int32_t vect32_1[NumOfElements];
int8_t  scal8_2;
int16_t scal16_2;
int32_t scal32_2;
int8_t  testres8[NumOfElements];
int16_t testres16[NumOfElements];
int32_t testres32[NumOfElements];
int8_t  *res8;
int16_t *res16;
int32_t *res32;
int8_t  result8[NumOfElements];
int16_t result16[NumOfElements];
int32_t result32[NumOfElements];
int testpesc[NumOfThreads], pesc8[NumOfThreads], pesc16[NumOfThreads], pesc32[NumOfThreads];
int size8=NumOfElements*sizeof(char);
int size16=NumOfElements*sizeof(short);
int size32=NumOfElements*sizeof(int);


int main()
{
	srand (TIME);
	for (int i=0; i<NumOfElements; i++) 
	{ 
    	vect8_1[i]  = rand()  % (0x100 - 0x1) +1;
    	vect16_1[i] = rand()  % (0x10000 - 0x1) +1;
    	vect32_1[i] = rand()  % (0x80000000 - 0x1) +1;
	}

	scal8_2  = rand() % 255 +1;
	scal16_2 = rand() % 65536 +1;
	scal32_2 = rand() % (0x80000000 - 0x1);

	
	int dsp_pesc8  = 0;
	int dsp_pesc16 = 0;
	int dsp_pesc32 = 0;
	int test_pesc_i = 0;
	int* dsp_ptr_pesc8 = &dsp_pesc8;
	int* dsp_ptr_pesc16 = &dsp_pesc16;
	int* dsp_ptr_pesc32 = &dsp_pesc32;
	int* test_ptr_pesc = &test_pesc_i;

	int add_pass;
	/************************************ 8-bit SVADDSC Start ************************************/

	// ENABLE COUNTING -------------------------------------------------------------------------
	__asm__("csrrw zero, mcycle, zero;"
			"csrrw zero, 0x7A0, 0x00000001");
	//------------------------------------------------------------------------------------------
	
	// TEST KSVADDSC8 ----------------------------------------------------------------------------	
	res8=kless_scalar_vect_add_sc_8((void*) result8, (void*) vect8_1, (void*) &scal8_2,  size8);
	//------------------------------------------------------------------------------------------

	// DISABLE COUNTING AND SAVE MCYCLE OF EACH THREAD -----------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[dsp_pesc8], mcycle, zero;"
			"sw %[dsp_pesc8], 0(%[dsp_ptr_pesc8]);"
			:
			:[dsp_pesc8] "r" (dsp_pesc8), [dsp_ptr_pesc8] "r" (dsp_ptr_pesc8)
			);
	if (Klessydra_get_coreID()==0) {pesc8[0]=dsp_pesc8; } //printf("Speed: %d Cycles\n", pesc8[0]);}
	if (Klessydra_get_coreID()==1) {pesc8[1]=dsp_pesc8; } //printf("Speed: %d Cycles\n", pesc8[1]);}
	if (Klessydra_get_coreID()==2) {pesc8[2]=dsp_pesc8; } //printf("Speed: %d Cycles\n", pesc8[2]);}
	//------------------------------------------------------------------------------------------
	
	// Test 8-bit svadd result -----------------------------------------------------------------
	add_pass = 0;
	if (Klessydra_get_coreID()==1)
	{
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<NumOfElements; i++)
		{
			testres8[i] = vect8_1[i]+scal8_2;
		}
		__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[test_pesc_i], mcycle, zero;"
			"sw %[test_pesc_i], 0(%[test_ptr_pesc]);"
			:
			:[test_pesc_i] "r" (test_pesc_i), [test_ptr_pesc] "r" (test_ptr_pesc)
			);
		testpesc[0]=test_pesc_i;
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
				add_pass++;
			}
			else 
			{
				goto FAIL_VECT_SVADD_SC_8;
			}
		}
		if (add_pass==NumOfElements)
		{
			printf("\nPASSED KSVADDSC8  8-bit  scalar-vector addition");
		}
	}

	// -----------------------------------------------------------------------------------------
	
	/************************************ 8-bit SVADDSC END **************************************/

	/************************************ 16-bit SVADDSC Start ***********************************/
	VECT_SVADD_SC_16:
	add_pass = 0;
	
	// ENABLE COUNTING -------------------------------------------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000001");
	//------------------------------------------------------------------------------------------

	// TEST KSVADD16 ---------------------------------------------------------------------------
	res16=kless_scalar_vect_add_sc_16((void*) result16, (void*) vect16_1, (void*) &scal16_2, size16);
	//------------------------------------------------------------------------------------------
	// DISABLE COUNTING AND SAVE MCYCLE OF EACH THREAD ////////
	__asm__("csrrw zero, 0x7A0, 0x00000000;"
	    	"csrrw %[dsp_pesc16], mcycle, zero;"
			"sw %[dsp_pesc16], 0(%[dsp_ptr_pesc16]);"
			:
			:[dsp_pesc16] "r" (dsp_pesc16), [dsp_ptr_pesc16] "r" (dsp_ptr_pesc16)
			);
	if (Klessydra_get_coreID()==0) pesc16[0]=dsp_pesc16;
	if (Klessydra_get_coreID()==1) pesc16[1]=dsp_pesc16;
	if (Klessydra_get_coreID()==2) pesc16[2]=dsp_pesc16;
	//------------------------------------------------------------------------------------------
	
	// Test 16-bit svadd result ----------------------------------------------------------------
	if (Klessydra_get_coreID()==1)
	{
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<NumOfElements; i++)
		{
			testres16[i] = vect16_1[i]+scal16_2;
		}
		__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[test_pesc_i], mcycle, zero;"
			"sw %[test_pesc_i], 0(%[test_ptr_pesc]);"
			:
			:[test_pesc_i] "r" (test_pesc_i), [test_ptr_pesc] "r" (test_ptr_pesc)
			);
		testpesc[1]=test_pesc_i;
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
				add_pass++;
			}
			else 
			{
				goto FAIL_VECT_SVADD_SC_16;
			}
		}
		if (add_pass==NumOfElements)
		{
			printf("\nPASSED KSVADDSC16 16-bit scalar-vector addition");
		}
	}
	// -----------------------------------------------------------------------------------------

	/************************************ 16-bit SVADDSC END *************************************/		

	/************************************ 32-bit SVADDSC Start ***********************************/
	VECT_SVADD_SC_32:
	add_pass = 0;
	
	// ENABLE COUNTING -------------------------------------------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000001");
	//------------------------------------------------------------------------------------------
	
	// TEST KSVADDSC32 ---------------------------------------------------------------------------	
	res32=kless_scalar_vect_add_sc_32((void*) result32, (void*) vect32_1, (void*) &scal32_2, size32);
	//------------------------------------------------------------------------------------------
	
	// DISABLE COUNTING AND SAVE MCYCLE OF EACH THREAD -----------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000000;"
	    	"csrrw %[dsp_pesc32], mcycle, zero;"
			"sw %[dsp_pesc32], 0(%[dsp_ptr_pesc32]);"
			:
			:[dsp_pesc32] "r" (dsp_pesc32), [dsp_ptr_pesc32] "r" (dsp_ptr_pesc32)
			);
	if (Klessydra_get_coreID()==0) pesc32[0]=dsp_pesc32;
	if (Klessydra_get_coreID()==1) pesc32[1]=dsp_pesc32;
	if (Klessydra_get_coreID()==2) pesc32[2]=dsp_pesc32;
	//------------------------------------------------------------------------------------------
	
	// Test 32-bit svadd result ----------------------------------------------------------------
	add_pass = 0;
	if (Klessydra_get_coreID()==1)
	{
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<NumOfElements; i++)
		{
			testres32[i] = vect32_1[i]+scal32_2;
		}
		__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[test_pesc_i], mcycle, zero;"
			"sw %[test_pesc_i], 0(%[test_ptr_pesc]);"
			:
			:[test_pesc_i] "r" (test_pesc_i), [test_ptr_pesc] "r" (test_ptr_pesc)
			);
		testpesc[2]=test_pesc_i;
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
				add_pass++;
			}
			else 
			{
				goto FAIL_VECT_SVADD_SC_32;
			}
		}
		if (add_pass==NumOfElements)
		{
			printf("\nPASSED KSVADDSC32 32-bit scalar-vector addition\n\n");
		}
	}
	// -----------------------------------------------------------------------------------------
	
	/************************************ 32-bit SVADDSC END *************************************/
	
	if (Klessydra_get_coreID()==1)
	{		
		printf("\nNumber of Elements: %d\n",NumOfElements);
		for(int i=0;i<3;i++)
		{
				printf("Th%d KSVADDSC8  Speed: %d Cycles\n",i, pesc8[i]);
		}
		for(int i=0;i<3;i++)
		{
				printf("Th%d KSVADDSC16 Speed: %d Cycles\n",i, pesc16[i]);
		}
		for(int i=0;i<3;i++)
		{
				printf("Th%d KSVADDSC32 Speed: %d Cycles\n",i, pesc32[i]);
		}
		for(int i=0;i<3;i++)
		{
				printf("SVADDSC%d Speed: %d Cycles\n",8*(2^i), testpesc[i]);
		}
		return 0;
	}	

	__asm__("csrrw zero, mstatus, 8;" "wfi;");
	return 0;

	FAIL_VECT_SVADD_SC_8: 
	printf("\nFAILED KSVADDSC8  8-bit scalar-vector addition");
	goto VECT_SVADD_SC_16;
	FAIL_VECT_SVADD_SC_16: 
	printf("\nFAILED KSVADDSC16 16-bit scalar-vector addition");
	goto VECT_SVADD_SC_32;
	FAIL_VECT_SVADD_SC_32: 
	printf("\nFAILED KSVADDSC32 32-bit scalar-vector addition\n");
	if (Klessydra_get_coreID()==1)
	{		
		printf("\nNumber of Elements: %d\n\n",NumOfElements);
	}
 	return 1;
}

