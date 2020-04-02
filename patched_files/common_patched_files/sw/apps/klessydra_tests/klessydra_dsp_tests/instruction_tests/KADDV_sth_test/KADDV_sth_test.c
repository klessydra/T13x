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

#ifndef SIMD
	#define SIMD 4
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
int8_t  *res8[NumOfThreads];
int8_t  *res8_sw_loop[NumOfThreads];
int16_t *res16[NumOfThreads];
int16_t *res16_sw_loop[NumOfThreads];
int32_t *res32[NumOfThreads];
int32_t *res32_sw_loop[NumOfThreads];
int8_t  result8[NumOfThreads][NumOfElements];
int8_t  result8_sw_loop[NumOfThreads][NumOfElements];
int16_t result16[NumOfThreads][NumOfElements];
int16_t result16_sw_loop[NumOfThreads][NumOfElements];
int32_t result32[NumOfThreads][NumOfElements];
int32_t result32_sw_loop[NumOfThreads][NumOfElements];
int   size8=NumOfElements*sizeof(char);
int   size16=NumOfElements*sizeof(short);
int   size32=NumOfElements*sizeof(int);
int   testperf[NumOfThreads], perf8[NumOfThreads], perf16[NumOfThreads], perf32[NumOfThreads];
int   SIMD_BYTES = SIMD*4;

int power(int a,int b);


