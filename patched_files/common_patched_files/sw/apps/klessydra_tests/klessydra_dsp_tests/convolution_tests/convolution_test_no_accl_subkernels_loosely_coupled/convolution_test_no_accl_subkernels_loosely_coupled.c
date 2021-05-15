/*
----------------------------------------------------------------------------------------------------
Convolution test
Multithreaded;
Accelerator (DPS+spm) is OFF/never used;
Replication of spm's and DSP Unit is OFF;
In this test the convolution is used only through memory + regfile. I have 3 different functions
working with the same REGIONS as splitted in test_2, plus another function that does the convolution on 
the whole matrix
----------------------------------------------------------------------------------------------------
*/
#ifndef A_ORDER
#define A_ORDER 32//Matrix size, don't do 2x2 case, for that i have another test
#endif

#define NO_ACCEL 1

#ifndef PRINT_NUM_CYCLES
//#define PRINT_NUM_CYCLES 1 // to print the cycle count
#endif

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

int perf0 = 0;
int final_perf0[3] = {777, 777, 777};
int *ptr_perf0 = &perf0;

int perf1 = 0;
int final_perf1[3] = {777, 777, 777};
int  *ptr_perf1 = &perf1;

int perf2 = 0;
int final_perf2[3] = {777, 777, 777};
int *ptr_perf2 = &perf2;

int perf3 = 0;
int final_perf3[3] = {777, 777, 777};
int *ptr_perf3 = &perf3;

int perf4 = 0;
int final_perf4[3] = {777, 777, 777};
int *ptr_perf4 = &perf4;

int perf5 = 0;
int final_perf5[3] = {777, 777, 777};
int *ptr_perf5 = &perf5;

int perf6 = 0;
int final_perf6[3] = {777, 777, 777};
int *ptr_perf6 = &perf6;

int perf7 = 0;
int final_perf7[3] = {777, 777, 777};
int *ptr_perf7 = &perf7;


int setting_cycles=0;

