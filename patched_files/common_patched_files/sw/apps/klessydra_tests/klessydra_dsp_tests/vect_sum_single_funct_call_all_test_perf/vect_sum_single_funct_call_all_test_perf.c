#include <stdio.h>
#include "dsp_functions.h"
#include "functions.h"
#include "klessydra_defs.h"

#define NumOfElements 10
#define NumOfThreads 3

unsigned char vect8_1[NumOfElements] = {0xFF, 0xEE, 0xDD, 0xCC, 0xBB, 0xAA, 0x99, 0x88};
unsigned char vect8_2[NumOfElements] = {0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11, 0x00};
unsigned short vect16_1[NumOfElements] = {0xFFFF, 0xEEEE, 0xDDDD, 0xCCCC, 0xBBBB, 0xAAAA, 0x9999, 0x8888};
unsigned short vect16_2[NumOfElements] = {0x7777, 0x6666, 0x5555, 0x4444, 0x3333, 0x2222, 0x1111, 0x0000};
unsigned int vect32_1[NumOfElements] = {0xFFFFFFFF, 0xEEEEEEEE, 0xDDDDDDDD, 0xCCCCCCCC, 0xBBBBBBBB, 0xAAAAAAAA, 0x99999999, 0x88888888};
unsigned int vect32_2[NumOfElements] = {0x77777777, 0x66666666, 0x55555555, 0x44444444, 0x33333333, 0x22222222, 0x11111111, 0x00000000};
unsigned char testres8[NumOfElements];
unsigned short testres16[NumOfElements];
unsigned int testres32[NumOfElements];
unsigned char  *res8;
unsigned short *res16;
unsigned int   *res32;
unsigned char result8[NumOfElements];
unsigned short result16[NumOfElements];
unsigned int result32[NumOfElements];
int size8=NumOfElements*sizeof(char);
int size16=NumOfElements*sizeof(short);
int size32=NumOfElements*sizeof(int);
int testperf[NumOfThreads], perf8[NumOfThreads], perf16[NumOfThreads], perf32[NumOfThreads];


int main()
{	
	int add_pass;
	int perf = 0;
	int* ptr_perf = &perf;

	/* 8-bit ADD here */
	
	// ENABLE COUNTING -------------------------------------------------------------------------
	__asm__("csrrw zero, mcycle, zero;"
			"csrrw zero, 0x7A0, 0x00000001");
	//------------------------------------------------------------------------------------------
	
	// TEST KADDV8 -----------------------------------------------------------------------------
	res8=kless_vector_addition_8((void*) result8, (void*) vect8_1, (void*) vect8_2,  size8);
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

	// Test 8-bit addition result
	add_pass = 0;
	if (Klessydra_get_coreID()==1)
	{
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<NumOfElements; i++)
		{
			testres8[i] = vect8_1[i]+vect8_2[i];
			//printf("\ntestres8(%d): %x", i, testres8[i]);
            //printf("\nres8(%d): %x", i, (unsigned char)res8[i]);
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
			if ((unsigned char)res8[i]==testres8[i])
			{
				add_pass++;
			}
			else 
			{
				goto FAIL_VECT_ADD_8;
			}
		}
		if (add_pass==NumOfElements)
		{
			printf("\nPASSED 8-bit  vector addition");
		}
	}

	/* 16-bit KADDV here */
	VECT_ADD_16:

	// ENABLE COUNTING -------------------------------------------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000001");
	//------------------------------------------------------------------------------------------

	// TEST KADDV16 ----------------------------------------------------------------------------
    res16=kless_vector_addition_16((void*) result16, (void*) vect16_1, (void*) vect16_2, size16);
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
	
	
	// Test 16-bit addition result
	add_pass = 0;
	if (Klessydra_get_coreID()==1)
	{
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<NumOfElements; i++)
		{
			testres16[i] = vect16_1[i]+vect16_2[i];
			//printf("\ntestres16(%d): %x", i, testres16[i]);
            //printf("\nres16(%d): %x", i, (unsigned short)res16[i]);
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
			if ((unsigned short)res16[i]==testres16[i])
			{
				add_pass++;
			}
			else 
			{
				goto FAIL_VECT_ADD_16;
			}
		}
		if (add_pass==NumOfElements)
		{
			printf("\nPASSED 16-bit vector addition");
		}
	}

	/* 32-bit KADDV here */
	VECT_ADD_32:
	
	
	// ENABLE COUNTING -------------------------------------------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000001");
	//------------------------------------------------------------------------------------------
	
	// TEST KADDV32 ----------------------------------------------------------------------------
	res32=kless_vector_addition_32((void*) result32, (void*) vect32_1, (void*) vect32_2, size32);
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

	// Test 32-bit addition result -------------------------------------------------------------
	add_pass = 0;
	if (Klessydra_get_coreID()==1){
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<NumOfElements; i++)
		{
			testres32[i] = vect32_1[i]+vect32_2[i];
			//printf("\ntestres32(%d): %x", i, (unsigned int)testres32[i]);
            //printf("\nres32(%d): %x", i, (unsigned int)res32[i]);
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
				add_pass++;
			}
			else 
			{
				goto FAIL_VECT_ADD_32;
			}
		}
		if (add_pass==NumOfElements)
		{
			printf("\nPASSED 32-bit vector addition");
		}
	
	}
	
	if (Klessydra_get_coreID()==1)
	{		
		printf("\n\nNumber of Elements:%d\n",NumOfElements);
		for(int i=0;i<3;i++)
		{
				printf("Th%d KADDV8  Speed: %d Cycles\n",i, perf8[i]);
		}
		for(int i=0;i<3;i++)
		{
				printf("Th%d KADDV16 Speed: %d Cycles\n",i, perf16[i]);
		}
		for(int i=0;i<3;i++)
		{
				printf("Th%d KADDV32 Speed: %d Cycles\n",i, perf32[i]);
		}
		for(int i=0;i<3;i++)
		{
				printf("ADDV%d Speed: %d Cycles\n",8*(2^i), testperf[i]);
		}
		return 0;
	}	

	__asm__("csrrw zero, mstatus, 8;" "wfi;");
	return 0;

	FAIL_VECT_ADD_8: 
	printf("\nFAILED 8-bit  vector addition");
	goto VECT_ADD_16;
	FAIL_VECT_ADD_16: 
	printf("\nFAILED 16-bit vector addition");
	goto VECT_ADD_32;
	FAIL_VECT_ADD_32: 
	printf("\nFAILED 32-bit vector addition\n\n");
        return 1;
}

