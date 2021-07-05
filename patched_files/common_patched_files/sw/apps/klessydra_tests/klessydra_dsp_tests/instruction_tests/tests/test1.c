#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "dsp_functions.h"
#include "functions.h"
#include "klessydra_defs.h"

#define NumOfThreads 3
#define scalar_size 4 

//#if !defined(row_size) && !defined(col_size)
//	#define row_size 4
//	#define col_size 4
//#endif

	#define row_size 4
	#define col_size 3

#ifndef TIME
	#define TIME 10
#endif

int8_t  mat8_1[col_size][row_size];
int8_t  mat8_2[col_size][row_size];
int16_t mat16_1[col_size][row_size];
int16_t mat16_2[col_size][row_size];
int32_t mat32_1[col_size][row_size] = { {0x0, 0x1, 0x2, 0x3},{0x4, 0x5, 0x6, 0x7},{0x8, 0x9, 0xA, 0xB} }; //,{0xC, 0xD, 0xE, 0xF} };
int32_t mat32_2[col_size][row_size] = { {0x10, 0x11, 0x12, 0x13},{0x14, 0x15, 0x16, 0x17},{0x18, 0x19, 0x1A, 0x1B} }; //,{0x1C, 0x1D, 0x1E, 0x1F} };
uint8_t testres8;
int16_t testres16;
int32_t testres32[col_size][row_size];
int32_t mul_add;
int8_t  *res8;
int16_t *res16;
int32_t *res32;
int result8[scalar_size], result16[scalar_size], result32[scalar_size];
int size8=row_size*sizeof(char);
int size16=row_size*sizeof(short);
int size32=row_size*sizeof(int);
int testperf[NumOfThreads], perf8[NumOfThreads], perf16[NumOfThreads], perf32[NumOfThreads];

