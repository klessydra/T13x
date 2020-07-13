#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
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
int8_t  vect8_2[NumOfElements];
int16_t vect16_1[NumOfElements];
int16_t vect16_2[NumOfElements];
int32_t vect32_1[NumOfElements];
int32_t vect32_2[NumOfElements];
int8_t  testres8;
int16_t testres16;
int8_t  testres8_int[NumOfElements];
int16_t testres16_int[NumOfElements];
int32_t testres32;
int8_t  *res8;
int16_t *res16;
int32_t *res32;
int result8[NumOfThreads][scalar_size];
int result16[NumOfElements][scalar_size];
int result32[NumOfElements][scalar_size];
int size8=NumOfElements*sizeof(char);
int size16=NumOfElements*sizeof(short);
int size32=NumOfElements*sizeof(int);
int testperf[NumOfThreads], perf8[NumOfThreads], perf16[NumOfThreads], perf32[NumOfThreads];
int p_scal8, p_scal16, p_scal32;

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
	p_scal8  = 2;
	p_scal16 = 4;
	p_scal32 = 15;

	int kdotpps = 0;
	int dsp_perf8  = 0;
	int dsp_perf16 = 0;
	int dsp_perf32 = 0;
	int test_perf_i = 0;
	int* dsp_ptr_perf8  = &dsp_perf8;
	int* dsp_ptr_perf16 = &dsp_perf16;
	int* dsp_ptr_perf32 = &dsp_perf32;
	int* test_ptr_perf  = &test_perf_i;
	
	if (Klessydra_get_coreID()==1)
	{
		for(int i=0;i<NumOfThreads;i++)
		{
			res8[i]=  &(result8[i][0])  + i*scalar_size;
			res16[i]= &(result16[i][0]) + i*scalar_size;
			res32[i]= &(result32[i][0]) + i*scalar_size;
		}
	}
	
	sync_barrier_reset();
	sync_barrier_thread_registration();
	sync_barrier();

	/************************************ 8-bit DOTPPS Start *************************************/
	testres8 = 0;
	CSR_MVTYPE(0);  // set data type to 8-bit

	// ENABLE COUNTING ---------------------------------------------------------------------------
	__asm__("csrrw zero, mcycle, zero;"
			"csrrw zero, 0x7A0, 0x00000001");
	//--------------------------------------------------------------------------------------------

	// TEST KDOTPPS8 -----------------------------------------------------------------------------
    res8=kless_post_scal_dot_product((void*) result8, (void*) vect8_1, (void*) vect8_2, (void*) p_scal8, size8);
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
			testres8_int[i] = (vect8_1[i]*vect8_2[i]);   
			testres8 += ((testres8_int[i]) >> p_scal8);  
		}
		__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[test_perf_i], mcycle, zero;"
			"sw %[test_perf_i], 0(%[test_ptr_perf]);"
			:
			:[test_perf_i] "r" (test_perf_i), [test_ptr_perf] "r" (test_ptr_perf)
			);
		testperf[0]=test_perf_i;
		//printf("\ntestres8: %x",testres8);
		//printf("\nres8: %x",*res8);
		for(int i=0;i<NumOfThreads;i++)
		{
			if (*(res8)==testres8)
			{
				kdotpps++;
			}
			else 
			{
				goto FAIL_VECT_DOTPPS_8;
			}
		}
		if (kdotpps==NumOfThreads)
		{
			printf("\nPASSED KDOTPPS8  8-bit  post scaling vector dot product");
		}
	}
	// -----------------------------------------------------------------------------------------
	
	/************************************ 8-bit DOTPPS END ***************************************/

	/************************************ 16-bit DOTPPS Start ************************************/
	VECT_DOTPPS_16:
	CSR_MVTYPE(1);  // set data type to 16-bit

	testres16 = 0;
	
	// ENABLE COUNTING -------------------------------------------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000001");
	//------------------------------------------------------------------------------------------

	// TEST KDOTPPS16 --------------------------------------------------------------------------
	res16=kless_post_scal_dot_product((void*) result16, (void*) vect16_1, (void*) vect16_2, (void*) p_scal16, size16);
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
			testres16_int[i] = (vect16_1[i]*vect16_2[i]);   
			testres16 += ((testres16_int[i]) >> p_scal16);       
		}
		__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[test_perf_i], mcycle, zero;"
			"sw %[test_perf_i], 0(%[test_ptr_perf]);"
			:
			:[test_perf_i] "r" (test_perf_i), [test_ptr_perf] "r" (test_ptr_perf)
			);
		testperf[1]=test_perf_i;
		//printf("\ntestres16: %x",testres16);
		//printf("\nres16: %x",*res16);
		kdotpps = 0;
		for(int i=0;i<NumOfThreads;i++)
		{
			if (*(res16)==testres16)
			{
				kdotpps++;
			}
			else 
			{
				goto FAIL_VECT_DOTPPS_16;
			}
		}
		if (kdotpps==NumOfThreads)
		{
			printf("\nPASSED KDOTPPS16  16-bit  post scaling vector dot product");
		}
	}
	// -----------------------------------------------------------------------------------------

	/************************************ 16-bit DOTPPS END **************************************/		

	/************************************ 32-bit DOTPPS Start ************************************/
	VECT_DOTPPS_32:
	CSR_MVTYPE(2);  // set data type to 32-bit

	testres32 = 0;
	
	// ENABLE COUNTING -------------------------------------------------------------------------
	__asm__("csrrw zero, 0x7A0, 0x00000001");
	//------------------------------------------------------------------------------------------
	
	// TEST KDOTPPS32 ----------------------------------------------------------------------------

	res32=kless_post_scal_dot_product((int*) result32, (void*) vect32_1, (void*) vect32_2, (void*) p_scal32, size32);
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
			testres32 += (vect32_1[i]*vect32_2[i]) >> p_scal32;     
		}
		__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[test_perf_i], mcycle, zero;"
			"sw %[test_perf_i], 0(%[test_ptr_perf]);"
			:
			:[test_perf_i] "r" (test_perf_i), [test_ptr_perf] "r" (test_ptr_perf)
			);
		testperf[2]=test_perf_i;
		//printf("\ntestres32: %x",testres32);
		//printf("\nres32: %x",*res32);
		kdotpps = 0;
		for(int i=0;i<NumOfThreads;i++)
		{
			if (*(res32)==testres32)
			{
				kdotpps++;
			}
			else 
			{
				goto FAIL_VECT_DOTPPS_32;
			}
		}
		if (kdotpps==NumOfThreads)
		{
			printf("\nPASSED KDOTPPS32  32-bit  post scaling vector dot product");
		}
	}
	// -----------------------------------------------------------------------------------------
	
	/************************************ 32-bit DOTPPS END *************************************/
	
	if (Klessydra_get_coreID()==1)
	{		
		printf("\nNumber of Elements: %d\n",NumOfElements);
		for(int i=0;i<3;i++)
		{
				printf("Th%d KDOTPPS8  Speed: %d Cycles\n",i, perf8[i]);
		}
		for(int i=0;i<3;i++)
		{
				printf("Th%d KDOTPPS16 Speed: %d Cycles\n",i, perf16[i]);
		}
		for(int i=0;i<3;i++)
		{
				printf("Th%d KDOTPPS32 Speed: %d Cycles\n",i, perf32[i]);
		}
		for(int i=0;i<3;i++)
		{
				printf("DOTPPS%d Speed: %d Cycles\n",8*power(2,i), testperf[i]);
		}
		return 0;
	}	

	__asm__("csrrw zero, mstatus, 8;" "wfi;");
	return 0;

	FAIL_VECT_DOTPPS_8: 
	printf("\nFAILED KDOTPPS8  8-bit  post scaling vector dot product");
	goto VECT_DOTPPS_16;
	FAIL_VECT_DOTPPS_16: 
	printf("\nFAILED KDOTPPS16 16-bit post scaling vector dot product");
	goto VECT_DOTPPS_32;
	FAIL_VECT_DOTPPS_32: 
	printf("\nFAILED KDOTPPS32 32-bit post scaling vector dot product\n");
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
