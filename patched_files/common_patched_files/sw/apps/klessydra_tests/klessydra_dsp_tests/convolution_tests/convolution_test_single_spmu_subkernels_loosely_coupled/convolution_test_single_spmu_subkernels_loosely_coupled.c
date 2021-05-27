/*
----------------------------------------------------------------------------------------------------
Convolution test
Multithreaded;
Accelerator (DPS+spm) is ON;
Replication of spm's and DSP Unit is OFF;
the Multithread is used with different thread working on 3 batches of rows of the same output matrix, 
so in this approach each thread has a REGION of the output matrix to work on
----------------------------------------------------------------------------------------------------
*/
#ifndef A_ORDER
#define A_ORDER 32//Matrix size, don't do 2x2 case, for that i have another test
#endif

#define MULTI_TH 1
#ifndef PRINT_NUM_CYCLES
#define PRINT_NUM_CYCLES 1 // to print the cycle count
#endif

//#define MATRIX_CHECK_THREAD 0
// #define MATRIX_CHECK 0
// #define PRINT_DEBUG 1

//-------------------------------------------------------------------------------------
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include "dsp_functions.h"
#include "functions.h"
#include "klessydra_defs.h"

#define SPM_MAX 64
#define SIZE_OF_INT 4
#define B_ORDER 3
#define K_COL (B_ORDER+1)

int loop_index=1;
int matA0[A_ORDER*A_ORDER];
int matA1[A_ORDER*A_ORDER];
int matA2[A_ORDER*A_ORDER];
int dimension_A=A_ORDER*A_ORDER*sizeof(int);

int matB[B_ORDER*B_ORDER] = {0};
int dimension_B=B_ORDER*B_ORDER*sizeof(int);

int output_compare0[A_ORDER*A_ORDER]={0};
int output_compare1[A_ORDER*A_ORDER]={0};
int output_compare2[A_ORDER*A_ORDER]={0};
int output_compare_s0[A_ORDER*A_ORDER]={0};
int output_compare_s1[A_ORDER*A_ORDER]={0};
int output_compare_s2[A_ORDER*A_ORDER]={0};
int mat_second_A[3][A_ORDER][A_ORDER];

// #define Z_ORDER A_ORDER
int conv2D_out_scal=5;
int shift_pre=8;
int shift_out=5;
int warn[3];

int print_global_k , print_global_id	,	print_global_dbg;
int azzero=0;
int sign;
int memory_offset[3]={0};


int perf0[3] = {0, 0, 0};
int final_perf0[3] = {777, 777, 777};
int *ptr_perf0[3];

int perf1[3] = {0, 0, 0};
int final_perf1[3] = {777, 777, 777};
int  *ptr_perf1[3];

int perf2[3] = {0, 0, 0};
int final_perf2[3] = {777, 777, 777};
int *ptr_perf2[3];

int perf3[3] = {0, 0, 0};
int final_perf3[3] = {777, 777, 777};
int *ptr_perf3[3];

int perf4[3] = {0, 0, 0};
int final_perf4[3] = {777, 777, 777};
int *ptr_perf4[3];

int perf5[3] = {0, 0, 0};
int final_perf5[3] = {777, 777, 777};
int *ptr_perf5[3];

int perf6[3] = {0, 0, 0};
int final_perf6[3] = {777, 777, 777};
int *ptr_perf6[3];

int perf7[3] = {0, 0, 0};
int final_perf7[3] = {777, 777, 777};
int *ptr_perf7[3];

int perf0ld = 0;
int final_perf0ld = 777;
int *ptr_perf0ld = &perf0ld;

int perf_mem = 0;
int final_perf_mem = 777;
int *ptr_perf_mem = &perf_mem;


void spegni_threads();
void display_spm_matrix(int size_r,int size_c,void* pt_spm_mat);
void display_spm_matrix_hex(int size_r,int size_c,void* pt_spm_mat);

void matrix_print(int* pt, int size, int mode);
void matrix_check( int* mat1, int* mat2, int size );
void convolution2D_Scaling(int size, int (*matrix)[size], int *kernel_tmp, int *out);
void matrix_check_thread( int* mat1, int* mat2, int size, int thread);

void convolution2D_SPM_off(void* spm_dest, void* spm_fm, void* spm_krn, int size, int mem_off);
void convolution2D_SPM_off_NOB_print_region_1(void* spm_dest, 	 void* spm_fm,	 void* spm_krn,	 void* spm_temp,  int size);
void convolution2D_SPM_off_NOB_print_region_2(void* spm_dest, 	 void* spm_fm,	 void* spm_krn,	 void* spm_temp,  int size);
void convolution2D_SPM_off_NOB_print_region_3(void* spm_dest, 	 void* spm_fm,	 void* spm_krn,	 void* spm_temp,  int size);

void convolution2D_SPM_off_NOB_2x2(void* spm_dest, 	 void* spm_fm,	 void* spm_krn,	 void* spm_temp,  int size);	//no
void convolution2D_SPM_off_NOB(void* spm_dest, 	 void* spm_fm,	 void* spm_krn,	 void* spm_temp,  int size);			//no
void convolution2D_SPM_off_ALT_2x2(void* spm_dest, void* spm_fm, void* spm_krn, void* spm_bank, int size);				//si


void convolution2D_Scaling_region_1(int size, int (*matrix)[size], int *kernel_tmp, int *out);
void convolution2D_Scaling_region_2(int size, int (*matrix)[size], int *kernel_tmp, int *out);
void convolution2D_Scaling_region_3(int size, int (*matrix)[size], int *kernel_tmp, int *out);

void matrix_check_v2( int* mat1, int* mat2, int size);