int main()
{	

	sync_barrier_reset();
	sync_barrier_thread_registration();
	
	srand(TIME);

	if (Klessydra_get_coreID()==1)
	{
		for (int i=0; i<NumOfElements; i++) 
		{ 
			vect8_1[i]  = rand()  % (0x100 - 0x1) +1;
			vect8_2[i]  = rand()  % (0x100 - 0x1) +1;
		}
		for (int i=0; i<NumOfThreads; i++) 
		{ 
			//res8[i] = &(result8[i][0]) + (i*size8 - ((i*size8)%4)) + 4*i;  //this way we avoid getting misaligned values
            //res8_sw_loop[i] = &(result8_sw_loop[i][0]) + (i*size8 - ((i*size8)%4)) + 4*i;
			res8[i]= &(result8[0][0]) + i*size8;
			res8_sw_loop[i]= &(result8_sw_loop[0][0]) + i*size8;
		}
	}

	else if (Klessydra_get_coreID()==1)
	{
		for (int i=0; i<NumOfElements; i++) 
		{ 
			vect16_1[i] = rand()  % (0x10000 - 0x1) +1;
			vect16_2[i] = rand()  % (0x10000 - 0x1) +1;
		}
		for (int i=0; i<NumOfThreads; i++) 
		{ 
			res16[i]= &(result16[0][0]) + i*size16;
			res16_sw_loop[i]= &(result16_sw_loop[0][0]) + i*size16;
		}
	}

	else if (Klessydra_get_coreID()==1)
	{
		for (int i=0; i<NumOfElements; i++) 
		{
			vect32_1[i] = rand()  % (0x80000000 - 0x1) +1;
			vect32_2[i] = rand()  % (0x80000000 - 0x1) +1;
		}
		for (int i=0; i<NumOfThreads; i++) 
		{
			res32[i]= &(result32[0][0]) + i*size32;
			res32_sw_loop[i]= &(result32_sw_loop[0][0]) + i*size32;
		}
	}

	int add_pass;
	int perf = 0;
	int* ptr_perf = &perf;
	
	sync_barrier();
	/* 8-bit KADDV here */
	CSR_MVTYPE(0);  // set data type to 8-bit

	// TEST KADDV8 -----------------------------------------------------------------------------
	sync_barrier_thread_registration();
	for(int i=0;i<NumOfThreads;i++)
	{
		if (Klessydra_get_coreID()==i)
		{
			// ENABLE COUNTING -------------------------------------------------------------------------
			__asm__("csrrw zero, mcycle, zero;"
				"csrrw zero, 0x7A0, 0x00000001");
			//------------------------------------------------------------------------------------------
			//if (Klessydra_get_coreID()==0) printf("\nres8[i]=%x",res8[i]);
			kless_vector_addition_sth(res8[i], (void*) vect8_1, (void*) vect8_2,  size8);
			// DISABLE COUNTING AND SAVE MCYCLE OF EACH THREAD -----------------------------------------
			__asm__("csrrw zero, 0x7A0, 0x00000000;"
				"csrrw %[perf], mcycle, zero;"
				"sw %[perf], 0(%[ptr_perf]);"
				:
				:[perf] "r" (perf), [ptr_perf] "r" (ptr_perf)
				);
			//------------------------------------------------------------------------------------------
		}
	}
	sync_barrier();
	//------------------------------------------------------------------------------------------
	sync_barrier_thread_registration();
	if (Klessydra_get_coreID()==0) perf8[0]=perf;
	if (Klessydra_get_coreID()==1) perf8[1]=perf;
	if (Klessydra_get_coreID()==2) perf8[2]=perf;
	// Test 8-bit addition result
	add_pass = 0;
	if (Klessydra_get_coreID()==1)
	{
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<NumOfElements; i++)
		{
			testres8[i] = vect8_1[i]+vect8_2[i];
		}
		__asm__("csrrw zero, 0x7A0, 0x00000000;"
				"csrrw %[perf], mcycle, zero;"
				"sw %[perf], 0(%[ptr_perf]);"
			:
			:[perf] "r" (perf), [ptr_perf] "r" (ptr_perf)
			);
        testperf[0]=perf;
		/*for (int i=0; i<NumOfElements; i++)
		{
			printf("\ntestres8(%d): %x", i, testres8[i]);
            printf("\nres8(%d): %x", i, res8[i]);
		}*/
		for (int i=0; i<NumOfThreads; i++)
		{
			for (int j=0; j<NumOfElements; j++)
			{
				if (*(res8[i]+j)==testres8[j])
				{
					add_pass++;
				}
			}
		}
		if (add_pass==NumOfThreads*NumOfElements)
		{
			printf("PASSED KADDV8  8-bit  vector addition\n");
		}
		else 	
		{
			printf("FAILED KADDV8  8-bit  vector addition\n");
		}
	}	
	
	if (Klessydra_get_coreID()==1)
	{		
		for(int i=0;i<3;i++)
		{
				printf("Th%d KADDV8  Speed: %d Cycles\n",i, perf8[i]);
		}
	}	
	sync_barrier();
	
	
	
		
	// TEST KADDV8 SW_LOOPS---------------------------------------------------------------------
	sync_barrier_thread_registration();
	for(int i=0;i<NumOfThreads;i++)
	{
		if (Klessydra_get_coreID()==i)
		{
			// ENABLE COUNTING -------------------------------------------------------------------------
			__asm__("csrrw zero, mcycle, zero;"
				"csrrw zero, 0x7A0, 0x00000001");
			//------------------------------------------------------------------------------------------
			kless_vector_addition_sth_sw_loop(res8_sw_loop[i], (void*) vect8_1, (void*) vect8_2,  size8, SIMD_BYTES);
			// DISABLE COUNTING AND SAVE MCYCLE OF EACH THREAD -----------------------------------------
			__asm__("csrrw zero, 0x7A0, 0x00000000;"
				"csrrw %[perf], mcycle, zero;"
				"sw %[perf], 0(%[ptr_perf]);"
				:
				:[perf] "r" (perf), [ptr_perf] "r" (ptr_perf)
				);
			//------------------------------------------------------------------------------------------
		}
	}
	sync_barrier();
	//------------------------------------------------------------------------------------------
	sync_barrier_thread_registration();
	if (Klessydra_get_coreID()==0) perf8[0]=perf;
	if (Klessydra_get_coreID()==1) perf8[1]=perf;
	if (Klessydra_get_coreID()==2) perf8[2]=perf;
	// Test 8-bit addition result
	add_pass = 0;
	if (Klessydra_get_coreID()==1)
	{
		for (int i=0; i<NumOfThreads; i++)
		{
			for (int j=0; j<NumOfElements; j++)
			{
				if (*(res8_sw_loop[i]+j)==testres8[j])
				{
					add_pass++;
				}
			}
		}
		if (add_pass==NumOfThreads*NumOfElements)
		{
			printf("PASSED KADDV8  8-bit  vector addition in sw loop\n");
		}
		else
		{
			printf("FAILED KADDV8  8-bit  vector addition in sw loop\n");
		}
	}
	if (Klessydra_get_coreID()==1)
	{		
		for(int i=0;i<3;i++)
		{
			printf("Th%d KADDV8 sw_loop  Speed: %d Cycles\n",i, perf8[i]);
		}
	}	
	sync_barrier();


	/* 16-bit KADDV here */
	CSR_MVTYPE(1);  // set data type to 16-bit

	sync_barrier_thread_registration();
	//------------------------------------------------------------------------------------------
	// TEST KADDV16 ----------------------------------------------------------------------------
	for(int i=0;i<NumOfThreads;i++)
	{
		if (Klessydra_get_coreID()==i)
		{
			// ENABLE COUNTING -------------------------------------------------------------------------
			__asm__("csrrw zero, 0x7A0, 0x00000001");
			kless_vector_addition_sth(result16[i], (void*) vect16_1, (void*) vect16_2, size16);
			// DISABLE COUNTING AND SAVE MCYCLE OF EACH THREAD -----------------------------------------
			__asm__("csrrw zero, 0x7A0, 0x00000000;"
					"csrrw %[perf], mcycle, zero;"
					"sw %[perf], 0(%[ptr_perf]);"
					:
					:[perf] "r" (perf), [ptr_perf] "r" (ptr_perf)
					);
		}
	}
	if (Klessydra_get_coreID()==0) perf16[0]=perf;
	if (Klessydra_get_coreID()==1) perf16[1]=perf;
	if (Klessydra_get_coreID()==2) perf16[2]=perf;
	sync_barrier();
	//------------------------------------------------------------------------------------------
	sync_barrier_thread_registration();
	// Test 16-bit addition result
	add_pass = 0;
	if (Klessydra_get_coreID()==1)
	{
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<NumOfElements; i++)
		{
			testres16[i] = vect16_1[i]+vect16_2[i];
		}
		__asm__("csrrw zero, 0x7A0, 0x00000000;"
				"csrrw %[perf], mcycle, zero;"
				"sw %[perf], 0(%[ptr_perf]);"
			:
			:[perf] "r" (perf), [ptr_perf] "r" (ptr_perf)
			);
        testperf[1]=perf;
		for (int i=0; i<NumOfThreads; i++)
		{
			for (int j=0; j<NumOfElements; j++)
			{
				if (result16[i][j]==testres16[j])
				{
					add_pass++;
				}
			}
		}
		if (add_pass==NumOfThreads*NumOfElements)
		{
			printf("PASSED KADDV16 16-bit vector addition\n");
		}
		else
		{
			printf("\nFAILED KADDV16 16-bit vector addition\n");
		}
	}
	if (Klessydra_get_coreID()==1)
	{		
		for(int i=0;i<3;i++)
		{
				printf("Th%d KADDV16  Speed: %d Cycles\n",i, perf16[i]);
		}
	}	
	sync_barrier();
	// TEST KADDV16 SW_LOOPS---------------------------------------------------------------------

	sync_barrier_thread_registration();
	for(int i=0;i<NumOfThreads;i++)
	{
		if (Klessydra_get_coreID()==i)
		{
			// ENABLE COUNTING -------------------------------------------------------------------------
			__asm__("csrrw zero, mcycle, zero;"
				"csrrw zero, 0x7A0, 0x00000001");
			//------------------------------------------------------------------------------------------
			kless_vector_addition_sth_sw_loop(result16_sw_loop[i], (void*) vect16_1, (void*) vect16_2,  size16, SIMD_BYTES);
			// DISABLE COUNTING AND SAVE MCYCLE OF EACH THREAD -----------------------------------------
			__asm__("csrrw zero, 0x7A0, 0x00000000;"
				"csrrw %[perf], mcycle, zero;"
				"sw %[perf], 0(%[ptr_perf]);"
				:
				:[perf] "r" (perf), [ptr_perf] "r" (ptr_perf)
				);
			//------------------------------------------------------------------------------------------
		}
	}
	if (Klessydra_get_coreID()==0) perf16[0]=perf;
	if (Klessydra_get_coreID()==1) perf16[1]=perf;
	if (Klessydra_get_coreID()==2) perf16[2]=perf;
	sync_barrier();
	//------------------------------------------------------------------------------------------
	sync_barrier_thread_registration();
	// Test 16-bit addition result
	add_pass = 0;
	if (Klessydra_get_coreID()==1)
	{
		for (int i=0; i<NumOfThreads; i++)
		{
			for (int j=0; j<NumOfElements; j++)
			{
				if (result16_sw_loop[i][j]==testres16[j])
				{
					add_pass++;
				}
			}
		}
		if (add_pass==NumOfThreads*NumOfElements)
		{
			printf("PASSED KADDV16  16-bit  vector addition in sw loop\n");
		}
		else
		{
			printf("FAILED KADDV16  16-bit  vector addition in sw loop\n");
		}
	}
	if (Klessydra_get_coreID()==1)
	{
		for(int i=0;i<3;i++)
		{
				printf("Th%d KADDV16 sw_loop  Speed: %d Cycles\n",i, perf16[i]);
		}
	}	
	sync_barrier();

	/* 32-bit KADDV here */
	CSR_MVTYPE(2);  // set data type to 32-bit

	sync_barrier_thread_registration();
	// TEST KADDV32 ----------------------------------------------------------------------------
	for(int i=0;i<NumOfThreads;i++)
	{
		if (Klessydra_get_coreID()==i)
		{
			// ENABLE COUNTING -------------------------------------------------------------------------
			__asm__("csrrw zero, mcycle, zero;"
				"csrrw zero, 0x7A0, 0x00000001");
			//------------------------------------------------------------------------------------------
			kless_vector_addition_sth(result32[i], (void*) vect32_1, (void*) vect32_2, size32);
			// DISABLE COUNTING AND SAVE MCYCLE OF EACH THREAD -----------------------------------------
			__asm__("csrrw zero, 0x7A0, 0x00000000;"
				"csrrw %[perf], mcycle, zero;"
				"sw %[perf], 0(%[ptr_perf]);"
				:
				:[perf] "r" (perf), [ptr_perf] "r" (ptr_perf)
				);
			//------------------------------------------------------------------------------------------
		}
	}
	if (Klessydra_get_coreID()==0) perf32[0]=perf;
	if (Klessydra_get_coreID()==1) perf32[1]=perf;
	if (Klessydra_get_coreID()==2) perf32[2]=perf;
	sync_barrier();
	//------------------------------------------------------------------------------------------
	sync_barrier_thread_registration();
	// Test 32-bit addition result -------------------------------------------------------------
	add_pass = 0;
	if (Klessydra_get_coreID()==1)
	{
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<NumOfElements; i++)
		{
			testres32[i] = vect32_1[i]+vect32_2[i];
		}
		__asm__("csrrw zero, 0x7A0, 0x00000000;"
				"csrrw %[perf], mcycle, zero;"
				"sw %[perf], 0(%[ptr_perf]);"
			:
			:[perf] "r" (perf), [ptr_perf] "r" (ptr_perf)
			);
        testperf[2]=perf;
		for (int i=0; i<NumOfThreads; i++)
		{
			for (int j=0; j<NumOfElements; j++)
			{
				if (result32[i][j]==testres32[j])
				{
					add_pass++;
				}
			}
		}
		if (add_pass==NumOfThreads*NumOfElements)
		{
			printf("PASSED KADDV32 32-bit vector addition\n");
		}
		else
		{
			printf("\nFAILED KADDV32 32-bit vector addition\n");
		}
	}
	if (Klessydra_get_coreID()==1)
	{		
		for(int i=0;i<3;i++)
		{
				printf("Th%d KADDV32  Speed: %d Cycles\n",i, perf32[i]);
		}
	}	
	sync_barrier();

	//------------------------------------------------------------------------------------------
	
	sync_barrier_thread_registration();
	// TEST KADDV32 SW_LOOP----------------------------------------------------------------------
	for(int i=0;i<NumOfThreads;i++)
	{
		if (Klessydra_get_coreID()==i)
		{
			// ENABLE COUNTING -------------------------------------------------------------------------
			__asm__("csrrw zero, mcycle, zero;"
				"csrrw zero, 0x7A0, 0x00000001");
			//------------------------------------------------------------------------------------------

			kless_vector_addition_sth_sw_loop(res32_sw_loop[i], (void*) vect32_1, (void*) vect32_2, size32, SIMD_BYTES);

			// DISABLE COUNTING AND SAVE MCYCLE OF EACH THREAD -----------------------------------------
			__asm__("csrrw zero, 0x7A0, 0x00000000;"
				"csrrw %[perf], mcycle, zero;"
				"sw %[perf], 0(%[ptr_perf]);"
				:
				:[perf] "r" (perf), [ptr_perf] "r" (ptr_perf)
				);
			//------------------------------------------------------------------------------------------
		}
	}
	if (Klessydra_get_coreID()==0) perf32[0]=perf;
	if (Klessydra_get_coreID()==1) perf32[1]=perf;
	if (Klessydra_get_coreID()==2) perf32[2]=perf;
	sync_barrier();
	//------------------------------------------------------------------------------------------
	sync_barrier_thread_registration();
	// Test 32-bit addition result -------------------------------------------------------------
	add_pass = 0;
	if (Klessydra_get_coreID()==1)
	{
		for (int i=0; i<NumOfThreads; i++)
		{
			for (int j=0; j<NumOfElements; j++)
			{
				if (*(res32_sw_loop[i]+j)==testres32[j])
				{
					add_pass++;
				}
			}
		}
		if (add_pass==NumOfThreads*NumOfElements)
		{
			printf("PASSED KADDV32 32-bit vector addition in sw loop\n");
		}
		else
		{
			printf("\nFAILED KADDV32 32-bit vector addition in sw loop\n");
		}
	}
	if (Klessydra_get_coreID()==1)
	{
		for(int i=0;i<3;i++)
		{
				printf("Th%d KADDV32  Speed: %d Cycles\n",i, perf32[i]);
		}
	}
	sync_barrier();

	//------------------------------------------------------------------------------------------
	if (Klessydra_get_coreID()==1)
	{
		printf("\n\nNumber of Elements:%d\n",NumOfElements);
		/*
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
		*/
		for(int i=0;i<3;i++)
		{
				printf("ADDV%d Speed: %d Cycles\n", 8*power(2,i), testperf[i]);
		}
		return 0;
	}

	__asm__("csrrw zero, mstatus, 8;" "wfi;");
	return 0;

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