void spegni_threads();
void display_spm_matrix(int size_r,int size_c,void* pt_spm_mat);

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
  // spegni_threads();
  // printf("\n********Test %dx%d*********\n",A_ORDER,A_ORDER);
  // CSR_MVSIZE(9*sizeof(int));

	print_global_k =0;
	print_global_id=0;
	print_global_dbg=0;;
	int squares[A_ORDER*A_ORDER]={0};
	warn[0]=2;
	warn[1]=2;
	warn[2]=2;

	for(int i=0; i<B_ORDER*B_ORDER; i++){
    matB[i]=(i+1)<<8;
  }
	sign=1;
	for(int i =0; i<A_ORDER*A_ORDER; i++){
    matA0[i]=(1000*sign*(i+1))<<8;
		matA1[i]=(20*sign*(i+1))<<8;
		matA2[i]=(3*sign*(i+1))<<8;
		sign=sign*(-1);
		output_compare_s0[i]=777;
		output_compare_s1[i]=777;
		output_compare_s2[i]=777;
  }
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

	int off_idx=0;
	int array_boundaries[3]={0};
	array_boundaries[0] = A_ORDER/3;
	array_boundaries[1] =	array_boundaries[0]*2;
	array_boundaries[2] = A_ORDER;

	#ifdef NO_ACCEL
		sync_barrier_reset();
		//----------------------------------------------------------------------------------------------------
		// for (int main_size = 32 ; main_size > 2; main_size/2){
		int main_size=A_ORDER;
	    int enable_oerf_cnt = 0;
		sync_barrier_thread_registration();
		if (Klessydra_get_coreID()==0){
			#ifdef PRINT_NUM_CYCLES
				final_perf0[0]=0;
				final_perf1[0]=0;
				final_perf2[0]=0;
				final_perf3[0]=0;
				final_perf4[0]=0;
				final_perf5[0]=0;
				final_perf6[0]=0;
				final_perf7[0]=0;
				// ENABLE COUNTING -------------------------------------------------------------------------
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
			// ------------------------------------------------------------------------------------------
			for (int l=0; l<loop_index; l++) convolution2D_Scaling_region_1(main_size, mat_second_A[0],(int*)matB, (int*)output_compare1);
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
						:
						:[perf0] "r" (perf0), [ptr_perf0] "r" (ptr_perf0),
						 [perf1] "r" (perf1), [ptr_perf1] "r" (ptr_perf1),
						 [perf2] "r" (perf2), [ptr_perf2] "r" (ptr_perf2),
						 [perf3] "r" (perf3), [ptr_perf3] "r" (ptr_perf3),
						 [perf4] "r" (perf4), [ptr_perf4] "r" (ptr_perf4),
						 [perf5] "r" (perf5), [ptr_perf5] "r" (ptr_perf5)
				);
				__asm__("csrrw %[perf6], 0xB09, zero;"
						"sw %[perf6], 0(%[ptr_perf6]);"
						"csrrw %[perf7], 0xB0A, zero;"
						"sw %[perf7], 0(%[ptr_perf7]);"
						:
						:[perf6] "r" (perf6), [ptr_perf6] "r" (ptr_perf6),
						 [perf7] "r" (perf7), [ptr_perf7] "r" (ptr_perf7)
				);
				final_perf0[0]=*(ptr_perf0);
				final_perf1[0]=*(ptr_perf1);
				final_perf2[0]=*(ptr_perf2);
				final_perf3[0]=*(ptr_perf3);
				final_perf4[0]=*(ptr_perf4);
				final_perf5[0]=*(ptr_perf5);
				final_perf6[0]=*(ptr_perf6);
				final_perf7[0]=*(ptr_perf7);
			#endif
			// ------------------------------------------------------------------------------------------
		}
		if (Klessydra_get_coreID()==1){
			#ifdef PRINT_NUM_CYCLES
				final_perf0[1]=0;
				final_perf1[1]=0;
				final_perf2[1]=0;
				final_perf3[1]=0;
				final_perf4[1]=0;
				final_perf5[1]=0;
				final_perf6[1]=0;
				final_perf7[1]=0;
				// ENABLE COUNTING -------------------------------------------------------------------------
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
			// ------------------------------------------------------------------------------------------
			for (int l=0; l<loop_index; l++) convolution2D_Scaling_region_2(main_size, mat_second_A[0],(int*)matB, (int*)output_compare1);
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
						:
						:[perf0] "r" (perf0), [ptr_perf0] "r" (ptr_perf0),
						 [perf1] "r" (perf1), [ptr_perf1] "r" (ptr_perf1),
						 [perf2] "r" (perf2), [ptr_perf2] "r" (ptr_perf2),
						 [perf3] "r" (perf3), [ptr_perf3] "r" (ptr_perf3),
						 [perf4] "r" (perf4), [ptr_perf4] "r" (ptr_perf4),
						 [perf5] "r" (perf5), [ptr_perf5] "r" (ptr_perf5)
				);
				__asm__("csrrw %[perf6], 0xB09, zero;"
						"sw %[perf6], 0(%[ptr_perf6]);"
						"csrrw %[perf7], 0xB0A, zero;"
						"sw %[perf7], 0(%[ptr_perf7]);"
						:
						:[perf6] "r" (perf6), [ptr_perf6] "r" (ptr_perf6),
						 [perf7] "r" (perf7), [ptr_perf7] "r" (ptr_perf7)
				);
				final_perf0[1]=*(ptr_perf0);
				final_perf1[1]=*(ptr_perf1);
				final_perf2[1]=*(ptr_perf2);
				final_perf3[1]=*(ptr_perf3);
				final_perf4[1]=*(ptr_perf4);
				final_perf5[1]=*(ptr_perf5);
				final_perf6[1]=*(ptr_perf6);
				final_perf7[1]=*(ptr_perf7);
			#endif
			//------------------------------------------------------------------------------------------
		}
		if (Klessydra_get_coreID()==2){
			#ifdef PRINT_NUM_CYCLES
				final_perf0[2]=0;
				final_perf1[2]=0;
				final_perf2[2]=0;
				final_perf3[2]=0;
				final_perf4[2]=0;
				final_perf5[2]=0;
				final_perf6[2]=0;
				final_perf7[2]=0;
				// ENABLE COUNTING -------------------------------------------------------------------------
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
			for (int l=0; l<loop_index; l++) convolution2D_Scaling_region_3(main_size, mat_second_A[0],(int*)matB, (int*)output_compare1);
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
						:
						:[perf0] "r" (perf0), [ptr_perf0] "r" (ptr_perf0),
						 [perf1] "r" (perf1), [ptr_perf1] "r" (ptr_perf1),
						 [perf2] "r" (perf2), [ptr_perf2] "r" (ptr_perf2),
						 [perf3] "r" (perf3), [ptr_perf3] "r" (ptr_perf3),
						 [perf4] "r" (perf4), [ptr_perf4] "r" (ptr_perf4),
						 [perf5] "r" (perf5), [ptr_perf5] "r" (ptr_perf5)
				);
				__asm__("csrrw %[perf6], 0xB09, zero;"
						"sw %[perf6], 0(%[ptr_perf6]);"
						"csrrw %[perf7], 0xB0A, zero;"
						"sw %[perf7], 0(%[ptr_perf7]);"
						:
						:[perf6] "r" (perf6), [ptr_perf6] "r" (ptr_perf6),
						 [perf7] "r" (perf7), [ptr_perf7] "r" (ptr_perf7)
				);
				final_perf0[2]=*(ptr_perf0);
				final_perf1[2]=*(ptr_perf1);
				final_perf2[2]=*(ptr_perf2);
				final_perf3[2]=*(ptr_perf3);
				final_perf4[2]=*(ptr_perf4);
				final_perf5[2]=*(ptr_perf5);
				final_perf6[2]=*(ptr_perf6);
				final_perf7[2]=*(ptr_perf7);
			#endif
			// printf("Convolution with DSP 0 Speed is:\n\t%d Cycles\n", final_perf0);
			//------------------------------------------------------------------------------------------
		}
		sync_barrier();
		
		sync_barrier_thread_registration();
		
		if (Klessydra_get_coreID()==0){
			#ifdef PRINT_NUM_CYCLES
				printf("--------Test: NO ACCELERATION SUBKERNELS LOOSELY COUPLED[%dx%d]--------\n", main_size, main_size);
				printf("N of loops:%d\n\n",loop_index);
				for (int i=0; i<3; i++) {
					printf(" Cycle Count = %d \n Instruction Count = %d \n Instruction wait = %d \n Load Count = %d \n Store Count = %d \n Unconditional Jump Count = %d \n Branch Count = %d \n Taken Count = %d \n \n", final_perf0[i], final_perf1[i], final_perf2[i], final_perf3[i], final_perf4[i], final_perf5[i], final_perf6[i], final_perf7[i]);
				}
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