//------------------------------------------------------------------------------------------------------------
// 													MAIN
//------------------------------------------------------------------------------------------------------------
int main(){

    for (int i=0; i<3; i++){
     	ptr_perf0[i] = &perf0[i];
    	ptr_perf1[i] = &perf1[i];
    	ptr_perf2[i] = &perf2[i];
    	ptr_perf3[i] = &perf3[i];
    	ptr_perf4[i] = &perf4[i];
    	ptr_perf5[i] = &perf5[i];
     	ptr_perf6[i] = &perf6[i];
    	ptr_perf7[i] = &perf7[i];
    }

	print_global_k =0;
	print_global_id=0;
	print_global_dbg=0;;
	int squares[A_ORDER*A_ORDER]={0};
	warn[0]=2;
	warn[1]=2;
	warn[2]=2;

	for(int i=0; i<B_ORDER*B_ORDER; i++){
    matB[i]=(i+1)<<8;}
    
	sign=1;
	for(int i =0; i<A_ORDER*A_ORDER; i++){
    matA0[i]=(1000*sign*(i+1))<<8;
		matA1[i]=(20*sign*(i+1))<<8;
		matA2[i]=(3*sign*(i+1))<<8;
		sign=sign*(-1);
		output_compare_s0[i]=777;
		output_compare_s1[i]=777;
		output_compare_s2[i]=777;}

	sign = 1;
  for(int i =0;i<A_ORDER; i++)
  {
    for(int j=0; j<A_ORDER; j++)
	{
      mat_second_A[0][i][j]=(1000*sign*(i*A_ORDER+j+1))<<8;
			mat_second_A[1][i][j]=(20*sign*(i*A_ORDER+j+1))<<8;
			mat_second_A[2][i][j]=(3*sign*(i*A_ORDER+j+1))<<8;
			sign=sign*(-1);
    }
  }
	memory_offset[0]=0;
	memory_offset[1]=1*32*32;
	memory_offset[2]=2*32*32;
	__asm__("csrw 0x300, 0x8;" );// each thread enables it's own interrupt
	__asm__("csrrw zero, mcycle, zero");
	CSR_MVSIZE(SPM_MAX*SPM_MAX*sizeof(int));
	kbcast((void*)spmaddrA,(void*)azzero);
	kbcast((void*)spmaddrB,(void*)azzero);
	kbcast((void*)spmaddrC,(void*)azzero);
	kbcast((void*)spmaddrD,(void*)azzero);
	CSR_MVSIZE(dimension_A);
	int junk=0;
	//so i just use a quick function that do the trick
	CSR_MVSIZE(2*SIZE_OF_INT);
	kdotpps_v3((void*)spmaddrA,	(void*)spmaddrA,	(void*)spmaddrB, (void*) conv2D_out_scal);
	CSR_MVSIZE(dimension_A);
	int off_idx=0;
	int array_boundaries[3]={0};
	array_boundaries[0] = A_ORDER/3;
	array_boundaries[1] =	array_boundaries[0]*2;
	array_boundaries[2] = A_ORDER;

	#ifdef MULTI_TH

		sync_barrier_reset();
		//------------------------------------------------------------------------------------------------------------
		sync_barrier_thread_registration();
		

		if (Klessydra_get_coreID() == 0) {

			// ENABLE COUNTING -------------------------------------------------------------------------
			#ifdef PRINT_NUM_CYCLES
			final_perf0ld=0;
				__asm__("csrrw zero, mcycle, zero;"
						"csrrw zero, 0x7A0, 0x00000001");
			#endif
			//------------------------------------------------------------------------------------------// CSR_MVSIZE(dimension_A);
			kmemld((void*)((int*)spmaddrB+memory_offset[0]), (void*)matB, dimension_B);
			ksrav((void*)((int*)spmaddrB+memory_offset[0]),(void*)((int*)spmaddrB+memory_offset[0]),	(int*)shift_pre);

			kmemld((void*)((int*)spmaddrA+memory_offset[0]), (void*)matA0, dimension_A);
			ksrav((void*)((int*)spmaddrA+memory_offset[0]),(void*)((int*)spmaddrA+memory_offset[0]),	(int*)shift_pre);

			// DISABLE COUNTING AND SAVE MCYCLE -------------------------------------------------------
			#ifdef PRINT_NUM_CYCLES
				__asm__("csrrw zero, 0x7A0, 0x00000000;"
						"csrrw %[perf0ld], mcycle, zero;"
						"sw %[perf0ld], 0(%[ptr_perf0ld]);"
						:
						:[perf0ld] "r" (perf0ld), [ptr_perf0ld] "r" (ptr_perf0ld)
				);
				final_perf0ld=*(ptr_perf0ld);
			#endif
			// //------------------------------------------------------------------------------------------
		}

		sync_barrier();
		//------------------------------------------------------------------------------------------------------------
		sync_barrier_thread_registration();
		int main_size=A_ORDER;
		int enable_oerf_cnt = 0;
		if (Klessydra_get_coreID() == 0) {
			// ENABLE COUNTING -------------------------------------------------------------------------
			#ifdef PRINT_NUM_CYCLES
				final_perf0[0]=0;
				final_perf1[0]=0;
				final_perf2[0]=0;
				final_perf3[0]=0;
				final_perf4[0]=0;
				final_perf5[0]=0;
				final_perf6[0]=0;
				final_perf7[0]=0;
				__asm__("csrrw zero, mcycle, zero;"    // reset cycle count
						"csrrw zero, minstret, zero;"  // reset instruction count
						"csrrw zero, 0xB03, zero;"     // reset load store access stall count
						"csrrw zero, 0xB06, zero;"     // reset load count
						"csrrw zero, 0xB07, zero;"     // reset store count
						"csrrw zero, 0xB08, zero;"     // reset unconditional count
						"csrrw zero, 0xB09, zero;"     // reset branch count
						"csrrw zero, 0xB0A, zero;"     // reset taken branch count
						"li %[enable], 0x000003E7;"    // enable performance counters
						"csrrw zero, 0x7A0, %[enable]" // enable performance counters
						:
						:[enable] "r" (enable_oerf_cnt)
				);
			#endif
			//------------------------------------------------------------------------------------------
			off_idx=0;
			for (int l=0; l<loop_index; l++) {
				convolution2D_SPM_off_NOB_print_region_1 ((void*)(	(int*)spmaddrC+	 memory_offset[off_idx]	), (void*)(	(int*)spmaddrA+	 memory_offset[off_idx]	), (void*)(	(int*)spmaddrB+ memory_offset[off_idx]	), (void*)(	(int*)spmaddrD+	 memory_offset[off_idx]	),	A_ORDER);
			}
				kmemstr((void*)((int*)output_compare_s0 + 0),
			 			(void*)((int*)spmaddrC+memory_offset[0] + 0),
						SIZE_OF_INT*(	A_ORDER*(array_boundaries[0] - 0))		);

			// DISABLE COUNTING AND SAVE MCYCLE -------------------------------------------------------
			#ifdef PRINT_NUM_CYCLES
				__asm__("csrrw zero, 0x7A0, 0x00000000;" // disable performance counters
						"csrrw %[perf0], mcycle, zero;"
						"sw %[perf0], 0(%[ptr_perf0]);"
						"csrrw %[perf1], minstret, zero;"
						"sw %[perf1], 0(%[ptr_perf1]);"
						"csrrw %[perf2], 0xB03, zero;"
						"sw %[perf2], 0(%[ptr_perf2]);"
						"csrrw %[perf3], 0xB06, zero;"
						"sw %[perf3], 0(%[ptr_perf3]);"
						"csrrw %[perf4], 0xB07, zero;"
						"sw %[perf4], 0(%[ptr_perf4]);"
						"csrrw %[perf5], 0xB08, zero;"
						"sw %[perf5], 0(%[ptr_perf5]);"
						"csrrw %[perf6], 0xB09, zero;"
						"sw %[perf6], 0(%[ptr_perf6]);"
						"csrrw %[perf7], 0xB0A, zero;"
						"sw %[perf7], 0(%[ptr_perf7]);"
						:
						:[perf0] "r" (perf0[0]), [ptr_perf0] "r" (ptr_perf0[0]),
						 [perf1] "r" (perf1[0]), [ptr_perf1] "r" (ptr_perf1[0]),
						 [perf2] "r" (perf2[0]), [ptr_perf2] "r" (ptr_perf2[0]),
						 [perf3] "r" (perf3[0]), [ptr_perf3] "r" (ptr_perf3[0]),
						 [perf4] "r" (perf4[0]), [ptr_perf4] "r" (ptr_perf4[0]),
						 [perf5] "r" (perf5[0]), [ptr_perf5] "r" (ptr_perf5[0]),
						 [perf6] "r" (perf6[0]), [ptr_perf6] "r" (ptr_perf6[0]),
						 [perf7] "r" (perf7[0]), [ptr_perf7] "r" (ptr_perf7[0])
				);
			#endif
			// //------------------------------------------------------------------------------------------
		}

		if (Klessydra_get_coreID() == 1) {
			// ENABLE COUNTING -------------------------------------------------------------------------
			#ifdef PRINT_NUM_CYCLES
				final_perf0[1]=0;
				final_perf1[1]=0;
				final_perf2[1]=0;
				final_perf3[1]=0;
				final_perf4[1]=0;
				final_perf5[1]=0;
				final_perf6[1]=0;
				final_perf7[1]=0;
				__asm__("csrrw zero, mcycle, zero;"    // reset cycle count
						"csrrw zero, minstret, zero;"  // reset instruction count
						"csrrw zero, 0xB03, zero;"     // reset load store access stall count
						"csrrw zero, 0xB06, zero;"     // reset load count
						"csrrw zero, 0xB07, zero;"     // reset store count
						"csrrw zero, 0xB08, zero;"     // reset unconditional count
						"csrrw zero, 0xB09, zero;"     // reset branch count
						"csrrw zero, 0xB0A, zero;"     // reset taken branch count
						"li %[enable], 0x000003E7;"    // enable performance counters
						"csrrw zero, 0x7A0, %[enable]" // enable performance counters
						:
						:[enable] "r" (enable_oerf_cnt)
				);
			#endif
			//------------------------------------------------------------------------------------------
			for (int l=0; l<loop_index; l++) 
			{
				off_idx=0;
				convolution2D_SPM_off_NOB_print_region_2 ((void*)(	(int*)spmaddrC+	 memory_offset[off_idx]	), (void*)(	(int*)spmaddrA+	 memory_offset[off_idx]	), (void*)(	(int*)spmaddrB+  memory_offset[off_idx]	), (void*)(	(int*)spmaddrD+	 memory_offset[off_idx]	),	A_ORDER);
			}
			kmemstr((void*)((int*)output_compare_s0 				+ A_ORDER*(array_boundaries[0])),
 			 		(void*)((int*)spmaddrC+memory_offset[0] + A_ORDER*(array_boundaries[0])),
 					SIZE_OF_INT*(	A_ORDER*(array_boundaries[1] - array_boundaries[0]))		);

			// DISABLE COUNTING AND SAVE MCYCLE -------------------------------------------------------
			#ifdef PRINT_NUM_CYCLES
				__asm__("csrrw zero, 0x7A0, 0x00000000;" // disable performance counters
						"csrrw %[perf0], mcycle, zero;"
						"sw %[perf0], 0(%[ptr_perf0]);"
						"csrrw %[perf1], minstret, zero;"
						"sw %[perf1], 0(%[ptr_perf1]);"
						"csrrw %[perf2], 0xB03, zero;"
						"sw %[perf2], 0(%[ptr_perf2]);"
						"csrrw %[perf3], 0xB06, zero;"
						"sw %[perf3], 0(%[ptr_perf3]);"
						"csrrw %[perf4], 0xB07, zero;"
						"sw %[perf4], 0(%[ptr_perf4]);"
						"csrrw %[perf5], 0xB08, zero;"
						"sw %[perf5], 0(%[ptr_perf5]);"
						"csrrw %[perf6], 0xB09, zero;"
						"sw %[perf6], 0(%[ptr_perf6]);"
						"csrrw %[perf7], 0xB0A, zero;"
						"sw %[perf7], 0(%[ptr_perf7]);"
						:
						:[perf0] "r" (perf0[1]), [ptr_perf0] "r" (ptr_perf0[1]),
						 [perf1] "r" (perf1[1]), [ptr_perf1] "r" (ptr_perf1[1]),
						 [perf2] "r" (perf2[1]), [ptr_perf2] "r" (ptr_perf2[1]),
						 [perf3] "r" (perf3[1]), [ptr_perf3] "r" (ptr_perf3[1]),
						 [perf4] "r" (perf4[1]), [ptr_perf4] "r" (ptr_perf4[1]),
						 [perf5] "r" (perf5[1]), [ptr_perf5] "r" (ptr_perf5[1]),
						 [perf6] "r" (perf6[1]), [ptr_perf6] "r" (ptr_perf6[1]),
						 [perf7] "r" (perf7[1]), [ptr_perf7] "r" (ptr_perf7[1])
				);
			#endif
			//------------------------------------------------------------------------------------------
		}

		if (Klessydra_get_coreID() == 2) {

			// ENABLE COUNTING -------------------------------------------------------------------------
			#ifdef PRINT_NUM_CYCLES
				final_perf0[2]=0;
				final_perf1[2]=0;
				final_perf2[2]=0;
				final_perf3[2]=0;
				final_perf4[2]=0;
				final_perf5[2]=0;
				final_perf6[2]=0;
				final_perf7[2]=0;
				__asm__("csrrw zero, mcycle, zero;"    // reset cycle count
						"csrrw zero, minstret, zero;"  // reset instruction count
						"csrrw zero, 0xB03, zero;"     // reset load store access stall count
						"csrrw zero, 0xB06, zero;"     // reset load count
						"csrrw zero, 0xB07, zero;"     // reset store count
						"csrrw zero, 0xB08, zero;"     // reset unconditional count
						"csrrw zero, 0xB09, zero;"     // reset branch count
						"csrrw zero, 0xB0A, zero;"     // reset taken branch count
						"li %[enable], 0x000003E7;"    // enable performance counters
						"csrrw zero, 0x7A0, %[enable]" // enable performance counters
						:
						:[enable] "r" (enable_oerf_cnt)
				);
			#endif
			//------------------------------------------------------------------------------------------
			for (int l=0; l<loop_index; l++) {
				off_idx=0;
				convolution2D_SPM_off_NOB_print_region_3 ((void*)(	(int*)spmaddrC+	 memory_offset[off_idx]	), (void*)(	(int*)spmaddrA+	 memory_offset[off_idx]	), (void*)(	(int*)spmaddrB+  memory_offset[off_idx]	), (void*)(	(int*)spmaddrD+	 memory_offset[off_idx]	),	A_ORDER);
			}

			kmemstr(	(void*)((int*)output_compare_s0 				+ A_ORDER*(array_boundaries[1])),
						(void*)((int*)spmaddrC+memory_offset[0] + A_ORDER*(array_boundaries[1])),
						 SIZE_OF_INT*(	A_ORDER*(array_boundaries[2] - array_boundaries[1]))		);
			// DISABLE COUNTING AND SAVE MCYCLE -------------------------------------------------------
			#ifdef PRINT_NUM_CYCLES
				__asm__("csrrw zero, 0x7A0, 0x00000000;" // disable performance counters
						"csrrw %[perf0], mcycle, zero;"
						"sw %[perf0], 0(%[ptr_perf0]);"
						"csrrw %[perf1], minstret, zero;"
						"sw %[perf1], 0(%[ptr_perf1]);"
						"csrrw %[perf2], 0xB03, zero;"
						"sw %[perf2], 0(%[ptr_perf2]);"
						"csrrw %[perf3], 0xB06, zero;"
						"sw %[perf3], 0(%[ptr_perf3]);"
						"csrrw %[perf4], 0xB07, zero;"
						"sw %[perf4], 0(%[ptr_perf4]);"
						"csrrw %[perf5], 0xB08, zero;"
						"sw %[perf5], 0(%[ptr_perf5]);"
						"csrrw %[perf6], 0xB09, zero;"
						"sw %[perf6], 0(%[ptr_perf6]);"
						"csrrw %[perf7], 0xB0A, zero;"
						"sw %[perf7], 0(%[ptr_perf7]);"
						:
						:[perf0] "r" (perf0[2]), [ptr_perf0] "r" (ptr_perf0[2]),
						 [perf1] "r" (perf1[2]), [ptr_perf1] "r" (ptr_perf1[2]),
						 [perf2] "r" (perf2[2]), [ptr_perf2] "r" (ptr_perf2[2]),
						 [perf3] "r" (perf3[2]), [ptr_perf3] "r" (ptr_perf3[2]),
						 [perf4] "r" (perf4[2]), [ptr_perf4] "r" (ptr_perf4[2]),
						 [perf5] "r" (perf5[2]), [ptr_perf5] "r" (ptr_perf5[2]),
						 [perf6] "r" (perf6[2]), [ptr_perf6] "r" (ptr_perf6[2]),
						 [perf7] "r" (perf7[2]), [ptr_perf7] "r" (ptr_perf7[2])
				);
			#endif
			//------------------------------------------------------------------------------------------
		}

		sync_barrier();
		//------------------------------------------------------------------------------------------------------------
		sync_barrier_thread_registration();
		if (Klessydra_get_coreID() == 0) {
			#ifdef PRINT_NUM_CYCLES
			    for (int i=0; i<3; i++){
					final_perf0[i]=*(ptr_perf0[i]);
					final_perf1[i]=*(ptr_perf1[i]);
					final_perf2[i]=*(ptr_perf2[i]);
					final_perf3[i]=*(ptr_perf3[i]);
					final_perf4[i]=*(ptr_perf4[i]);
					final_perf5[i]=*(ptr_perf5[i]);
					final_perf6[i]=*(ptr_perf6[i]);
					final_perf7[i]=*(ptr_perf7[i]);
    			}
				printf("--------Test: SINGLE SPMU SUBKERNEL LOOSELY COUPLED[%dx%d]--------\n", main_size, main_size);
				printf("N of loops:%d\n\n",loop_index);
				printf("\n Thread_0 doing kmemld+ksrav of input matrix and kernel matrix is = %d Cycles\n", final_perf0ld);
				printf("\n");
				for (int i=0; i<3; i++) {
					printf(" Cycle Count = %d \n Instruction Count = %d \n Instruction wait = %d \n Load Count = %d \n Store Count = %d \n Unconditional Jump Count = %d \n Branch Count = %d \n Taken Count = %d \n \n",
							 final_perf0[i], final_perf1[i], final_perf2[i], final_perf3[i], final_perf4[i], final_perf5[i], final_perf6[i], final_perf7[i]);
				}
				printf("\n");
			#endif


			#ifdef PRINT_DEBUG
				// ENABLE COUNTING -------------------------------------------------------------------------
				final_perf_mem=0;
				__asm__("csrrw zero, mcycle, zero;"
						"csrrw zero, 0x7A0, 0x00000001");
				//------------------------------------------------------------------------------------------

				for (int l=0; l<loop_index; l++) convolution2D_Scaling(A_ORDER, mat_second_A[0],(int*)matB, (int*)output_compare0);
				// DISABLE COUNTING AND SAVE MCYCLE -------------------------------------------------------
				__asm__("csrrw zero, 0x7A0, 0x00000000;"
						"csrrw %[perf_mem], mcycle, zero;"
						"sw %[perf_mem], 0(%[ptr_perf_mem]);"
						:
						:[perf_mem] "r" (perf_mem), [ptr_perf_mem] "r" (ptr_perf_mem)
						);
				final_perf_mem=*(ptr_perf_mem);
				// //------------------------------------------------------------------------------------------
				printf("Convolution with Multiplier (in memory) Speed is:\t%d Cycles\n", final_perf_mem);
				printf("\n\n");

				printf("DEBUG_print_debug\n");
				printf("----------Dal thread 0, Reale e SPM\n");
					matrix_check_v2((int*)output_compare_s0,(int*)output_compare0, A_ORDER);
				printf("\n");
				printf("\n");
			#endif
		}
		sync_barrier();

	#endif

	return 0;
}



//------------------------------------------------------------------------------------------------------------
// Functions
//------------------------------------------------------------------------------------------------------------

