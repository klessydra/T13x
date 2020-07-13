#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
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
int8_t  vect8_2[NumOfElements];
int16_t vect16_1[NumOfElements];
int16_t vect16_2[NumOfElements];
int32_t vect32_1[NumOfElements];
int32_t vect32_2[NumOfElements];
int8_t  testres8[NumOfElements];
int16_t testres16[NumOfElements];
int32_t testres32[NumOfElements];
int8_t  *res8;
int16_t *res16;
int32_t *res32;
int8_t  result8[NumOfElements];
int16_t result16[NumOfElements];
int32_t result32[NumOfElements];
int   size8=NumOfElements*sizeof(char);
int   size16=NumOfElements*sizeof(short);
int   size32=NumOfElements*sizeof(int);
int   testperf[NumOfThreads], perf8[NumOfThreads], perf16[NumOfThreads], perf32[NumOfThreads];

int power(int a,int b);

int main()
{	

	srand (TIME);
	for (int i=0; i<NumOfElements; i++) 
	{ 
    	vect8_1[i]  = rand()  % (0x100 - 0x1) +1;
       	vect8_2[i]  = rand()  % (0x100 - 0x1) +1;
		vect16_1[i] = rand()  % (0x10000 - 0x1) +1;
		vect16_2[i] = rand()  % (0x10000 - 0x1) +1;
		vect32_1[i] = rand()  % (0x80000000 - 0x1) +1;
		vect32_2[i] = rand()  % (0x80000000 - 0x1) +1;
	}

	int sub_pass;
	int perf = 0;
	int* ptr_perf = &perf;

	/* 8-bit SUB here */
	CSR_MVTYPE(0);  // set data type to 8-bit

	// ENABLE COUNTING -------------------------------------------------------------------------
	__asm__("csrrw zero, mcycle, zero;"
			"csrrw zero, 0x7A0, 0x00000001");
	//------------------------------------------------------------------------------------------
	
	// TEST KSUBV8 -----------------------------------------------------------------------------
	res8=kless_vector_subtraction((void*) result8, (void*) vect8_1, (void*) vect8_2,  size8);
	//------------------------------------------------------------------------------------------

	// DISABLE COUNTING AND SAVE MCYCLE OF EACH THREAD -----------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[perf], mcycle, zero;"
			"sw %[perf], 0(%[ptr_perf]);"
			:
			:[perf] "r" (perf), [ptr_perf] "r" (ptr_perf)
			);
	if (Klessydra_get_coreID()==0) perf8[0]=perf;
	if (Klessydra_get_coreID()==1) perf8[1]=perf;
	if (Klessydra_get_coreID()==2) perf8[2]=perf;
	//------------------------------------------------------------------------------------------

	// Test 8-bit subtraction result
	sub_pass = 0;
	if (Klessydra_get_coreID()==1)
	{
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<NumOfElements; i++)
		{
			testres8[i] = vect8_1[i]-vect8_2[i];
		//	printf("\ntestres8(%d): %x", i, testres8[i]);
        //    printf("\nres8(%d): %x", i, res8[i]);
		}
		__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[perf], mcycle, zero;"
			"sw %[perf], 0(%[ptr_perf]);"
			:
			:[perf] "r" (perf), [ptr_perf] "r" (ptr_perf)
			);
        testperf[0]=perf;
		for (int i=0; i<NumOfElements; i++)
		{
			if (res8[i]==testres8[i])
			{
				sub_pass++;
			}
			else 
			{
				goto FAIL_VECT_SUB_8;
			}
		}
		if (sub_pass==NumOfElements)
		{
			printf("\nPASSED KSUBV8  8-bit vector subtraction");
		}
	}

	/* 16-bit KSUBV here */
	VECT_SUB_16:
	CSR_MVTYPE(1);  // set data type to 16-bit

	// ENABLE COUNTING -------------------------------------------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000001");
	//------------------------------------------------------------------------------------------

	// TEST KSUBV16 ----------------------------------------------------------------------------
    res16=kless_vector_subtraction((void*) result16, (void*) vect16_1, (void*) vect16_2, size16);
    //------------------------------------------------------------------------------------------
    
	// DISABLE COUNTING AND SAVE MCYCLE OF EACH THREAD -----------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000000;"
	    	"csrrw %[perf], mcycle, zero;"
			"sw %[perf], 0(%[ptr_perf]);"
			:
			:[perf] "r" (perf), [ptr_perf] "r" (ptr_perf)
			);
	if (Klessydra_get_coreID()==0) perf16[0]=perf;
	if (Klessydra_get_coreID()==1) perf16[1]=perf;
	if (Klessydra_get_coreID()==2) perf16[2]=perf;
	//------------------------------------------------------------------------------------------
	
	
	// Test 16-bit subtraction result
	sub_pass = 0;
	if (Klessydra_get_coreID()==1)
	{
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<NumOfElements; i++)
		{
			testres16[i] = vect16_1[i]-vect16_2[i];
		//	printf("\ntestres16(%d): %x", i, testres16[i]);
        //    printf("\nres16(%d): %x", i, res16[i]);
		}
		__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[perf], mcycle, zero;"
			"sw %[perf], 0(%[ptr_perf]);"
			:
			:[perf] "r" (perf), [ptr_perf] "r" (ptr_perf)
			);
        testperf[1]=perf;
		for (int i=0; i<NumOfElements; i++)
		{
			if (res16[i]==testres16[i])
			{
				sub_pass++;
			}
			else 
			{
				goto FAIL_VECT_SUB_16;
			}
		}
		if (sub_pass==NumOfElements)
		{
			printf("\nPASSED KSUBV16 16-bit vector subtraction");
		}
	}

	/* 32-bit KSUBV here */
	VECT_SUB_32:
	CSR_MVTYPE(2);  // set data type to 32-bit

	
	// ENABLE COUNTING -------------------------------------------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000001");
	//------------------------------------------------------------------------------------------
	
	// TEST KSUBV32 ----------------------------------------------------------------------------
	res32=kless_vector_subtraction((void*) result32, (void*) vect32_1, (void*) vect32_2, size32);
	//------------------------------------------------------------------------------------------
	
	// DISABLE COUNTING AND SAVE MCYCLE OF EACH THREAD -----------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[perf], mcycle, zero;"
			"sw %[perf], 0(%[ptr_perf]);"
			:
			:[perf] "r" (perf), [ptr_perf] "r" (ptr_perf)
			);
	if (Klessydra_get_coreID()==0) perf32[0]=perf;
	if (Klessydra_get_coreID()==1) perf32[1]=perf;
	if (Klessydra_get_coreID()==2) perf32[2]=perf;
	//------------------------------------------------------------------------------------------

	// Test 32-bit subtraction result -------------------------------------------------------------
	sub_pass = 0;
	if (Klessydra_get_coreID()==1){
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<NumOfElements; i++)
		{
			testres32[i] = vect32_1[i]-vect32_2[i];
		//	printf("\ntestres32(%d): %x", i, testres32[i]);
        //    printf("\nres32(%d): %x", i, res32[i]);
		}
		__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[perf], mcycle, zero;"
			"sw %[perf], 0(%[ptr_perf]);"
			:
			:[perf] "r" (perf), [ptr_perf] "r" (ptr_perf)
			);
		testperf[2]=perf;
		for (int i=0; i<NumOfElements; i++)
		{
			if (res32[i]==testres32[i])
			{
				sub_pass++;
			}
			else 
			{
				goto FAIL_VECT_SUB_32;
			}
		}
		if (sub_pass==NumOfElements)
		{
			printf("\nPASSED KSUBV32 32-bit vector subtraction");
		}
	
	}
	
	if (Klessydra_get_coreID()==1)
	{		
		printf("\n\nNumber of Elements:%d\n",NumOfElements);
		for(int i=0;i<3;i++)
		{
				printf("Th%d KSUBV8  Speed: %d Cycles\n",i, perf8[i]);
		}
		for(int i=0;i<3;i++)
		{
				printf("Th%d KSUBV16 Speed: %d Cycles\n",i, perf16[i]);
		}
		for(int i=0;i<3;i++)
		{
				printf("Th%d KSUBV32 Speed: %d Cycles\n",i, perf32[i]);
		}
		for(int i=0;i<3;i++)
		{
				printf("SUBV%d Speed: %d Cycles\n",8*power(2,i), testperf[i]);
		}
		return 0;
	}	

	__asm__("csrrw zero, mstatus, 8;" "wfi;");
	return 0;

	FAIL_VECT_SUB_8: 
	printf("\nFAILED KSUBV8  8-bit  vector subtraction");
	goto VECT_SUB_16;
	FAIL_VECT_SUB_16: 
	printf("\nFAILED KSUBV16 16-bit vector subtraction");
	goto VECT_SUB_32;
	FAIL_VECT_SUB_32: 
	printf("\nFAILED KSUBV32 32-bit vector subtraction\n");
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