int main()
{	

	////srand (TIME);
	////for (int i=0; i<row_size; i++) 
	////{ 
    ////	mat8_1[i]  = rand()  % (0x100 - 0x1) +1;
	////	mat8_2[i]  = rand()  % (0x100 - 0x1) +1;
	////	mat16_1[i] = rand()  % (0x10000 - 0x1) +1;
	////	mat16_2[i] = rand()  % (0x10000 - 0x1) +1;
	////	mat32_1[i] = rand()  % (0x80000000 - 0x1) +1;
	////	mat32_2[i] = rand()  % (0x80000000 - 0x1) +1;
	////}

	////}int dsp_perf8  = 0;
	////}int dsp_perf16 = 0;
	////}int dsp_perf32 = 0;
	////}int test_perf_i = 0;
	////}int* dsp_ptr_perf8  = &dsp_perf8;
	////}int* dsp_ptr_perf16 = &dsp_perf16;
	////}int* dsp_ptr_perf32 = &dsp_perf32;
	////}int* test_ptr_perf  = &test_perf_i;

	/************************************ 8-bit DOTP Start *************************************/
	////testres8 = 0;


	// ENABLE COUNTING -------------------------------------------------------------------------
	////__asm__("csrrw zero, mcycle, zero;"
	////		"csrrw zero, 0x7A0, 0x00000001");
	//------------------------------------------------------------------------------------------

	// TEST KDOTP8 -----------------------------------------------------------------------------	
    ////res8=kless_dot_product_8((void*) result8, (void*) mat8_1, (void*) mat8_2,  size8);
	//------------------------------------------------------------------------------------------

	// DISABLE COUNTING AND SAVE MCYCLE OF EACH THREAD -----------------------------------------
	////__asm__("csrrw zero, 0x7A0, 0x00000000;"
	////		"csrrw %[dsp_perf8], mcycle, zero;"
	////		"sw %[dsp_perf8], 0(%[dsp_ptr_perf8]);"
	////		:
	////		:[dsp_perf8] "r" (dsp_perf8), [dsp_ptr_perf8] "r" (dsp_ptr_perf8)
	////		);
	////if (Klessydra_get_coreID()==0) {perf8[0]=dsp_perf8; } //printf("Speed: %d Cycles\n", perf8[0]);}
	////if (Klessydra_get_coreID()==1) {perf8[1]=dsp_perf8; }//printf("Speed: %d Cycles\n", perf8[1]);}
	////if (Klessydra_get_coreID()==2) {perf8[2]=dsp_perf8; } //printf("Speed: %d Cycles\n", perf8[2]);}
	//------------------------------------------------------------------------------------------

	// Test 8-bit dot-product result -----------------------------------------------------------
	/*
	if (Klessydra_get_coreID()==1)
	{
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<row_size; i++)
		{
			testres8 += mat8_1[i]*mat8_2[i];
		}
		printf("\ntestres8: %x",testres8);
		printf("\nres8: %x",*res8);
		__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[test_perf_i], mcycle, zero;"
			"sw %[test_perf_i], 0(%[test_ptr_perf]);"
			:
			:[test_perf_i] "r" (test_perf_i), [test_ptr_perf] "r" (test_ptr_perf)
			);
		testperf[0]=test_perf_i;
		if (*res8==testres8)
		{
			printf("\nPASSED KDOTP8  8-bit  vector dot product");
		}
		else 
		{
			goto FAIL_VECT_DOTP_8;
		}
	}
	*/
	// -----------------------------------------------------------------------------------------
	
	/************************************ 8-bit DOTP END ***************************************/

	/************************************ 16-bit DOTP Start ************************************/
	////VECT_DOTP_16:
	////testres16 = 0;
	
	// ENABLE COUNTING -------------------------------------------------------------------------
	////__asm__("csrrw zero, 0x7A0, 0x00000001");
	//------------------------------------------------------------------------------------------

	// TEST KDOTP16 ----------------------------------------------------------------------------	
	////res16=kless_dot_product_16((void*) result16, (void*) mat16_1, (void*) mat16_2, size16);
	//------------------------------------------------------------------------------------------
	// DISABLE COUNTING AND SAVE MCYCLE OF EACH THREAD ////////
	////__asm__("csrrw zero, 0x7A0, 0x00000000;"
	////    	"csrrw %[dsp_perf16], mcycle, zero;"
	////		"sw %[dsp_perf16], 0(%[dsp_ptr_perf16]);"
	////		:
	////		:[dsp_perf16] "r" (dsp_perf16), [dsp_ptr_perf16] "r" (dsp_ptr_perf16)
	////		);
	////if (Klessydra_get_coreID()==0) perf16[0]=dsp_perf16;
	////if (Klessydra_get_coreID()==1) perf16[1]=dsp_perf16;
	////if (Klessydra_get_coreID()==2) perf16[2]=dsp_perf16;
	//------------------------------------------------------------------------------------------

	// Test 16-bit dot-product result ----------------------------------------------------------
	/*
	if (Klessydra_get_coreID()==1)
	{
		__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		for (int i=0; i<row_size; i++)
		{
			testres16 += mat16_1[i]*mat16_2[i];     
		}
		printf("\ntestres16: %x",testres16);
		printf("\nres16: %x",*res16);
		__asm__("csrrw zero, 0x7A0, 0x00000000;"
			"csrrw %[test_perf_i], mcycle, zero;"
			"sw %[test_perf_i], 0(%[test_ptr_perf]);"
			:
			:[test_perf_i] "r" (test_perf_i), [test_ptr_perf] "r" (test_ptr_perf)
			);
		testperf[1]=test_perf_i;
		if (*res16==testres16)
		{
			printf("\nPASSED KDOTP16 16-bit vector dot product");
		}
		else 
		{
			goto FAIL_VECT_DOTP_16;
		}
	}
	*/
	// -----------------------------------------------------------------------------------------

	/************************************ 16-bit DOTP END **************************************/		

	/************************************ 32-bit DOTP Start ************************************/
	////VECT_DOTP_32:
	////testres32 = 0;
	
	// ENABLE COUNTING -------------------------------------------------------------------------
	////__asm__("csrrw zero, 0x7A0, 0x00000001");
	//------------------------------------------------------------------------------------------
	
	// TEST KDOTP32 ----------------------------------------------------------------------------	
	////res32=kless_dot_product_32((int*) result32, (void*) mat32_1, (void*) mat32_2, size32);
	//------------------------------------------------------------------------------------------
	
	// DISABLE COUNTING AND SAVE MCYCLE OF EACH THREAD -----------------------------------------
	////__asm__("csrrw zero, 0x7A0, 0x00000000;"
	////    	"csrrw %[dsp_perf32], mcycle, zero;"
	////		"sw %[dsp_perf32], 0(%[dsp_ptr_perf32]);"
	////		:
	////		:[dsp_perf32] "r" (dsp_perf32), [dsp_ptr_perf32] "r" (dsp_ptr_perf32)
	////		);
	////if (Klessydra_get_coreID()==0) perf32[0]=dsp_perf32;
	////if (Klessydra_get_coreID()==1) perf32[1]=dsp_perf32;
	////if (Klessydra_get_coreID()==2) perf32[2]=dsp_perf32;
	//------------------------------------------------------------------------------------------
	
	// Test 32-bit dot-product result ----------------------------------------------------------
	if (Klessydra_get_coreID()==1)
	{
		for(int i=0; i<col_size; i++)
		{
			for (int j=0; j<row_size; j++)
			{
				printf("\mat32_1: %x",mat32_1[i][j]);
			}
		}
		////__asm__( "csrrw zero, 0x7A0, 0x00000001;");
		mul_add = 0;	
		for(int i=0; i<col_size; i++)
		{
			for (int j=0; j<row_size; j++)
			{
				for (int k=0; k<col_size; k++)
				{
					mul_add += mat32_1[i][k]*mat32_2[k][j];  
				}
				testres32[i][j] = mul_add;
				mul_add = 0;
				printf("\ntestres32: %x",testres32[i][j]);
			}
		}
		printf("\n");
		////printf("\nres32: %x",*res32);
		////__asm__("csrrw zero, 0x7A0, 0x00000000;"
		////	"csrrw %[test_perf_i], mcycle, zero;"
		////	"sw %[test_perf_i], 0(%[test_ptr_perf]);"
		////	:
		////	:[test_perf_i] "r" (test_perf_i), [test_ptr_perf] "r" (test_ptr_perf)
		////	);
		////testperf[2]=test_perf_i;
		////if (*res32==testres32)
		////{
		////	printf("\nPASSED KDOTP32 32-bit vector dot product\n\n");
		////}
		////else 
		////{
		////	goto FAIL_VECT_DOTP_32;
		////}
	}
	// -----------------------------------------------------------------------------------------
	
	/************************************ 32-bit DOTP END *************************************/
	
	if (Klessydra_get_coreID()==1)
	{		
	////	printf("\nNumber of Elements: %d\n",row_size);
	////	for(int i=0;i<3;i++)
	////	{
	////			printf("Th%d KDOTP8  Speed: %d Cycles\n",i, perf8[i]);
	////	}
	////	for(int i=0;i<3;i++)
	////	{
	////			printf("Th%d KDOTP16 Speed: %d Cycles\n",i, perf16[i]);
	////	}
	////	for(int i=0;i<3;i++)
	////	{
	////			printf("Th%d KDOTP32 Speed: %d Cycles\n",i, perf32[i]);
	////	}
	////	for(int i=0;i<3;i++)
	////	{
	////			printf("DOTP%d Speed: %d Cycles\n",8*(2^i), testperf[i]);
	////	}
	return 0;
	}	

	__asm__("csrrw zero, mstatus, 8;" "wfi;");
	return 0;

	////FAIL_VECT_DOTP_8: 
	////printf("\nFAILED KDOTP8  8-bit  vector dot product");
	////goto VECT_DOTP_16;
	////FAIL_VECT_DOTP_16: 
	////printf("\nFAILED KDOTP16 16-bit vector dot product");
	////goto VECT_DOTP_32;
	////FAIL_VECT_DOTP_32: 
	////printf("\nFAILED KDOTP32 32-bit vector dot product\n");
	////if (Klessydra_get_coreID()==1)
	////{		
	////	printf("\nNumber of Elements: %d\n\n",row_size);
	////}
    ////return 1;
}