void convolution2D_Scaling(int size, int (*matrix)[size], int *kernel_tmp, int *out)
{
	int print=0;
	int kernel[9];
	int conv2D_scaling_factor=8;
	int conv2D_out_scal=5;
	for(int i=0;i<9;i++){
    	kernel[i]=(kernel_tmp[i]>>conv2D_scaling_factor);
    }
	int i, j;
	int pt=0;
	///////////////////////////////////
	//scandisci tutta l'ultima						colonna	F
	j=(size-1);
	for(i = 1; i < size-1 ; i++)
	{
		pt=i*size+j;
		out[pt] +=	(((matrix[i-1][j-1]>>conv2D_scaling_factor) 	* kernel[0])>>		conv2D_out_scal)     +
					(((matrix[i-1][j]	>>conv2D_scaling_factor)	* kernel[1])>>		conv2D_out_scal)     +
					(((matrix[i][j-1]	>>conv2D_scaling_factor)	* kernel[3])>>		conv2D_out_scal)     +
					(((matrix[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>		conv2D_out_scal)     +
					(((matrix[i+1][j-1]>>conv2D_scaling_factor) 	* kernel[6])>>		conv2D_out_scal)     +
					(((matrix[i+1][j] >>conv2D_scaling_factor)		* kernel[7])>>		conv2D_out_scal)    ;
	}
	if(print){
		printf("dopo kernel F\n");
		for (int rig=0;rig<size;rig++){
			for (int col=0;col<size;col++){
				printf("%d\t",out[rig*size+col]);
			}printf("\n");
		}
	}
		//printf("out[%d]=%d\n",pt,(int)out[pt]);
	///////////////////////////////////
													//alto sinistra A
	i=0;
	j=0;
	pt=i*size+j;
		out[pt] +=	(((matrix[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>			conv2D_out_scal) 	 +
					(((matrix[i][j+1]>>conv2D_scaling_factor)		* kernel[5])>>			conv2D_out_scal)	 +
					(((matrix[i+1][j] >>conv2D_scaling_factor)		* kernel[7])>>			conv2D_out_scal)	 +
					(((matrix[i+1][j+1]>>conv2D_scaling_factor) 	* kernel[8])>>			conv2D_out_scal)	;
		//printf("out[%d]=%d\n",pt,(int)out[pt]);

	///////////////////////////////////
	//vertice alto a destra 						C
	i=0;
	j=(size-1);
	pt=i*size+j;
		out[pt] +=	(((matrix[i][j-1]>>conv2D_scaling_factor)		* kernel[3])>>			conv2D_out_scal) 	  +
					(((matrix[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>			conv2D_out_scal) 	  +
					(((matrix[i+1][j-1]>>conv2D_scaling_factor) 	* kernel[6])>>			conv2D_out_scal) 	  +
					(((matrix[i+1][j] >>conv2D_scaling_factor)		* kernel[7])>>			conv2D_out_scal) 	 ;
		//printf("out[%d]=%d\n",pt,(int)out[pt]);

	///////////////////////////////////
	//in basso a 									sinistra G
	j=0;
	i=size-1;
	pt=i*size+j;
		out[pt] +=	(((matrix[i-1][j]	>>conv2D_scaling_factor)	* kernel[1])>>		conv2D_out_scal)     +
					(((matrix[i-1][j+1]>>conv2D_scaling_factor)		* kernel[2])>>		conv2D_out_scal)     +
					(((matrix[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>		conv2D_out_scal)     +
					(((matrix[i][j+1]	>>conv2D_scaling_factor)	* kernel[5])>>		conv2D_out_scal)    ;
		//printf("out[%d]=%d\n",pt,(int)out[pt]);

	///////////////////////////////////
	//in basso a 									destra	I
	i=(size-1);
	j=size-1;
	pt=i*size+j;
		out[pt] +=	(((matrix[i-1][j-1]>>conv2D_scaling_factor) 	* kernel[0])>>		conv2D_out_scal)     +
					(((matrix[i-1][j]	>>conv2D_scaling_factor)	* kernel[1])>>		conv2D_out_scal)     +
					(((matrix[i][j-1]	>>conv2D_scaling_factor)	* kernel[3])>>		conv2D_out_scal)     +
					(((matrix[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>		conv2D_out_scal)    ;
		//printf("out[%d]=%d\n",pt,(int)out[pt]);
	if(print){
		printf("dopo kernel F-ACGI\n");
		for (int rig=0;rig<size;rig++){
			for (int col=0;col<size;col++){
				printf("%d\t",out[rig*size+col]);
			}printf("\n");
		}
	}
	///////////////////////////////////
	//scandisci tutta la prima colonna 				D
	j=0;
	for(i = 1; i < size-1 ; i++)
	{
		pt=i*size+j;
		out[pt] +=	(((matrix[i-1][j]>>conv2D_scaling_factor)	* kernel[1])>>			conv2D_out_scal) 	   +
					(((matrix[i-1][j+1]>>conv2D_scaling_factor)	* kernel[2])>>			conv2D_out_scal) 	   +
					(((matrix[i][j]	>>conv2D_scaling_factor)	* kernel[4])>>			conv2D_out_scal) 	   +
					(((matrix[i][j+1]>>conv2D_scaling_factor)	* kernel[5])>>			conv2D_out_scal) 	   +
					(((matrix[i+1][j] >>conv2D_scaling_factor)	* kernel[7])>>			conv2D_out_scal) 	   +
					(((matrix[i+1][j+1]>>conv2D_scaling_factor) * kernel[8])>>			conv2D_out_scal) 	  ;
	}
		//printf("out[%d]=%d\n",pt,(int)out[pt]);
	if(print){
		printf("dopo kernel F-ACGI-D\n");
	for (int rig=0;rig<size;rig++){
		for (int col=0;col<size;col++){
			printf("%d\t",out[rig*size+col]);
			}printf("\n");
		}
	}
	///////////////////////////////////
	// kernel 										E centrale
	for (i = 1; i < size-1; i++)
	{
		for (j = 1; j < size-1; j++)
		{
			pt=i*size+j;
			out[pt] +=	(	(	(matrix[i-1][j-1]>>conv2D_scaling_factor) 	* kernel[0])>>		conv2D_out_scal)    +
						(	(	(matrix[i-1][j]	>>conv2D_scaling_factor)	* kernel[1])>>		conv2D_out_scal)    +
						(	(	(matrix[i-1][j+1]>>conv2D_scaling_factor)		* kernel[2])>>		conv2D_out_scal)    +
						(	(	(matrix[i][j-1]	>>conv2D_scaling_factor)	* kernel[3])>>		conv2D_out_scal)    +
						(	(	(matrix[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>		conv2D_out_scal)    +
						(	(	(matrix[i][j+1]	>>conv2D_scaling_factor)	* kernel[5])>>		conv2D_out_scal)    +
						(	(	(matrix[i+1][j-1]>>conv2D_scaling_factor) 	* kernel[6])>>		conv2D_out_scal)    +
						(	(	(matrix[i+1][j] >>conv2D_scaling_factor)		* kernel[7])>>		conv2D_out_scal)    +
						(	(	(matrix[i+1][j+1]>>conv2D_scaling_factor) 	* kernel[8])>>		conv2D_out_scal)   ;
		}
	}
	if(print){
		printf("dopo kernel F-ACGI-D-E\n");
		for (int rig=0;rig<size;rig++){
			for (int col=0;col<size;col++){
				printf("%d\t",out[rig*size+col]);
			}printf("\n");
		}
	}
	///////////////////////////////////
	//scandisci tutta la prima riga tra i due		 vertici alti 	B
	i=0;
	for (j = 1; j < size-1; j++)
	{
		pt=i*size+j;
		out[pt] +=	(((matrix[i][j-1]>>conv2D_scaling_factor)	* kernel[3])>>			conv2D_out_scal) 	  +
					(((matrix[i][j]	>>conv2D_scaling_factor)	* kernel[4])>>			conv2D_out_scal) 	  +
					(((matrix[i][j+1]>>conv2D_scaling_factor)	* kernel[5])>>			conv2D_out_scal) 	  +
					(((matrix[i+1][j-1]>>conv2D_scaling_factor) * kernel[6])>>			conv2D_out_scal) 	  +
					(((matrix[i+1][j] >>conv2D_scaling_factor)	* kernel[7])>>			conv2D_out_scal) 	  +
					(((matrix[i+1][j+1]>>conv2D_scaling_factor) * kernel[8])>>			conv2D_out_scal) 	 ;
	}
		//printf("out[%d]=%d\n",pt,(int)out[pt]);
	if(print){
		printf("dopo kernel F-ACGI-D-E-B\n");
		for (int rig=0;rig<size;rig++){
			for (int col=0;col<size;col++){
				printf("%d\t",out[rig*size+col]);
			}printf("\n");
		}
	}
	///////////////////////////////////
	//scandisci tutta l'ultima riga tra i due vertici bassi	 H
	i=size-1;
	for (j = 1; j < size-1; j++)
	{
		pt=i*size+j;
		out[pt] +=	(((matrix[i-1][j-1]>>conv2D_scaling_factor) 	* kernel[0])>>		conv2D_out_scal)  +
					(((matrix[i-1][j]	>>conv2D_scaling_factor)	* kernel[1])>>		conv2D_out_scal)  +
					(((matrix[i-1][j+1]>>conv2D_scaling_factor)		* kernel[2])>>		conv2D_out_scal)  +
					(((matrix[i][j-1]	>>conv2D_scaling_factor)	* kernel[3])>>		conv2D_out_scal)  +
					(((matrix[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>		conv2D_out_scal)  +
					(((matrix[i][j+1]	>>conv2D_scaling_factor)	* kernel[5])>>		conv2D_out_scal) ;
	}
		//printf("out[%d]=%d\n",pt,(int)out[pt]);
	if(print){
		printf("dopo kernel F-ACGI-D-E-B-H\n");
		for (int rig=0;rig<size;rig++){
			for (int col=0;col<size;col++){
				printf("%d\t",out[rig*size+col]);
			}printf("\n");
		}
	}
}
//base algorithm for check pourposes
void matrix_check( int* mat1, int* mat2, int size )
{
	printf("Checking if there is an error...");
  int err=0;
	for(int i=0; i<size; i++)
	{
		for(int j=0; j<size; j++)
		{
			if ( *((int*)mat1+i*size+j) != *((int*)mat2+i*size+j) ) {
				printf("\nERROR at elements [%d][%d] !\n",i,j);
        err++;

			}
		}
	}
  if (err==0){
    printf("No errors.\n");
  }
}

void matrix_check_thread( int* mat1, int* mat2, int size, int thread)
{
	warn[thread]=0;
	// printf("Checking if there is an error...");
  int err=0;
	for(int i=0; i<size; i++)
	{
		for(int j=0; j<size; j++)
		{
			if ( *((int*)mat1+i*size+j) != *((int*)mat2+i*size+j) )
			{
				warn[thread]=1;
			}
		}
	}
  // if (err==0){
  //   printf("No errors.\n");
  // }
}
void matrix_check_v2( int* mat1, int* mat2, int size)
{
	printf("Checking if there is an error (V2)...\n");
  int err=0;
	for(int i=0; i<size; i++)
	{
		for(int j=0; j<size; j++)
		{
			if ( *((int*)mat1+i*size+j) != *((int*)mat2+i*size+j) ) {
				printf("\t{%3d}",*((int*)mat1+i*size+j));
        err++;
			}
      else{
        printf("\t%5d",*((int*)mat1+i*size+j));
      }
		}
    printf("\n");
	}
  if (err==0){
    printf("No errors.\n");
  }
}
void spegni_threads()
{
	for (int i=0;i<5;i++)
	{
		if (Klessydra_get_coreID()==0);
		else
		{
			Klessydra_WFI();
		}
	}
  printf("---Mode:Single Thread_0---\n");
}

void display_spm_matrix(int size_r,int size_c,void* pt_spm_mat)
{

	printf("\n--------------------------------------\n");
  printf("\t\t-------Display_matrix 0x_@-----\n",pt_spm_mat);
  int pref_buff[32*32]={0};
  kmemstr((int*)pref_buff, (void*)(pt_spm_mat), (size_r*size_c)*sizeof(int));

  // int k=0,quad=0,temp=0;
  for(int i=0; i<size_r; i++)
  {
    for(int j=0; j<size_c; j++)
    {
      // kmemstr((void*)pref_buff, ( (void*)((int*)pt_spm_mat + (i*size_r)+j ) ), 1*sizeof(int));
      // printf("\t%02d",pref_buff+i*size_r+j));
      printf("\t%d",pref_buff[i*size_r+j]);
    }
    printf("\n");
  }
  // free(pref_buff);
  // printf("\t\t-------Display_matrix 0x_@%d-----\n",pt_spm_mat);
  printf("\t\t-------Display_matrix 0x_@-----\n");
  printf("--------------------------------------\n\n");

	/*
	int *pref_buff=(int*)malloc(sizeof(int)*size_r*size_c);
  kmemstr( pref_buff, (void*)(pt_spm_mat), (size_r*size_c)*sizeof(int));
	for(int i=0; i<size_r;i++){
			for(int j=0;j<size_c;j++){
					printf("\t%d",pref_buff[i*size_r+j]);
			}printf("\n");
	}
	free(pref_buff);
	*/
}
void matrix_print(int* pt, int size, int mode)
{
	for(int i=0; i<size; i++)
	{
		for(int j=0; j<size; j++)
		{
			if (mode==0){
				printf("\t%02d",*((int*)pt+i*size+j));
			}
			else{
				printf("\t0x%08x", *(int*)(&pt[i*size+j])	);
			}
		}
		printf("\n");
	}
}
//----------------------------------------------------------------------------------------------------
void convolution2D_SPM_off_NOB_print_region_1(void* spm_dest, 	 void* spm_fm,	 void* spm_krn,	 void* spm_temp,  int size)
{
	int print_F		=0;
	int print_ACGI=0;
	int print_D		=0;
	int print_E		=0;
	int print_B		=0;
	int print_H		=1;
  //Pointers to Spms and other index that i'll need for the convolution
	int backward_space=100;
	void* spmaddrAoff= (void*)(spm_fm);
	void* spmaddrBoff= (void*)(spm_krn );
	void* spmaddrCoff= (void*)(spm_dest);
	// void* spmaddrDoff= (void*)(spm_temp);
	void* spmaddrDoff= (void*)((int*)spmaddrC-backward_space*1);

	void* dest_in_C;
  void* dest_in_B;
  void* dest_in_D;

  int k_element=0;
  int mat_int_shift=0; //internal shifting for properly pointing insied the spms while making kaddv

	int jump_kr_row=3; // determina il salto della riga per la matrice kernel zeropadded
	int kern_offset=0;
	int fm_offset=0;
  int zero=0;

	int reg_0=size/3;
	int reg_1=reg_0+reg_0;

	// switch(size){
		// case 16:
				// reg_0=	0 + 5;
				// reg_1=	reg_0+5;
			// break;
		// default:
			// break;
	// }
	//______________________________sub_kernel F
  CSR_MVSIZE(2*SIZE_OF_INT);
	kern_offset	=	0;
	fm_offset= (size-1-1);
	// for(int i=1; i< size-1;i++){
	for(int i=1; i< reg_0;i++){
		dest_in_C	= (void*)spmaddrCoff + SIZE_OF_INT*(size*i)+ SIZE_OF_INT*(1)*(size-1);
		dest_in_D	= (void*)spmaddrDoff;
		kdotpps		(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(i-1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(0)*jump_kr_row+	kern_offset ) );
    kaddv(dest_in_C, dest_in_C, dest_in_D);
		kdotpps		(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(i)*size				+fm_offset	),	(void*) ( (int*)spmaddrBoff+(1)*jump_kr_row+	kern_offset )	);
    kaddv(dest_in_C, dest_in_C, dest_in_D);
		kdotpps		(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(i+1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(2)*jump_kr_row+	kern_offset )	);
		kaddv(dest_in_C, dest_in_C, dest_in_D);
	}
	if(print_global_dbg && print_global_id%64 == 0 && print_global_k%8 == 0 && print_F){
		printf("Primo ciclo spmC dopo kernel F\n");
		display_spm_matrix(size,size, (void*)spmaddrCoff);
	}

  //______________________________sub_kernel___________A-C-G-I
	CSR_MVSIZE(2*SIZE_OF_INT);
  //______________________________sub_kernel A
	dest_in_C	=		(void*)spmaddrCoff + SIZE_OF_INT*(0)*(size-1); //[0]
	dest_in_D	=		(void*)spmaddrDoff + SIZE_OF_INT*(4);
	kern_offset	=	1;
	fm_offset		=	0;
	kdotpps(dest_in_D + SIZE_OF_INT*(0),		(void*)(	(int*)spmaddrAoff+	(0)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(1)*jump_kr_row+	kern_offset ));
	kdotpps(dest_in_D + SIZE_OF_INT*(1),		(void*)(	(int*)spmaddrAoff+	(1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(2)*jump_kr_row+	kern_offset ));
	//______________________________sub_kernel C
	dest_in_C	=		(void*)spmaddrCoff + SIZE_OF_INT*(1)*(size-1); //[4]
	dest_in_D	=		(void*)spmaddrDoff + SIZE_OF_INT*(4);
	kern_offset	=	0;
	fm_offset		=	(size-1-1);
	kdotpps(dest_in_D + SIZE_OF_INT*(2),		(void*)(	(int*)spmaddrAoff+	(0)*size			+ fm_offset	),	(void*) ( (int*)spmaddrBoff+(1)*jump_kr_row+	kern_offset ));
	kdotpps(dest_in_D + SIZE_OF_INT*(3),		(void*)(	(int*)spmaddrAoff+	(1)*size			+ fm_offset	),	(void*) ( (int*)spmaddrBoff+(2)*jump_kr_row+	kern_offset ));

	// //______________________________sub_kernel G
	// dest_in_C	=		(void*)spmaddrCoff + SIZE_OF_INT*(size)*(size-1); //[20]
	// dest_in_D	=		(void*)spmaddrDoff + SIZE_OF_INT*(size)*(size-1);
	// kern_offset	=	1;
	// fm_offset		=	0;
	// kdotpps(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(size-1-1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(0)*jump_kr_row+	kern_offset ));
	// kdotpps(dest_in_D+4,		(void*)(	(int*)spmaddrAoff+	(size-1)	*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(1)*jump_kr_row+	kern_offset ));
	// //______________________________sub_kernel I
	// dest_in_C	=		(void*)spmaddrCoff + SIZE_OF_INT*(size+1)*(size-1); //[24]
	// dest_in_D	=		(void*)spmaddrDoff + SIZE_OF_INT*(size+1)*(size-1);
	// kern_offset	=	0;
	// fm_offset		=	(size-1-1);
	// kdotpps(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(size-1-1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(0)*jump_kr_row+	kern_offset ));
	// kdotpps(dest_in_D-4,		(void*)(	(int*)spmaddrAoff+	(size-1)	*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(1)*jump_kr_row+	kern_offset ));

	// //______________________________sommo i parziali prodotti dei sub_kernels A-C-G-I
	CSR_MVSIZE(1*SIZE_OF_INT);

	kaddv((void*)spmaddrCoff + SIZE_OF_INT*(0)*(size-1),	    	(void*)spmaddrCoff + SIZE_OF_INT*(0)*(size-1),	       	(void*)spmaddrDoff +4*SIZE_OF_INT+ SIZE_OF_INT*(0)	);
  kaddv((void*)spmaddrCoff + SIZE_OF_INT*(1)*(size-1),	    	(void*)spmaddrCoff + SIZE_OF_INT*(1)*(size-1),        	(void*)spmaddrDoff +4*SIZE_OF_INT+ SIZE_OF_INT*(2)	);
  // kaddv((void*)spmaddrCoff + SIZE_OF_INT*(size)*(size-1),			(void*)spmaddrCoff + SIZE_OF_INT*(size)*(size-1),  			(void*)spmaddrDoff + SIZE_OF_INT*(size)*(size-1));
  // kaddv((void*)spmaddrCoff + SIZE_OF_INT*(size+1)*(size-1),		(void*)spmaddrCoff + SIZE_OF_INT*(size+1)*(size-1),			(void*)spmaddrDoff + SIZE_OF_INT*(size+1)*(size-1));

  kaddv((void*)spmaddrCoff + SIZE_OF_INT*(0)*(size-1),	    	(void*)spmaddrCoff + SIZE_OF_INT*(0)*(size-1),	    	  	(void*)spmaddrDoff +4*SIZE_OF_INT+ SIZE_OF_INT*(1)	);
  kaddv((void*)spmaddrCoff + SIZE_OF_INT*(1)*(size-1),	    	(void*)spmaddrCoff + SIZE_OF_INT*(1)*(size-1),      		 	(void*)spmaddrDoff +4*SIZE_OF_INT+ SIZE_OF_INT*(3)	);
  // kaddv((void*)spmaddrCoff + SIZE_OF_INT*(size)*(size-1),			(void*)spmaddrCoff + SIZE_OF_INT*(size)*(size-1),  				(void*)spmaddrDoff + SIZE_OF_INT*(size)*(size-1) +4	);
  // kaddv((void*)spmaddrCoff + SIZE_OF_INT*(size+1)*(size-1),		(void*)spmaddrCoff + SIZE_OF_INT*(size+1)*(size-1),				(void*)spmaddrDoff + SIZE_OF_INT*(size+1)*(size-1) -4	);

	if(print_global_dbg && print_global_id%64 == 0 && print_global_k%8 == 0&& print_ACGI){
		printf("Primo ciclo spmC dopo kernel F-ACGI\n");
		display_spm_matrix(size,size, (void*)spmaddrCoff);
	}

	//______________________________sub_kernel D
	dest_in_D	=		(void*)spmaddrDoff;
  CSR_MVSIZE(2*SIZE_OF_INT);
	kern_offset	=	1;
	fm_offset		=	0;
	// for(int i=1; i< size-1;i++){
	for(int i=1; i< reg_0;i++){
		dest_in_C	= (void*)spmaddrCoff + SIZE_OF_INT*(size*i);
		dest_in_D	= (void*)spmaddrDoff;
		kdotpps(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(i-1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(0)*jump_kr_row+	kern_offset ));
		kaddv(dest_in_C, dest_in_C, dest_in_D);
		kdotpps(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(i)*size				+fm_offset	),	(void*) ( (int*)spmaddrBoff+(1)*jump_kr_row+	kern_offset ));
    kaddv(dest_in_C, dest_in_C, dest_in_D);
		kdotpps(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(i+1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(2)*jump_kr_row+	kern_offset ));
    kaddv(dest_in_C, dest_in_C, dest_in_D);
	}
	if(print_global_dbg && print_global_id%64 == 0 && print_global_k%8 == 0&& print_D){
		printf("Primo ciclo spmC dopo kernel F-ACGI-D\n");
		display_spm_matrix(size,size, (void*)spmaddrCoff);
  }


	//______________________________sub_kernel E
	// CSR_MVSIZE(backward_space*SIZE_OF_INT);
	// ksvmulrf((void*)spmaddrDoff,(void*)spmaddrDoff,(void*)zero);
	CSR_MVSIZE((size-2)*SIZE_OF_INT);
	// for(int i=1; i< size-1;i++)
	for(int i=1; i< reg_0;i++)
	{
		k_element=0;
		for (int rw_pt=-1; rw_pt<2; rw_pt++) //rw_pt is an index i use to point to the correct row, regarding this loop that is executed three times
		//instead of making 9 different ksvmulrf
		{
			ksvmulsc((void*)(	(int*)	(spmaddrDoff)	),
			(void*)	( (int*)spmaddrAoff + (i+rw_pt)*size	+0 ),
			(void*)	( (int*)spmaddrBoff+k_element++) );

			ksrav((void*)(	(int*)	(spmaddrDoff)	) ,
			(void*)(	(int*)	(spmaddrDoff)	) ,
			(int*)conv2D_out_scal);

			kaddv ((void*)(	(int*)	(spmaddrCoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
			(void*)(	(int*)	(spmaddrCoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
			(void*)(	(int*)	(spmaddrDoff)	) );

			ksvmulsc((void*)(	(int*)	(spmaddrDoff)	) ,
			(void*)	( (int*)spmaddrAoff + (i+rw_pt)*size	+1 ),
			(void*)	( (int*)spmaddrBoff+k_element++) );

			ksrav((void*)(	(int*)	(spmaddrDoff)	) ,
			(void*)(	(int*)	(spmaddrDoff)	) ,
			(int*)conv2D_out_scal);

			kaddv ((void*)(	(int*)	(spmaddrCoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
			(void*)(	(int*)	(spmaddrCoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
			(void*)(	(int*)	(spmaddrDoff)	) );

			ksvmulsc((void*)(	(int*)	(spmaddrDoff)	) ,
			(void*)	( (int*)spmaddrAoff + (i+rw_pt)*size	+2 ),
			(void*)	( (int*)spmaddrBoff+k_element++) );

			ksrav((void*)(	(int*)	(spmaddrDoff)	) ,
			(void*)(	(int*)	(spmaddrDoff)	) ,
			(int*)conv2D_out_scal);

			kaddv ((void*)(	(int*)	(spmaddrCoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
			(void*)(	(int*)	(spmaddrCoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
			(void*)(	(int*)	(spmaddrDoff)	) );
		}
	}
	if(print_global_dbg && print_global_id%64 == 0 && print_global_k%8 == 0 && print_E){
		printf("Primo ciclo spmC dopo kernel F-ACGI-D-E\n");
		display_spm_matrix(size,size, (void*)spmaddrCoff);
	}


	// //______________________________sub_kernel B
  // CSR_MVSIZE((size-2)*SIZE_OF_INT);
  for(int i=0; i< 1;i++)
  {
    dest_in_C	= (void*)spmaddrCoff  + 1*SIZE_OF_INT;
    dest_in_D	= (void*)spmaddrDoff;
    k_element=3;
    for (int rw_pt=0; rw_pt<2; rw_pt++) //rw_pt is an index i use to point to the correct row, regarding this loop that is executed three times
    //instead of making 9 different ksvmulrf
    {
      ksvmulsc(dest_in_D,			(void*)	( (int*)spmaddrAoff + (i+rw_pt)*size	+0 ),	(void*)	( (int*)spmaddrBoff+k_element++) );
					ksrav(dest_in_D,	dest_in_D,	(int*)conv2D_out_scal);
      kaddv (dest_in_C, dest_in_C,  dest_in_D);
      ksvmulsc(dest_in_D,			(void*)	( (int*)spmaddrAoff + (i+rw_pt)*size	+1 ),	(void*)	( (int*)spmaddrBoff+k_element++) );
					ksrav(dest_in_D,	dest_in_D,	(int*)conv2D_out_scal);
      kaddv	(dest_in_C, dest_in_C,  dest_in_D);
      ksvmulsc(dest_in_D,			(void*)	( (int*)spmaddrAoff + (i+rw_pt)*size	+2 ),	(void*)	( (int*)spmaddrBoff+k_element++) );
					ksrav(dest_in_D,	dest_in_D,	(int*)conv2D_out_scal);
      kaddv (dest_in_C, dest_in_C,  dest_in_D);
    }
  }

	//AAAAAA
	CSR_MVSIZE(backward_space*SIZE_OF_INT);
	ksvmulrf((void*)spmaddrDoff,(void*)spmaddrDoff,(void*)zero);
	// k_element=0;
	// CSR_MVSIZE(size*size*SIZE_OF_INT);
	// kbcast((void*)spmaddrDoff,(void*)k_element);
}
void convolution2D_SPM_off_NOB_print_region_2(void* spm_dest, 	 void* spm_fm,	 void* spm_krn,	 void* spm_temp,  int size)
{
	int print_F		=0;
	int print_ACGI=0;
	int print_D		=0;
	int print_E		=0;
	int print_B		=0;
	int print_H		=1;
  //Pointers to Spms and other index that i'll need for the convolution
	int backward_space=100;
	void* spmaddrAoff= (void*)(spm_fm);
	void* spmaddrBoff= (void*)(spm_krn );
	void* spmaddrCoff= (void*)(spm_dest);
	// void* spmaddrDoff= (void*)(spm_temp);
	void* spmaddrDoff= (void*)((int*)spmaddrC-backward_space*2);

	void* dest_in_C;
  void* dest_in_B;
  void* dest_in_D;

  int k_element=0;
  int mat_int_shift=0; //internal shifting for properly pointing insied the spms while making kaddv

	int jump_kr_row=3; // determina il salto della riga per la matrice kernel zeropadded
	int kern_offset=0;
	int fm_offset=0;
  int zero=0;

	int reg_0=size/3;
	int reg_1=reg_0+reg_0;

	// switch(size){
		// case 16:
				// reg_0=	0 + 5;
				// reg_1=	reg_0+5;
			// break;
		// default:
			// break;
	// }
	//______________________________sub_kernel F
  CSR_MVSIZE(2*SIZE_OF_INT);
	kern_offset	=	0;
	fm_offset= (size-1-1);
	// for(int i=1; i< size-1;i++){
	for(int i=reg_0; i< reg_1;i++){
		dest_in_C	= (void*)spmaddrCoff + SIZE_OF_INT*(size*i)+ SIZE_OF_INT*(1)*(size-1);
		dest_in_D	= (void*)spmaddrDoff;
		kdotpps		(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(i-1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(0)*jump_kr_row+	kern_offset ) );
    kaddv(dest_in_C, dest_in_C, dest_in_D);
		kdotpps		(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(i)*size				+fm_offset	),	(void*) ( (int*)spmaddrBoff+(1)*jump_kr_row+	kern_offset )	);
    kaddv(dest_in_C, dest_in_C, dest_in_D);
		kdotpps		(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(i+1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(2)*jump_kr_row+	kern_offset )	);
		kaddv(dest_in_C, dest_in_C, dest_in_D);
	}
	if(print_global_dbg && print_global_id%64 == 0 && print_global_k%8 == 0 && print_F){
		printf("Primo ciclo spmC dopo kernel F\n");
		display_spm_matrix(size,size, (void*)spmaddrCoff);
	}



	//______________________________sub_kernel D
  CSR_MVSIZE(2*SIZE_OF_INT);
	kern_offset	=	1;
	fm_offset		=	0;
	// for(int i=1; i< size-1;i++){
	for(int i=reg_0; i< reg_1;i++){
		dest_in_C	= (void*)spmaddrCoff + SIZE_OF_INT*(size*i);
		dest_in_D	= (void*)spmaddrDoff;
		kdotpps(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(i-1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(0)*jump_kr_row+	kern_offset ));
		kaddv(dest_in_C, dest_in_C, dest_in_D);
		kdotpps(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(i)*size				+fm_offset	),	(void*) ( (int*)spmaddrBoff+(1)*jump_kr_row+	kern_offset ));
    kaddv(dest_in_C, dest_in_C, dest_in_D);
		kdotpps(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(i+1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(2)*jump_kr_row+	kern_offset ));
    kaddv(dest_in_C, dest_in_C, dest_in_D);
	}
	if(print_global_dbg && print_global_id%64 == 0 && print_global_k%8 == 0&& print_D){
		printf("Primo ciclo spmC dopo kernel F-ACGI-D\n");
		display_spm_matrix(size,size, (void*)spmaddrCoff);
  }


  //______________________________sub_kernel E
  CSR_MVSIZE((size-2)*SIZE_OF_INT);
	// for(int i=1; i< size-1;i++)
	for(int i=reg_0; i< reg_1;i++)
	{
		k_element=0;
		for (int rw_pt=-1; rw_pt<2; rw_pt++) //rw_pt is an index i use to point to the correct row, regarding this loop that is executed three times
		//instead of making 9 different ksvmulrf
		{
			ksvmulsc((void*)(	(int*)	(spmaddrDoff)	) ,
        			  (void*)	( (int*)spmaddrAoff + (i+rw_pt)*size	+0 ),
                (void*)	( (int*)spmaddrBoff+k_element++) );

				ksrav((void*)(	(int*)	(spmaddrDoff)	) ,
								(void*)(	(int*)	(spmaddrDoff)	) ,
								(int*)conv2D_out_scal);

  		kaddv ((void*)(	(int*)	(spmaddrCoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
              (void*)(	(int*)	(spmaddrCoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
              (void*)(	(int*)	(spmaddrDoff)	) );

			ksvmulsc((void*)(	(int*)	(spmaddrDoff)	) ,
        			  (void*)	( (int*)spmaddrAoff + (i+rw_pt)*size	+1 ),
                (void*)	( (int*)spmaddrBoff+k_element++) );

				ksrav((void*)(	(int*)	(spmaddrDoff)	) ,
								(void*)(	(int*)	(spmaddrDoff)	) ,
								(int*)conv2D_out_scal);

  		kaddv ((void*)(	(int*)	(spmaddrCoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
              (void*)(	(int*)	(spmaddrCoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
              (void*)(	(int*)	(spmaddrDoff)	) );

			ksvmulsc((void*)(	(int*)	(spmaddrDoff)	) ,
        			  (void*)	( (int*)spmaddrAoff + (i+rw_pt)*size	+2 ),
                (void*)	( (int*)spmaddrBoff+k_element++) );

				ksrav((void*)(	(int*)	(spmaddrDoff)	) ,
								(void*)(	(int*)	(spmaddrDoff)	) ,
								(int*)conv2D_out_scal);

  		kaddv ((void*)(	(int*)	(spmaddrCoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
              (void*)(	(int*)	(spmaddrCoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
              (void*)(	(int*)	(spmaddrDoff)	) );
		}
	}
	if(print_global_dbg && print_global_id%64 == 0 && print_global_k%8 == 0 && print_E){
		printf("Primo ciclo spmC dopo kernel F-ACGI-D-E\n");
		display_spm_matrix(size,size, (void*)spmaddrCoff);
  }



	CSR_MVSIZE(backward_space*SIZE_OF_INT);
	ksvmulrf((void*)spmaddrDoff,(void*)spmaddrDoff,(void*)zero);
	// k_element=0;
	// CSR_MVSIZE(size*size*SIZE_OF_INT);
	// kbcast((void*)spmaddrDoff,(void*)k_element);
}
void convolution2D_SPM_off_NOB_print_region_3(void* spm_dest, 	 void* spm_fm,	 void* spm_krn,	 void* spm_temp,  int size)
{
	int print_F		=0;
	int print_ACGI=0;
	int print_D		=0;
	int print_E		=0;
	int print_B		=0;
	int print_H		=1;
  //Pointers to Spms and other index that i'll need for the convolution
	int backward_space=100;
	void* spmaddrAoff= (void*)(spm_fm);
	void* spmaddrBoff= (void*)(spm_krn );
	void* spmaddrCoff= (void*)(spm_dest);
	// void* spmaddrDoff= (void*)(spm_temp);
	void* spmaddrDoff= (void*)((int*)spmaddrC-backward_space*3);

	void* dest_in_C;
  void* dest_in_B;
  void* dest_in_D;

  int k_element=0;
  int mat_int_shift=0; //internal shifting for properly pointing insied the spms while making kaddv

	int jump_kr_row=3; // determina il salto della riga per la matrice kernel zeropadded
	int kern_offset=0;
	int fm_offset=0;
  int zero=0;

	int reg_0=size/3;
	int reg_1=reg_0+reg_0;

	// switch(size){
		// case 16:
				// reg_0=	0 + 5;
				// reg_1=	reg_0+5;
			// break;
		// default:
			// break;
	// }

	//______________________________sub_kernel F
  CSR_MVSIZE(2*SIZE_OF_INT);
	kern_offset	=	0;
	fm_offset= (size-1-1);
	// for(int i=1; i< size-1;i++){
	for(int i=reg_1; i< size-1;i++){
		dest_in_C	= (void*)spmaddrCoff + SIZE_OF_INT*(size*i)+ SIZE_OF_INT*(1)*(size-1);
		dest_in_D	= (void*)spmaddrDoff;
		kdotpps		(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(i-1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(0)*jump_kr_row+	kern_offset ) );
    kaddv(dest_in_C, dest_in_C, dest_in_D);
		kdotpps		(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(i)*size				+fm_offset	),	(void*) ( (int*)spmaddrBoff+(1)*jump_kr_row+	kern_offset )	);
    kaddv(dest_in_C, dest_in_C, dest_in_D);
		kdotpps		(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(i+1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(2)*jump_kr_row+	kern_offset )	);
		kaddv(dest_in_C, dest_in_C, dest_in_D);
	}
	if(print_global_dbg && print_global_id%64 == 0 && print_global_k%8 == 0 && print_F){
		printf("Primo ciclo spmC dopo kernel F\n");
		display_spm_matrix(size,size, (void*)spmaddrCoff);
	}

  //______________________________sub_kernel___________A-C-G-I
	CSR_MVSIZE(2*SIZE_OF_INT);
  // //______________________________sub_kernel A
	// dest_in_C	=		(void*)spmaddrCoff + SIZE_OF_INT*(0)*(size-1); //[0]
	// dest_in_D	=		(void*)spmaddrDoff + SIZE_OF_INT*(0)*(size-1);
	// kern_offset	=	1;
	// fm_offset		=	0;
	// kdotpps(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(0)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(1)*jump_kr_row+	kern_offset ));
	// kdotpps(dest_in_D+4,		(void*)(	(int*)spmaddrAoff+	(1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(2)*jump_kr_row+	kern_offset ));
	// //______________________________sub_kernel C
	// dest_in_C	=		(void*)spmaddrCoff + SIZE_OF_INT*(1)*(size-1); //[4]
	// dest_in_D	=		(void*)spmaddrDoff + SIZE_OF_INT*(1)*(size-1);
	// kern_offset	=	0;
	// fm_offset		=	(size-1-1);
	// kdotpps(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(0)*size			+ fm_offset	),	(void*) ( (int*)spmaddrBoff+(1)*jump_kr_row+	kern_offset ));
	// kdotpps(dest_in_D-4,		(void*)(	(int*)spmaddrAoff+	(1)*size			+ fm_offset	),	(void*) ( (int*)spmaddrBoff+(2)*jump_kr_row+	kern_offset ));
	//______________________________sub_kernel G
	dest_in_C	=		(void*)spmaddrCoff + SIZE_OF_INT*(size)*(size-1); //[20]
	dest_in_D	=		(void*)spmaddrDoff + SIZE_OF_INT*(4);
	kern_offset	=	1;
	fm_offset		=	0;
	kdotpps(dest_in_D + SIZE_OF_INT*(0),		(void*)(	(int*)spmaddrAoff+	(size-1-1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(0)*jump_kr_row+	kern_offset ));
	kdotpps(dest_in_D + SIZE_OF_INT*(1),		(void*)(	(int*)spmaddrAoff+	(size-1)	*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(1)*jump_kr_row+	kern_offset ));
	//______________________________sub_kernel I
	dest_in_C	=		(void*)spmaddrCoff + SIZE_OF_INT*(size+1)*(size-1); //[24]
	dest_in_D	=		(void*)spmaddrDoff + SIZE_OF_INT*(4);
	kern_offset	=	0;
	fm_offset		=	(size-1-1);
	kdotpps(dest_in_D + SIZE_OF_INT*(2),		(void*)(	(int*)spmaddrAoff+	(size-1-1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(0)*jump_kr_row+	kern_offset ));
	kdotpps(dest_in_D + SIZE_OF_INT*(3),		(void*)(	(int*)spmaddrAoff+	(size-1)	*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(1)*jump_kr_row+	kern_offset ));

	// //______________________________sommo i parziali prodotti dei sub_kernels A-C-G-I
	CSR_MVSIZE(1*SIZE_OF_INT);

	// kaddv((void*)spmaddrCoff + SIZE_OF_INT*(0)*(size-1),	    	(void*)spmaddrCoff + SIZE_OF_INT*(0)*(size-1),	       	(void*)spmaddrDoff + SIZE_OF_INT*(0)*(size-1));
  // kaddv((void*)spmaddrCoff + SIZE_OF_INT*(1)*(size-1),	    	(void*)spmaddrCoff + SIZE_OF_INT*(1)*(size-1),        	(void*)spmaddrDoff + SIZE_OF_INT*(1)*(size-1));
  kaddv((void*)spmaddrCoff + SIZE_OF_INT*(size)*(size-1),			(void*)spmaddrCoff + SIZE_OF_INT*(size)*(size-1),  			(void*)spmaddrDoff +4*SIZE_OF_INT+ SIZE_OF_INT*(0)	);
  kaddv((void*)spmaddrCoff + SIZE_OF_INT*(size+1)*(size-1),		(void*)spmaddrCoff + SIZE_OF_INT*(size+1)*(size-1),			(void*)spmaddrDoff +4*SIZE_OF_INT+ SIZE_OF_INT*(2)	);

  // kaddv((void*)spmaddrCoff + SIZE_OF_INT*(0)*(size-1),	    	(void*)spmaddrCoff + SIZE_OF_INT*(0)*(size-1),	    	  	(void*)spmaddrDoff + SIZE_OF_INT*(0)*(size-1) + 4	);
  // kaddv((void*)spmaddrCoff + SIZE_OF_INT*(1)*(size-1),	    	(void*)spmaddrCoff + SIZE_OF_INT*(1)*(size-1),      		 	(void*)spmaddrDoff + SIZE_OF_INT*(1)*(size-1) - 4	);
  kaddv((void*)spmaddrCoff + SIZE_OF_INT*(size)*(size-1),			(void*)spmaddrCoff + SIZE_OF_INT*(size)*(size-1),  				(void*)spmaddrDoff +4*SIZE_OF_INT+ SIZE_OF_INT*(1)	);
  kaddv((void*)spmaddrCoff + SIZE_OF_INT*(size+1)*(size-1),		(void*)spmaddrCoff + SIZE_OF_INT*(size+1)*(size-1),				(void*)spmaddrDoff +4*SIZE_OF_INT+ SIZE_OF_INT*(3)	);

	if(print_global_dbg && print_global_id%64 == 0 && print_global_k%8 == 0&& print_ACGI){
		printf("Primo ciclo spmC dopo kernel F-ACGI\n");
		display_spm_matrix(size,size, (void*)spmaddrCoff);
	}


	//______________________________sub_kernel D
	dest_in_D	=		(void*)spmaddrDoff;
  CSR_MVSIZE(2*SIZE_OF_INT);
	kern_offset	=	1;
	fm_offset		=	0;
	// for(int i=1; i< size-1;i++){
	for(int i=reg_1; i< size-1;i++){
		dest_in_C	= (void*)spmaddrCoff + SIZE_OF_INT*(size*i);
		dest_in_D	= (void*)spmaddrDoff;
		kdotpps(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(i-1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(0)*jump_kr_row+	kern_offset ));
		kaddv(dest_in_C, dest_in_C, dest_in_D);
		kdotpps(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(i)*size				+fm_offset	),	(void*) ( (int*)spmaddrBoff+(1)*jump_kr_row+	kern_offset ));
    kaddv(dest_in_C, dest_in_C, dest_in_D);
		kdotpps(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(i+1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(2)*jump_kr_row+	kern_offset ));
    kaddv(dest_in_C, dest_in_C, dest_in_D);
	}
	if(print_global_dbg && print_global_id%64 == 0 && print_global_k%8 == 0&& print_D){
		printf("Primo ciclo spmC dopo kernel F-ACGI-D\n");
		display_spm_matrix(size,size, (void*)spmaddrCoff);
  }


  //______________________________sub_kernel E
  CSR_MVSIZE((size-2)*SIZE_OF_INT);
	// for(int i=1; i< size-1;i++)
	for(int i=reg_1; i< size-1;i++)
	{
		k_element=0;
		for (int rw_pt=-1; rw_pt<2; rw_pt++) //rw_pt is an index i use to point to the correct row, regarding this loop that is executed three times
		//instead of making 9 different ksvmulrf
		{
			ksvmulsc((void*)(	(int*)	(spmaddrDoff)	),
        			  (void*)	( (int*)spmaddrAoff + (i+rw_pt)*size	+0 ),
                (void*)	( (int*)spmaddrBoff+k_element++) );

				ksrav((void*)(	(int*)	(spmaddrDoff)	),
								(void*)(	(int*)	(spmaddrDoff)	),
								(int*)conv2D_out_scal);

  		kaddv ((void*)(	(int*)	(spmaddrCoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
              (void*)(	(int*)	(spmaddrCoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
              (void*)(	(int*)	(spmaddrDoff)	) );

			ksvmulsc((void*)(	(int*)	(spmaddrDoff)	),
        			  (void*)	( (int*)spmaddrAoff + (i+rw_pt)*size	+1 ),
                (void*)	( (int*)spmaddrBoff+k_element++) );

				ksrav((void*)(	(int*)	(spmaddrDoff)	),
								(void*)(	(int*)	(spmaddrDoff)	),
								(int*)conv2D_out_scal);

  		kaddv ((void*)(	(int*)	(spmaddrCoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
              (void*)(	(int*)	(spmaddrCoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
              (void*)(	(int*)	(spmaddrDoff)	) );

			ksvmulsc((void*)(	(int*)	(spmaddrDoff)	),
        			  (void*)	( (int*)spmaddrAoff + (i+rw_pt)*size	+2 ),
                (void*)	( (int*)spmaddrBoff+k_element++) );

				ksrav((void*)(	(int*)	(spmaddrDoff)	),
								(void*)(	(int*)	(spmaddrDoff)	),
								(int*)conv2D_out_scal);

  		kaddv ((void*)(	(int*)	(spmaddrCoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
              (void*)(	(int*)	(spmaddrCoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
              (void*)(	(int*)	(spmaddrDoff)	) );
		}
	}
	if(print_global_dbg && print_global_id%64 == 0 && print_global_k%8 == 0 && print_E){
		printf("Primo ciclo spmC dopo kernel F-ACGI-D-E\n");
		display_spm_matrix(size,size, (void*)spmaddrCoff);
  }



	//______________________________sub_kernel H
	for(int i=size-1; i< size;i++)
	{
		dest_in_C	= (void*)spmaddrCoff + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT;
    dest_in_D	= (void*)spmaddrDoff;
		k_element=0;
		for (int rw_pt=-1; rw_pt<1; rw_pt++) //rw_pt is an index i use to point to the correct row, regarding this loop that is executed three times
		//instead of making 9 different ksvmulrf
		{
			ksvmulsc(dest_in_D,			(void*)	( (int*)spmaddrAoff + (i+rw_pt)*size	+0 ),	(void*)	( (int*)spmaddrBoff+k_element++) );
				ksrav(dest_in_D,	dest_in_D,	(int*)conv2D_out_scal);
      kaddv	(dest_in_C, dest_in_C, dest_in_D);
			ksvmulsc(dest_in_D,			(void*)	( (int*)spmaddrAoff + (i+rw_pt)*size	+1 ),	(void*)	( (int*)spmaddrBoff+k_element++) );
				ksrav(dest_in_D,	dest_in_D,	(int*)conv2D_out_scal);
      kaddv	(dest_in_C, dest_in_C, dest_in_D);
			ksvmulsc(dest_in_D,			(void*)	( (int*)spmaddrAoff + (i+rw_pt)*size	+2 ),	(void*)	( (int*)spmaddrBoff+k_element++) );
				ksrav(dest_in_D,	dest_in_D,	(int*)conv2D_out_scal);
      kaddv	(dest_in_C, dest_in_C, dest_in_D);
		}
	}
	if(print_global_dbg && print_global_id%64 == 0 && print_global_k%8 == 0 && print_H){
		printf("Primo ciclo spmC dopo kernel F-ACGI-D-E-B-H\n");
		display_spm_matrix(size,size, (void*)spmaddrCoff);
	}

	CSR_MVSIZE(backward_space*SIZE_OF_INT);
	ksvmulrf((void*)spmaddrDoff,(void*)spmaddrDoff,(void*)zero);
	// k_element=0;
	// CSR_MVSIZE(size*size*SIZE_OF_INT);
	// kbcast((void*)spmaddrDoff,(void*)k_element);
}
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
void convolution2D_Scaling_region_1(int size, int (*matrix)[size], int *kernel_tmp, int *out)
{
	int print=0;
	int kernel[9];
	int conv2D_scaling_factor=8;
	int conv2D_out_scal=5;
	for(int i=0;i<9;i++){
    	kernel[i]=(kernel_tmp[i]>>conv2D_scaling_factor);
    }
	int i, j;
	int pt=0;
	
	int reg_0=size/3;
	int reg_1=reg_0+reg_0;
	///////////////////////////////////
	//scandisci tutta l'ultima						colonna	F
	j=(size-1);
	for(int i=1; i< reg_0;i++)
	{
		pt=i*size+j;
		out[pt] +=	(((matrix[i-1][j-1]>>conv2D_scaling_factor) 	* kernel[0])>>		conv2D_out_scal)     +
					(((matrix[i-1][j]	>>conv2D_scaling_factor)	* kernel[1])>>		conv2D_out_scal)     +
					(((matrix[i][j-1]	>>conv2D_scaling_factor)	* kernel[3])>>		conv2D_out_scal)     +
					(((matrix[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>		conv2D_out_scal)     +
					(((matrix[i+1][j-1]>>conv2D_scaling_factor) 	* kernel[6])>>		conv2D_out_scal)     +
					(((matrix[i+1][j] >>conv2D_scaling_factor)		* kernel[7])>>		conv2D_out_scal)    ;
	}
	if(print){
		printf("dopo kernel F\n");
		for (int rig=0;rig<size;rig++){
			for (int col=0;col<size;col++){
				printf("%d\t",out[rig*size+col]);
			}printf("\n");
		}
	}
		//printf("out[%d]=%d\n",pt,(int)out[pt]);
	///////////////////////////////////
													//alto sinistra A
	i=0;
	j=0;
	pt=i*size+j;
		out[pt] +=	(((matrix[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>			conv2D_out_scal) 	 +
					(((matrix[i][j+1]>>conv2D_scaling_factor)		* kernel[5])>>			conv2D_out_scal)	 +
					(((matrix[i+1][j] >>conv2D_scaling_factor)		* kernel[7])>>			conv2D_out_scal)	 +
					(((matrix[i+1][j+1]>>conv2D_scaling_factor) 	* kernel[8])>>			conv2D_out_scal)	;
		//printf("out[%d]=%d\n",pt,(int)out[pt]);

	///////////////////////////////////
	//vertice alto a destra 						C
	i=0;
	j=(size-1);
	pt=i*size+j;
		out[pt] +=	(((matrix[i][j-1]>>conv2D_scaling_factor)		* kernel[3])>>			conv2D_out_scal) 	  +
					(((matrix[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>			conv2D_out_scal) 	  +
					(((matrix[i+1][j-1]>>conv2D_scaling_factor) 	* kernel[6])>>			conv2D_out_scal) 	  +
					(((matrix[i+1][j] >>conv2D_scaling_factor)		* kernel[7])>>			conv2D_out_scal) 	 ;
		//printf("out[%d]=%d\n",pt,(int)out[pt]);

	///////////////////////////////////
	//scandisci tutta la prima colonna 				D
	j=0;
	for(int i=1; i< reg_0;i++)
	{
		pt=i*size+j;
		out[pt] +=	(((matrix[i-1][j]>>conv2D_scaling_factor)	* kernel[1])>>			conv2D_out_scal) 	   +
					(((matrix[i-1][j+1]>>conv2D_scaling_factor)	* kernel[2])>>			conv2D_out_scal) 	   +
					(((matrix[i][j]	>>conv2D_scaling_factor)	* kernel[4])>>			conv2D_out_scal) 	   +
					(((matrix[i][j+1]>>conv2D_scaling_factor)	* kernel[5])>>			conv2D_out_scal) 	   +
					(((matrix[i+1][j] >>conv2D_scaling_factor)	* kernel[7])>>			conv2D_out_scal) 	   +
					(((matrix[i+1][j+1]>>conv2D_scaling_factor) * kernel[8])>>			conv2D_out_scal) 	  ;
	}
		//printf("out[%d]=%d\n",pt,(int)out[pt]);
	if(print){
		printf("dopo kernel F-ACGI-D\n");
	for (int rig=0;rig<size;rig++){
		for (int col=0;col<size;col++){
			printf("%d\t",out[rig*size+col]);
			}printf("\n");
		}
	}
	///////////////////////////////////
	// kernel 										E centrale
	for(int i=1; i< reg_0;i++)
	{
		for (j = 1; j < size-1; j++)
		{
			pt=i*size+j;
			out[pt] +=	(	(	(matrix[i-1][j-1]>>conv2D_scaling_factor) 	* kernel[0])>>		conv2D_out_scal)    +
						(	(	(matrix[i-1][j]	>>conv2D_scaling_factor)	* kernel[1])>>		conv2D_out_scal)    +
						(	(	(matrix[i-1][j+1]>>conv2D_scaling_factor)		* kernel[2])>>		conv2D_out_scal)    +
						(	(	(matrix[i][j-1]	>>conv2D_scaling_factor)	* kernel[3])>>		conv2D_out_scal)    +
						(	(	(matrix[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>		conv2D_out_scal)    +
						(	(	(matrix[i][j+1]	>>conv2D_scaling_factor)	* kernel[5])>>		conv2D_out_scal)    +
						(	(	(matrix[i+1][j-1]>>conv2D_scaling_factor) 	* kernel[6])>>		conv2D_out_scal)    +
						(	(	(matrix[i+1][j] >>conv2D_scaling_factor)		* kernel[7])>>		conv2D_out_scal)    +
						(	(	(matrix[i+1][j+1]>>conv2D_scaling_factor) 	* kernel[8])>>		conv2D_out_scal)   ;
		}
	}
	if(print){
		printf("dopo kernel F-ACGI-D-E\n");
		for (int rig=0;rig<size;rig++){
			for (int col=0;col<size;col++){
				printf("%d\t",out[rig*size+col]);
			}printf("\n");
		}
	}
	///////////////////////////////////
	//scandisci tutta la prima riga tra i due		 vertici alti 	B
	i=0;
	for (j = 1; j < size-1; j++)
	{
		pt=i*size+j;
		out[pt] +=	(((matrix[i][j-1]>>conv2D_scaling_factor)	* kernel[3])>>			conv2D_out_scal) 	  +
					(((matrix[i][j]	>>conv2D_scaling_factor)	* kernel[4])>>			conv2D_out_scal) 	  +
					(((matrix[i][j+1]>>conv2D_scaling_factor)	* kernel[5])>>			conv2D_out_scal) 	  +
					(((matrix[i+1][j-1]>>conv2D_scaling_factor) * kernel[6])>>			conv2D_out_scal) 	  +
					(((matrix[i+1][j] >>conv2D_scaling_factor)	* kernel[7])>>			conv2D_out_scal) 	  +
					(((matrix[i+1][j+1]>>conv2D_scaling_factor) * kernel[8])>>			conv2D_out_scal) 	 ;
	}
	//printf("out[%d]=%d\n",pt,(int)out[pt]);
	if(print){
		printf("dopo kernel F-ACGI-D-E-B\n");
		for (int rig=0;rig<size;rig++){
			for (int col=0;col<size;col++){
				printf("%d\t",out[rig*size+col]);
			}printf("\n");
		}
	}
	///////////////////////////////////
}
void convolution2D_Scaling_region_2(int size, int (*matrix)[size], int *kernel_tmp, int *out)
{
	int print=0;
	int kernel[9];
	int conv2D_scaling_factor=8;
	int conv2D_out_scal=5;
	for(int i=0;i<9;i++){
    	kernel[i]=(kernel_tmp[i]>>conv2D_scaling_factor);
    }
	int i, j;
	int pt=0;
	
	int reg_0=size/3;
	int reg_1=reg_0+reg_0;

	///////////////////////////////////
	//scandisci tutta l'ultima						colonna	F
	j=(size-1);
	for(int i=reg_0; i< reg_1;i++)
	{
		pt=i*size+j;
		out[pt] +=	(((matrix[i-1][j-1]>>conv2D_scaling_factor) 	* kernel[0])>>		conv2D_out_scal)     +
					(((matrix[i-1][j]	>>conv2D_scaling_factor)	* kernel[1])>>		conv2D_out_scal)     +
					(((matrix[i][j-1]	>>conv2D_scaling_factor)	* kernel[3])>>		conv2D_out_scal)     +
					(((matrix[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>		conv2D_out_scal)     +
					(((matrix[i+1][j-1]>>conv2D_scaling_factor) 	* kernel[6])>>		conv2D_out_scal)     +
					(((matrix[i+1][j] >>conv2D_scaling_factor)		* kernel[7])>>		conv2D_out_scal)    ;
	}
	if(print){
		printf("dopo kernel F\n");
		for (int rig=0;rig<size;rig++){
			for (int col=0;col<size;col++){
				printf("%d\t",out[rig*size+col]);
			}printf("\n");
		}
	}
	///////////////////////////////////
	//scandisci tutta la prima colonna 				D
	j=0;
	for(int i=reg_0; i< reg_1;i++)
	{
		pt=i*size+j;
		out[pt] +=	(((matrix[i-1][j]>>conv2D_scaling_factor)	* kernel[1])>>			conv2D_out_scal) 	   +
					(((matrix[i-1][j+1]>>conv2D_scaling_factor)	* kernel[2])>>			conv2D_out_scal) 	   +
					(((matrix[i][j]	>>conv2D_scaling_factor)	* kernel[4])>>			conv2D_out_scal) 	   +
					(((matrix[i][j+1]>>conv2D_scaling_factor)	* kernel[5])>>			conv2D_out_scal) 	   +
					(((matrix[i+1][j] >>conv2D_scaling_factor)	* kernel[7])>>			conv2D_out_scal) 	   +
					(((matrix[i+1][j+1]>>conv2D_scaling_factor) * kernel[8])>>			conv2D_out_scal) 	  ;
	}
		//printf("out[%d]=%d\n",pt,(int)out[pt]);
	if(print){
		printf("dopo kernel F-ACGI-D\n");
	for (int rig=0;rig<size;rig++){
		for (int col=0;col<size;col++){
			printf("%d\t",out[rig*size+col]);
			}printf("\n");
		}
	}
	///////////////////////////////////
	// kernel 										E centrale
	for(int i=reg_0; i< reg_1;i++)
	{
		for (j = 1; j < size-1; j++)
		{
			pt=i*size+j;
			out[pt] +=	(	(	(matrix[i-1][j-1]>>conv2D_scaling_factor) 	* kernel[0])>>		conv2D_out_scal)    +
						(	(	(matrix[i-1][j]	>>conv2D_scaling_factor)	* kernel[1])>>		conv2D_out_scal)    +
						(	(	(matrix[i-1][j+1]>>conv2D_scaling_factor)		* kernel[2])>>		conv2D_out_scal)    +
						(	(	(matrix[i][j-1]	>>conv2D_scaling_factor)	* kernel[3])>>		conv2D_out_scal)    +
						(	(	(matrix[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>		conv2D_out_scal)    +
						(	(	(matrix[i][j+1]	>>conv2D_scaling_factor)	* kernel[5])>>		conv2D_out_scal)    +
						(	(	(matrix[i+1][j-1]>>conv2D_scaling_factor) 	* kernel[6])>>		conv2D_out_scal)    +
						(	(	(matrix[i+1][j] >>conv2D_scaling_factor)		* kernel[7])>>		conv2D_out_scal)    +
						(	(	(matrix[i+1][j+1]>>conv2D_scaling_factor) 	* kernel[8])>>		conv2D_out_scal)   ;
		}
	}
	if(print){
		printf("dopo kernel F-ACGI-D-E\n");
		for (int rig=0;rig<size;rig++){
			for (int col=0;col<size;col++){
				printf("%d\t",out[rig*size+col]);
			}printf("\n");
		}
	}

}
void convolution2D_Scaling_region_3(int size, int (*matrix)[size], int *kernel_tmp, int *out)
{
	int print=0;
	int kernel[9];
	int conv2D_scaling_factor=8;
	int conv2D_out_scal=5;
	for(int i=0;i<9;i++){
    	kernel[i]=(kernel_tmp[i]>>conv2D_scaling_factor);
    }
	int i, j;
	int pt=0;
	

	int reg_0=size/3;
	int reg_1=reg_0+reg_0;

	///////////////////////////////////
	//scandisci tutta l'ultima						colonna	F
	j=(size-1);
	for(int i=reg_1; i< size-1;i++)
	{
		pt=i*size+j;
		out[pt] +=	(((matrix[i-1][j-1]>>conv2D_scaling_factor) 	* kernel[0])>>		conv2D_out_scal)     +
					(((matrix[i-1][j]	>>conv2D_scaling_factor)	* kernel[1])>>		conv2D_out_scal)     +
					(((matrix[i][j-1]	>>conv2D_scaling_factor)	* kernel[3])>>		conv2D_out_scal)     +
					(((matrix[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>		conv2D_out_scal)     +
					(((matrix[i+1][j-1]>>conv2D_scaling_factor) 	* kernel[6])>>		conv2D_out_scal)     +
					(((matrix[i+1][j] >>conv2D_scaling_factor)		* kernel[7])>>		conv2D_out_scal)    ;
	}
	if(print){
		printf("dopo kernel F\n");
		for (int rig=0;rig<size;rig++){
			for (int col=0;col<size;col++){
				printf("%d\t",out[rig*size+col]);
			}printf("\n");
		}
	}
		//printf("out[%d]=%d\n",pt,(int)out[pt]);
	///////////////////////////////////
	//in basso a 									sinistra G
	j=0;
	i=size-1;
	pt=i*size+j;
		out[pt] +=	(((matrix[i-1][j]	>>conv2D_scaling_factor)	* kernel[1])>>		conv2D_out_scal)     +
					(((matrix[i-1][j+1]>>conv2D_scaling_factor)		* kernel[2])>>		conv2D_out_scal)     +
					(((matrix[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>		conv2D_out_scal)     +
					(((matrix[i][j+1]	>>conv2D_scaling_factor)	* kernel[5])>>		conv2D_out_scal)    ;
		//printf("out[%d]=%d\n",pt,(int)out[pt]);

	///////////////////////////////////
	//in basso a 									destra	I
	i=(size-1);
	j=size-1;
	pt=i*size+j;
		out[pt] +=	(((matrix[i-1][j-1]>>conv2D_scaling_factor) 	* kernel[0])>>		conv2D_out_scal)     +
					(((matrix[i-1][j]	>>conv2D_scaling_factor)	* kernel[1])>>		conv2D_out_scal)     +
					(((matrix[i][j-1]	>>conv2D_scaling_factor)	* kernel[3])>>		conv2D_out_scal)     +
					(((matrix[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>		conv2D_out_scal)    ;
		//printf("out[%d]=%d\n",pt,(int)out[pt]);
	if(print){
		printf("dopo kernel F-ACGI\n");
		for (int rig=0;rig<size;rig++){
			for (int col=0;col<size;col++){
				printf("%d\t",out[rig*size+col]);
			}printf("\n");
		}
	}
	///////////////////////////////////
	//scandisci tutta la prima colonna 				D
	j=0;
	for(int i=reg_1; i< size-1;i++)
	{
		pt=i*size+j;
		out[pt] +=	(((matrix[i-1][j]>>conv2D_scaling_factor)	* kernel[1])>>			conv2D_out_scal) 	   +
					(((matrix[i-1][j+1]>>conv2D_scaling_factor)	* kernel[2])>>			conv2D_out_scal) 	   +
					(((matrix[i][j]	>>conv2D_scaling_factor)	* kernel[4])>>			conv2D_out_scal) 	   +
					(((matrix[i][j+1]>>conv2D_scaling_factor)	* kernel[5])>>			conv2D_out_scal) 	   +
					(((matrix[i+1][j] >>conv2D_scaling_factor)	* kernel[7])>>			conv2D_out_scal) 	   +
					(((matrix[i+1][j+1]>>conv2D_scaling_factor) * kernel[8])>>			conv2D_out_scal) 	  ;
	}
		//printf("out[%d]=%d\n",pt,(int)out[pt]);
	if(print){
		printf("dopo kernel F-ACGI-D\n");
	for (int rig=0;rig<size;rig++){
		for (int col=0;col<size;col++){
			printf("%d\t",out[rig*size+col]);
			}printf("\n");
		}
	}
	///////////////////////////////////
	// kernel 										E centrale
	for(int i=reg_1; i< size-1;i++)
	{
		for (j = 1; j < size-1; j++)
		{
			pt=i*size+j;
			out[pt] +=	(	(	(matrix[i-1][j-1]>>conv2D_scaling_factor) 	* kernel[0])>>		conv2D_out_scal)    +
						(	(	(matrix[i-1][j]	>>conv2D_scaling_factor)	* kernel[1])>>		conv2D_out_scal)    +
						(	(	(matrix[i-1][j+1]>>conv2D_scaling_factor)		* kernel[2])>>		conv2D_out_scal)    +
						(	(	(matrix[i][j-1]	>>conv2D_scaling_factor)	* kernel[3])>>		conv2D_out_scal)    +
						(	(	(matrix[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>		conv2D_out_scal)    +
						(	(	(matrix[i][j+1]	>>conv2D_scaling_factor)	* kernel[5])>>		conv2D_out_scal)    +
						(	(	(matrix[i+1][j-1]>>conv2D_scaling_factor) 	* kernel[6])>>		conv2D_out_scal)    +
						(	(	(matrix[i+1][j] >>conv2D_scaling_factor)		* kernel[7])>>		conv2D_out_scal)    +
						(	(	(matrix[i+1][j+1]>>conv2D_scaling_factor) 	* kernel[8])>>		conv2D_out_scal)   ;
		}
	}
	if(print){
		printf("dopo kernel F-ACGI-D-E\n");
		for (int rig=0;rig<size;rig++){
			for (int col=0;col<size;col++){
				printf("%d\t",out[rig*size+col]);
			}printf("\n");
		}
	}
	///////////////////////////////////
	//scandisci tutta l'ultima riga tra i due vertici bassi	 H
	i=size-1;
	for (j = 1; j < size-1; j++)
	{
		pt=i*size+j;
		out[pt] +=	(((matrix[i-1][j-1]>>conv2D_scaling_factor) 	* kernel[0])>>		conv2D_out_scal)  +
					(((matrix[i-1][j]	>>conv2D_scaling_factor)	* kernel[1])>>		conv2D_out_scal)  +
					(((matrix[i-1][j+1]>>conv2D_scaling_factor)		* kernel[2])>>		conv2D_out_scal)  +
					(((matrix[i][j-1]	>>conv2D_scaling_factor)	* kernel[3])>>		conv2D_out_scal)  +
					(((matrix[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>		conv2D_out_scal)  +
					(((matrix[i][j+1]	>>conv2D_scaling_factor)	* kernel[5])>>		conv2D_out_scal) ;
	}
	//printf("out[%d]=%d\n",pt,(int)out[pt]);
	if(print){
		printf("dopo kernel F-ACGI-D-E-B-H\n");
		for (int rig=0;rig<size;rig++){
			for (int col=0;col<size;col++){
				printf("%d\t",out[rig*size+col]);
			}printf("\n");
		}
	}
}
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------

void convolution2D_SPM_off_NOB_2x2(void* spm_dest, 	 void* spm_fm,	 void* spm_krn,	 void* spm_temp,  int size)
{
	int print=0;
  //Pointers to Spms and other index that i'll need for the convolution

	// void* spmaddrAoff= (void*)((int*)spm_fm + mem_off );
	void* spmaddrAoff= (void*)(spm_fm);
	void* spmaddrBoff= (void*)(spm_krn );
	void* spmaddrCoff= (void*)(spm_dest);
	void* spmaddrDoff= (void*)(spm_temp);

	void* dest_in_C;
  void* dest_in_B;
  void* dest_in_D;

  int k_element=0;
  int mat_int_shift=0; //internal shifting for properly pointing insied the spms while making kaddv

	int jump_kr_row=3; // determina il salto della riga per la matrice kernel zeropadded
	int kern_offset=0;
	int fm_offset=0;
  int zero=0;


  //______________________________sub_kernel___________A-C-G-I
	CSR_MVSIZE(2*SIZE_OF_INT);
  //______________________________sub_kernel A
	dest_in_C	=		(void*)spmaddrCoff + SIZE_OF_INT*(0)*(size-1); //[0]
	dest_in_D	=		(void*)spmaddrDoff + SIZE_OF_INT*(0)*(size-1);
	kern_offset	=	1;
	fm_offset		=	0;
	kdotpps(dest_in_D,			(void*)(	(int*)spmaddrAoff+	(0)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(1)*jump_kr_row+	kern_offset ));
	kdotpps(dest_in_D+4,		(void*)(	(int*)spmaddrAoff+	(1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(2)*jump_kr_row+	kern_offset ));
	//______________________________sub_kernel C
	dest_in_C	=		(void*)spmaddrCoff + SIZE_OF_INT*(1)*(size-1); //[4]
	dest_in_D	=		(void*)spmaddrDoff + SIZE_OF_INT*(1)*(size-1);
	kern_offset	=	0;
	fm_offset		=	(size-1-1);
	kdotpps(dest_in_D,			(void*)(	(int*)spmaddrAoff+	(0)*size			+ fm_offset	),	(void*) ( (int*)spmaddrBoff+(1)*jump_kr_row+	kern_offset ));
	kdotpps(dest_in_D-4,		(void*)(	(int*)spmaddrAoff+	(1)*size			+ fm_offset	),	(void*) ( (int*)spmaddrBoff+(2)*jump_kr_row+	kern_offset ));
	//______________________________sub_kernel G
	dest_in_C	=		(void*)spmaddrCoff + SIZE_OF_INT*(size)*(size-1); //[20]
	dest_in_D	=		(void*)spmaddrDoff + SIZE_OF_INT*(size)*(size-1);
	kern_offset	=	1;
	fm_offset		=	0;
	kdotpps(dest_in_D,			(void*)(	(int*)spmaddrAoff+	(size-1-1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(0)*jump_kr_row+	kern_offset ));
	kdotpps(dest_in_D+4,		(void*)(	(int*)spmaddrAoff+	(size-1)	*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(1)*jump_kr_row+	kern_offset ));
	//______________________________sub_kernel I
	dest_in_C	=		(void*)spmaddrCoff + SIZE_OF_INT*(size+1)*(size-1); //[24]
	dest_in_D	=		(void*)spmaddrDoff + SIZE_OF_INT*(size+1)*(size-1);
	kern_offset	=	0;
	fm_offset		=	(size-1-1);
	kdotpps(dest_in_D,			(void*)(	(int*)spmaddrAoff+	(size-1-1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(0)*jump_kr_row+	kern_offset ));
	kdotpps(dest_in_D-4,		(void*)(	(int*)spmaddrAoff+	(size-1)	*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(1)*jump_kr_row+	kern_offset ));

	
	
	// //______________________________sommo i parziali prodotti dei sub_kernels A-C-G-I
  	CSR_MVSIZE(1*SIZE_OF_INT);

	kaddv((void*)spmaddrCoff + SIZE_OF_INT*(0)*(size-1),	    	(void*)spmaddrCoff + SIZE_OF_INT*(0)*(size-1),	       	(void*)spmaddrDoff + SIZE_OF_INT*(0)*(size-1)); 					//[]
  kaddv((void*)spmaddrCoff + SIZE_OF_INT*(0)*(size-1),	    	(void*)spmaddrCoff + SIZE_OF_INT*(0)*(size-1),	    	 	(void*)spmaddrDoff + SIZE_OF_INT*(0)*(size-1) + 4	);    	//[]
	

  kaddv((void*)spmaddrCoff + SIZE_OF_INT*(1)*(size-1),	    	(void*)spmaddrCoff + SIZE_OF_INT*(1)*(size-1),        	(void*)spmaddrDoff + SIZE_OF_INT*(1)*(size-1));           //[]
  kaddv((void*)spmaddrCoff + SIZE_OF_INT*(1)*(size-1),	    	(void*)spmaddrCoff + SIZE_OF_INT*(1)*(size-1),      	 	(void*)spmaddrDoff + SIZE_OF_INT*(1)*(size-1) - 4	);   	  //[]
	

  kaddv((void*)spmaddrCoff + SIZE_OF_INT*(size)*(size-1),			(void*)spmaddrCoff + SIZE_OF_INT*(size)*(size-1),  			(void*)spmaddrDoff + SIZE_OF_INT*(size)*(size-1));        //[]
  kaddv((void*)spmaddrCoff + SIZE_OF_INT*(size)*(size-1),			(void*)spmaddrCoff + SIZE_OF_INT*(size)*(size-1),  			(void*)spmaddrDoff + SIZE_OF_INT*(size)*(size-1) +4	);  	//[]

	
  kaddv((void*)spmaddrCoff + SIZE_OF_INT*(size+1)*(size-1),		(void*)spmaddrCoff + SIZE_OF_INT*(size+1)*(size-1),			(void*)spmaddrDoff + SIZE_OF_INT*(size+1)*(size-1));      //[]
  kaddv((void*)spmaddrCoff + SIZE_OF_INT*(size+1)*(size-1),		(void*)spmaddrCoff + SIZE_OF_INT*(size+1)*(size-1),			(void*)spmaddrDoff + SIZE_OF_INT*(size+1)*(size-1) -4	); 	//[]


	CSR_MVSIZE(size*size*SIZE_OF_INT);
	ksvmulrf((void*)spmaddrDoff,(void*)spmaddrDoff,(void*)zero);
	// CSR_MVSIZE(3*3*SIZE_OF_INT);
	// ksvmulrf((void*)spmaddrBoff,(void*)spmaddrBoff,(void*)zero);
	// // kbcast((void*)spmaddrBoff,(void*)shift_spmB);
}
void convolution2D_SPM_off_NOB(void* spm_dest, 	 void* spm_fm,	 void* spm_krn,	 void* spm_temp,  int size)
{
	int print=0;
  //Pointers to Spms and other index that i'll need for the convolution

	// void* spmaddrAoff= (void*)((int*)spm_fm + mem_off );
	void* spmaddrAoff= (void*)(spm_fm);
	void* spmaddrBoff= (void*)(spm_krn );
	void* spmaddrCoff= (void*)(spm_dest);
	void* spmaddrDoff= (void*)(spm_temp);

	void* dest_in_C;
  void* dest_in_B;
  void* dest_in_D;

  int k_element=0;
  int mat_int_shift=0; //internal shifting for properly pointing insied the spms while making kaddv

	int jump_kr_row=3; // determina il salto della riga per la matrice kernel zeropadded
	int kern_offset=0;
	int fm_offset=0;
  int zero=0;


	//______________________________sub_kernel F
  CSR_MVSIZE(2*SIZE_OF_INT);
	kern_offset	=	0;
	fm_offset= (size-1-1);
	for(int i=1; i< size-1;i++){
		dest_in_C	= (void*)spmaddrCoff + SIZE_OF_INT*(size*i)+ SIZE_OF_INT*(1)*(size-1);
		dest_in_D	= (void*)spmaddrDoff + SIZE_OF_INT*(size*i)+ SIZE_OF_INT*(1)*(size-1);
		kdotpps		(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(i-1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(0)*jump_kr_row+	kern_offset ) );
    kaddv(dest_in_C, dest_in_C, dest_in_D);
		kdotpps		(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(i)*size				+fm_offset	),	(void*) ( (int*)spmaddrBoff+(1)*jump_kr_row+	kern_offset )	);
    kaddv(dest_in_C, dest_in_C, dest_in_D);
		kdotpps		(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(i+1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(2)*jump_kr_row+	kern_offset )	);
		kaddv(dest_in_C, dest_in_C, dest_in_D);
	}


	// kern_offset	=	0;
	// fm_offset= (size-1-1);
	// for(int i=1; i< size-1;i++){
		// CSR_MVSIZE(2*SIZE_OF_INT);
		// dest_in_C	= (void*)spmaddrCoff + SIZE_OF_INT*(size*i)+ SIZE_OF_INT*(1)*(size-1);
		// dest_in_D	= (void*)spmaddrDoff + SIZE_OF_INT*(size*i)+ SIZE_OF_INT*(1)*(size-1);
		// kdotpps		(dest_in_D+4,			(void*)(	(int*)spmaddrAoff+	(i-1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(0)*jump_kr_row+	kern_offset ) );
		// kdotpps		(dest_in_D+8,			(void*)(	(int*)spmaddrAoff+	(i)*size				+fm_offset	),	(void*) ( (int*)spmaddrBoff+(1)*jump_kr_row+	kern_offset )	);
		// kdotpps		(dest_in_D+12,		(void*)(	(int*)spmaddrAoff+	(i+1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(2)*jump_kr_row+	kern_offset )	);
    // // kaddv(dest_in_C, dest_in_C, dest_in_D);
    // // kaddv(dest_in_C, dest_in_C, dest_in_D);
		// // kaddv(dest_in_C, dest_in_C, dest_in_D);
		// CSR_MVSIZE(3*SIZE_OF_INT);
		// kvred32(dest_in_C,dest_in_D);
	// }
// // int kbacst16_v2(void* rd, void* rs1, int size)
// // {
	// // __asm__(
		// // "csrw 0xBF0, %[size];"
		// // "kvred16 %[rd], %[rs1];"
		// // ://no output register
		// // :[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1)
		// // :/*no clobbered registers*/
	// // );

	// // return 1;
// // }


  //______________________________sub_kernel___________A-C-G-I
	CSR_MVSIZE(2*SIZE_OF_INT);
  //______________________________sub_kernel A
	dest_in_C	=		(void*)spmaddrCoff + SIZE_OF_INT*(0)*(size-1); //[0]
	dest_in_D	=		(void*)spmaddrDoff + SIZE_OF_INT*(0)*(size-1);
	kern_offset	=	1;
	fm_offset		=	0;
	kdotpps(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(0)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(1)*jump_kr_row+	kern_offset ));
	kdotpps(dest_in_D+4,		(void*)(	(int*)spmaddrAoff+	(1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(2)*jump_kr_row+	kern_offset ));
	//______________________________sub_kernel C
	dest_in_C	=		(void*)spmaddrCoff + SIZE_OF_INT*(1)*(size-1); //[4]
	dest_in_D	=		(void*)spmaddrDoff + SIZE_OF_INT*(1)*(size-1);
	kern_offset	=	0;
	fm_offset		=	(size-1-1);
	kdotpps(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(0)*size			+ fm_offset	),	(void*) ( (int*)spmaddrBoff+(1)*jump_kr_row+	kern_offset ));
	kdotpps(dest_in_D-4,		(void*)(	(int*)spmaddrAoff+	(1)*size			+ fm_offset	),	(void*) ( (int*)spmaddrBoff+(2)*jump_kr_row+	kern_offset ));
	//______________________________sub_kernel G
	dest_in_C	=		(void*)spmaddrCoff + SIZE_OF_INT*(size)*(size-1); //[20]
	dest_in_D	=		(void*)spmaddrDoff + SIZE_OF_INT*(size)*(size-1);
	kern_offset	=	1;
	fm_offset		=	0;
	kdotpps(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(size-1-1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(0)*jump_kr_row+	kern_offset ));
	kdotpps(dest_in_D+4,		(void*)(	(int*)spmaddrAoff+	(size-1)	*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(1)*jump_kr_row+	kern_offset ));
	//______________________________sub_kernel I
	dest_in_C	=		(void*)spmaddrCoff + SIZE_OF_INT*(size+1)*(size-1); //[24]
	dest_in_D	=		(void*)spmaddrDoff + SIZE_OF_INT*(size+1)*(size-1);
	kern_offset	=	0;
	fm_offset		=	(size-1-1);
	kdotpps(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(size-1-1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(0)*jump_kr_row+	kern_offset ));
	kdotpps(dest_in_D-4,		(void*)(	(int*)spmaddrAoff+	(size-1)	*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(1)*jump_kr_row+	kern_offset ));

	// //______________________________sommo i parziali prodotti dei sub_kernels A-C-G-I
  	CSR_MVSIZE(1*SIZE_OF_INT);

	kaddv((void*)spmaddrCoff + SIZE_OF_INT*(0)*(size-1),	    	(void*)spmaddrCoff + SIZE_OF_INT*(0)*(size-1),	       	(void*)spmaddrDoff + SIZE_OF_INT*(0)*(size-1));
  kaddv((void*)spmaddrCoff + SIZE_OF_INT*(1)*(size-1),	    	(void*)spmaddrCoff + SIZE_OF_INT*(1)*(size-1),        	(void*)spmaddrDoff + SIZE_OF_INT*(1)*(size-1));
  kaddv((void*)spmaddrCoff + SIZE_OF_INT*(size)*(size-1),			(void*)spmaddrCoff + SIZE_OF_INT*(size)*(size-1),  			(void*)spmaddrDoff + SIZE_OF_INT*(size)*(size-1));
  kaddv((void*)spmaddrCoff + SIZE_OF_INT*(size+1)*(size-1),		(void*)spmaddrCoff + SIZE_OF_INT*(size+1)*(size-1),			(void*)spmaddrDoff + SIZE_OF_INT*(size+1)*(size-1));

  kaddv((void*)spmaddrCoff + SIZE_OF_INT*(0)*(size-1),	    	(void*)spmaddrCoff + SIZE_OF_INT*(0)*(size-1),	    	  	(void*)spmaddrDoff + SIZE_OF_INT*(0)*(size-1) + 4	);
  kaddv((void*)spmaddrCoff + SIZE_OF_INT*(1)*(size-1),	    	(void*)spmaddrCoff + SIZE_OF_INT*(1)*(size-1),      		 	(void*)spmaddrDoff + SIZE_OF_INT*(1)*(size-1) - 4	);
  kaddv((void*)spmaddrCoff + SIZE_OF_INT*(size)*(size-1),			(void*)spmaddrCoff + SIZE_OF_INT*(size)*(size-1),  				(void*)spmaddrDoff + SIZE_OF_INT*(size)*(size-1) +4	);
  kaddv((void*)spmaddrCoff + SIZE_OF_INT*(size+1)*(size-1),		(void*)spmaddrCoff + SIZE_OF_INT*(size+1)*(size-1),				(void*)spmaddrDoff + SIZE_OF_INT*(size+1)*(size-1) -4	);



	//______________________________sub_kernel D
  CSR_MVSIZE(2*SIZE_OF_INT);
	kern_offset	=	1;
	fm_offset		=	0;
	for(int i=1; i< size-1;i++){
		dest_in_C	= (void*)spmaddrCoff + SIZE_OF_INT*(size*i);
		dest_in_D	= (void*)spmaddrDoff + SIZE_OF_INT*(size*i);
		kdotpps(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(i-1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(0)*jump_kr_row+	kern_offset ));
		kaddv(dest_in_C, dest_in_C, dest_in_D);
		kdotpps(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(i)*size				+fm_offset	),	(void*) ( (int*)spmaddrBoff+(1)*jump_kr_row+	kern_offset ));
    kaddv(dest_in_C, dest_in_C, dest_in_D);
		kdotpps(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(i+1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(2)*jump_kr_row+	kern_offset ));
    kaddv(dest_in_C, dest_in_C, dest_in_D);
	}



  //______________________________sub_kernel E
  CSR_MVSIZE((size-2)*SIZE_OF_INT);
	for(int i=1; i< size-1;i++)
	{
		// dest_in_C	= (void*)(	(int*)	(spmaddrCoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT;
		// dest_in_D	= (void*)(	(int*)	(spmaddrDoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT;
		k_element=0;
		for (int rw_pt=-1; rw_pt<2; rw_pt++) //rw_pt is an index i use to point to the correct row, regarding this loop that is executed three times
		//instead of making 9 different ksvmulrf
		{
			ksvmulsc((void*)(	(int*)	(spmaddrDoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
        			  (void*)	( (int*)spmaddrAoff + (i+rw_pt)*size	+0 ),
                (void*)	( (int*)spmaddrBoff+k_element++) );

				ksrav((void*)(	(int*)	(spmaddrDoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
								(void*)(	(int*)	(spmaddrDoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
								(int*)conv2D_out_scal);

  		kaddv ((void*)(	(int*)	(spmaddrCoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
              (void*)(	(int*)	(spmaddrCoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
              (void*)(	(int*)	(spmaddrDoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT);

			ksvmulsc((void*)(	(int*)	(spmaddrDoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
        			  (void*)	( (int*)spmaddrAoff + (i+rw_pt)*size	+1 ),
                (void*)	( (int*)spmaddrBoff+k_element++) );

				ksrav((void*)(	(int*)	(spmaddrDoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
								(void*)(	(int*)	(spmaddrDoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
								(int*)conv2D_out_scal);

  		kaddv ((void*)(	(int*)	(spmaddrCoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
              (void*)(	(int*)	(spmaddrCoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
              (void*)(	(int*)	(spmaddrDoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT);

			ksvmulsc((void*)(	(int*)	(spmaddrDoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
        			  (void*)	( (int*)spmaddrAoff + (i+rw_pt)*size	+2 ),
                (void*)	( (int*)spmaddrBoff+k_element++) );

				ksrav((void*)(	(int*)	(spmaddrDoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
								(void*)(	(int*)	(spmaddrDoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
								(int*)conv2D_out_scal);

  		kaddv ((void*)(	(int*)	(spmaddrCoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
              (void*)(	(int*)	(spmaddrCoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT,
              (void*)(	(int*)	(spmaddrDoff)	) + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT);
		}
	}



  // //______________________________sub_kernel B
  // CSR_MVSIZE((size-2)*SIZE_OF_INT);
  for(int i=0; i< 1;i++)
  {
    dest_in_C	= (void*)spmaddrCoff  + 1*SIZE_OF_INT;
    dest_in_D	= (void*)spmaddrDoff  + 1*SIZE_OF_INT;
    k_element=3;
    for (int rw_pt=0; rw_pt<2; rw_pt++) //rw_pt is an index i use to point to the correct row, regarding this loop that is executed three times
    //instead of making 9 different ksvmulrf
    {
      ksvmulsc(dest_in_D,			(void*)	( (int*)spmaddrAoff + (i+rw_pt)*size	+0 ),	(void*)	( (int*)spmaddrBoff+k_element++) );
					ksrav(dest_in_D,	dest_in_D,	(int*)conv2D_out_scal);
      kaddv (dest_in_C, dest_in_C,  dest_in_D);
      ksvmulsc(dest_in_D,			(void*)	( (int*)spmaddrAoff + (i+rw_pt)*size	+1 ),	(void*)	( (int*)spmaddrBoff+k_element++) );
					ksrav(dest_in_D,	dest_in_D,	(int*)conv2D_out_scal);
      kaddv	(dest_in_C, dest_in_C,  dest_in_D);
      ksvmulsc(dest_in_D,			(void*)	( (int*)spmaddrAoff + (i+rw_pt)*size	+2 ),	(void*)	( (int*)spmaddrBoff+k_element++) );
					ksrav(dest_in_D,	dest_in_D,	(int*)conv2D_out_scal);
      kaddv (dest_in_C, dest_in_C,  dest_in_D);
    }
  }



	//______________________________sub_kernel H
  // CSR_MVSIZE((size-2)*SIZE_OF_INT);
	for(int i=size-1; i< size;i++)
	{
		dest_in_C	= (void*)spmaddrCoff + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT;
    dest_in_D	= (void*)spmaddrDoff + SIZE_OF_INT*(size*i)+1*SIZE_OF_INT;
		k_element=0;
		for (int rw_pt=-1; rw_pt<1; rw_pt++) //rw_pt is an index i use to point to the correct row, regarding this loop that is executed three times
		//instead of making 9 different ksvmulrf
		{
			ksvmulsc(dest_in_D,			(void*)	( (int*)spmaddrAoff + (i+rw_pt)*size	+0 ),	(void*)	( (int*)spmaddrBoff+k_element++) );
				ksrav(dest_in_D,	dest_in_D,	(int*)conv2D_out_scal);
      kaddv	(dest_in_C, dest_in_C, dest_in_D);
			ksvmulsc(dest_in_D,			(void*)	( (int*)spmaddrAoff + (i+rw_pt)*size	+1 ),	(void*)	( (int*)spmaddrBoff+k_element++) );
				ksrav(dest_in_D,	dest_in_D,	(int*)conv2D_out_scal);
      kaddv	(dest_in_C, dest_in_C, dest_in_D);
			ksvmulsc(dest_in_D,			(void*)	( (int*)spmaddrAoff + (i+rw_pt)*size	+2 ),	(void*)	( (int*)spmaddrBoff+k_element++) );
				ksrav(dest_in_D,	dest_in_D,	(int*)conv2D_out_scal);
      kaddv	(dest_in_C, dest_in_C, dest_in_D);
		}
	}

	CSR_MVSIZE(size*size*SIZE_OF_INT);
	ksvmulrf((void*)spmaddrDoff,(void*)spmaddrDoff,(void*)zero);
	// CSR_MVSIZE(3*3*SIZE_OF_INT);
	// ksvmulrf((void*)spmaddrBoff,(void*)spmaddrBoff,(void*)zero);
	// // kbcast((void*)spmaddrBoff,(void*)shift_spmB);
}
void convolution2D_SPM_off_ALT_2x2(void* spm_dest, void* spm_fm, void* spm_krn, void* spm_bank, int size)
{
	int print=0;
  //Pointers to Spms and other index that i'll need for the convolution

	// void* spmaddrAoff= (void*)((int*)spm_fm + mem_off );
	void* spmaddrAoff= (void*)(spm_fm		);
	void* spmaddrBoff= (void*)(spm_krn 	);
	void* spmaddrCoff= (void*)(spm_dest	);
	void* spmaddrDoff= (void*)(spm_bank	);

	void* dest_in_C;
  void* dest_in_B;
  void* dest_in_D;

  int k_element=0;
  int mat_int_shift=0; //internal shifting for properly pointing insied the spms while making kaddv

	int jump_kr_row=3; // determina il salto della riga per la matrice kernel zeropadded
	int kern_offset=0;
	int fm_offset=0;
  int shift_spmB=1;

	shift_spmB=0;
  //______________________________sub_kernel___________A-C-G-I
  //______________________________sub_kernel A
	CSR_MVSIZE(2*SIZE_OF_INT);
	dest_in_C	=		(void*)spmaddrCoff + SIZE_OF_INT*(0)*(size-1); //[0]
	dest_in_D	=		(void*)spmaddrDoff + SIZE_OF_INT*(0)*(size-1);
  dest_in_B	= 	(void*)spmaddrBoff + SIZE_OF_INT*(9+shift_spmB); //move_b_pt=1
    shift_spmB++;
	kern_offset	=	1;
	fm_offset		=	0;
	kdotpps_v3(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(0)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(1)*jump_kr_row+	kern_offset ), (void*) conv2D_out_scal);
	kdotpps(dest_in_B,		(void*)(	(int*)spmaddrAoff+	(1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(2)*jump_kr_row+	kern_offset ));
	//______________________________sub_kernel C
	dest_in_C	=		(void*)spmaddrCoff + SIZE_OF_INT*(1)*(size-1); //[4]
	dest_in_D	=		(void*)spmaddrDoff + SIZE_OF_INT*(1)*(size-1);
  dest_in_B	= 	(void*)spmaddrBoff + SIZE_OF_INT*(9+shift_spmB); //move_b_pt=2
    shift_spmB++;
	kern_offset	=	0;
	fm_offset		=	(size-1-1);
	kdotpps(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(0)*size			+ fm_offset	),	(void*) ( (int*)spmaddrBoff+(1)*jump_kr_row+	kern_offset ));
	kdotpps(dest_in_B,		(void*)(	(int*)spmaddrAoff+	(1)*size			+ fm_offset	),	(void*) ( (int*)spmaddrBoff+(2)*jump_kr_row+	kern_offset ));
	//______________________________sub_kernel G
	dest_in_C	=		(void*)spmaddrCoff + SIZE_OF_INT*(size)*(size-1); //[20]
	dest_in_D	=		(void*)spmaddrDoff + SIZE_OF_INT*(size)*(size-1);
  dest_in_B	= 	(void*)spmaddrBoff + SIZE_OF_INT*(9+shift_spmB); //move_b_pt=3
    shift_spmB++;
	kern_offset	=	1;
	fm_offset		=	0;
	kdotpps(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(size-1-1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(0)*jump_kr_row+	kern_offset ));
	kdotpps(dest_in_B,		(void*)(	(int*)spmaddrAoff+	(size-1)	*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(1)*jump_kr_row+	kern_offset ));
	//______________________________sub_kernel I
	dest_in_C	=		(void*)spmaddrCoff + SIZE_OF_INT*(size+1)*(size-1); //[24]
	dest_in_D	=		(void*)spmaddrDoff + SIZE_OF_INT*(size+1)*(size-1);
  dest_in_B	= 	(void*)spmaddrBoff + SIZE_OF_INT*(9+shift_spmB); //move_b_pt=4
    shift_spmB++;
	kern_offset	=	0;
	fm_offset		=	(size-1-1);
	kdotpps(dest_in_D,		(void*)(	(int*)spmaddrAoff+	(size-1-1)*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(0)*jump_kr_row+	kern_offset ));
	kdotpps(dest_in_B,		(void*)(	(int*)spmaddrAoff+	(size-1)	*size			+fm_offset	),	(void*) ( (int*)spmaddrBoff+(1)*jump_kr_row+	kern_offset ));
	// //______________________________sommo i parziali prodotti dei sub_kernels A-C-G-I
  CSR_MVSIZE(1*SIZE_OF_INT);
  kaddv((void*)spmaddrCoff + SIZE_OF_INT*(0)*(size-1),	    	(void*)spmaddrCoff + SIZE_OF_INT*(0)*(size-1),	       	(void*)spmaddrDoff + SIZE_OF_INT*(0)*(size-1));
  kaddv((void*)spmaddrCoff + SIZE_OF_INT*(1)*(size-1),	    	(void*)spmaddrCoff + SIZE_OF_INT*(1)*(size-1),        	(void*)spmaddrDoff + SIZE_OF_INT*(1)*(size-1));
  kaddv((void*)spmaddrCoff + SIZE_OF_INT*(size)*(size-1),		(void*)spmaddrCoff + SIZE_OF_INT*(size)*(size-1),  		(void*)spmaddrDoff + SIZE_OF_INT*(size)*(size-1));
  kaddv((void*)spmaddrCoff + SIZE_OF_INT*(size+1)*(size-1),	(void*)spmaddrCoff + SIZE_OF_INT*(size+1)*(size-1),		(void*)spmaddrDoff + SIZE_OF_INT*(size+1)*(size-1));

  kaddv((void*)spmaddrCoff + SIZE_OF_INT*(0)*(size-1),	    	(void*)spmaddrCoff + SIZE_OF_INT*(0)*(size-1),	       	(void*)spmaddrBoff+SIZE_OF_INT*9);
  kaddv((void*)spmaddrCoff + SIZE_OF_INT*(1)*(size-1),	    	(void*)spmaddrCoff + SIZE_OF_INT*(1)*(size-1),        	(void*)spmaddrBoff+SIZE_OF_INT*10);
  kaddv((void*)spmaddrCoff + SIZE_OF_INT*(size)*(size-1),		(void*)spmaddrCoff + SIZE_OF_INT*(size)*(size-1),  				(void*)spmaddrBoff+SIZE_OF_INT*11);
  kaddv((void*)spmaddrCoff + SIZE_OF_INT*(size+1)*(size-1),	(void*)spmaddrCoff + SIZE_OF_INT*(size+1)*(size-1),				(void*)spmaddrBoff+SIZE_OF_INT*12);

	// if(print){
		// printf("Primo ciclo spmC dopo kernel ACGI\n");
		// display_spm_matrix(size,size, (void*)spmaddrCoff);
	// }

	CSR_MVSIZE(size*size*SIZE_OF_INT);
	shift_spmB=0;
	ksvmulrf((void*)spmaddrDoff,(void*)spmaddrDoff,(void*)shift_spmB);
	CSR_MVSIZE((3+1)*(3+1)*SIZE_OF_INT);
	ksvmulrf((void*)spmaddrBoff,(void*)spmaddrBoff,(void*)shift_spmB);
	// kbcast((void*)spmaddrBoff,(void*)shift_spmB);
}
