/*
Test
-Multithread
-Decoupled
-Uses the ZEROPADDING convolutional algorithm
-Single accelerator
-can work with three SPM banks instead of four
-SPM size must be > 4KB
*/
// ----------------------------------------------------------------------------------------------------
// ----------------------------------ZEROPADDED--------------------------------------------------------
// ----------------------------------------------------------------------------------------------------
#ifndef A_ORDER
#define A_ORDER 32//Matrix size, don't do 2x2 case, for that i have another test
#endif
// ----------------------------------------------------------------------------------------------------
#define B_ORDER 3
#define EXPLICIT 1 // set to 0: uses the function with double inner loops; set to 1: use the explicit/rolled functions
// ----------------------------------------------------------------------------------------------------
#if B_ORDER == 3
#define Z_overhead 2
#endif
#if B_ORDER == 5
#define Z_overhead 4
#endif
#if B_ORDER == 7
#define Z_overhead 6
#endif
#if B_ORDER == 9
#define Z_overhead 8
#endif
#if B_ORDER == 11
#define Z_overhead 10
#endif
#define Z_ORDER (A_ORDER+Z_overhead)
// ----------------------------------------------------------------------------------------------------
#define REPLICATION 1
#ifndef PRINT_NUM_CYCLES
#define PRINT_NUM_CYCLES 1 // to print the cycle count
#endif

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

// #define PRINT_DEBUG 1 //to check if matrix is correct
#define MATRIX_CHECK 0 


int loop_index=1;

#define MULTI_TH 1

//don't change these :P
// // //#define MATRIX_CHECK_THREAD 0

#define SPM_MAX 64
#define SIZE_OF_INT 4
#define K_COL (B_ORDER+1)

int matA0[A_ORDER*A_ORDER];
int matA1[A_ORDER*A_ORDER];
int matA2[A_ORDER*A_ORDER];
int dimension_A=A_ORDER*A_ORDER*sizeof(int);
int dimension_Zero=(A_ORDER+2)*(A_ORDER+2)*sizeof(int);

int matB[B_ORDER*B_ORDER] = {0};
int dimension_B=B_ORDER*B_ORDER*sizeof(int);

int output_compare0[A_ORDER*A_ORDER]={0};
int output_compare1[A_ORDER*A_ORDER]={0};
int output_compare2[A_ORDER*A_ORDER]={0};


int output_compare_zero[A_ORDER*A_ORDER]={0};

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
int final_perf0 = 777;
int *ptr_perf0 = &perf0;

int perf1 = 0;
int final_perf1 = 777;
int *ptr_perf1 = &perf1;

int perf2 = 0;
int final_perf2 = 777;
int *ptr_perf2 = &perf2;

int perf3 = 0;
int final_perf3 = 777;
int *ptr_perf3 = &perf3;

int perf4 = 0;
int final_perf4 = 777;
int *ptr_perf4 = &perf4;

int perf5 = 0;
int final_perf5 = 777;
int *ptr_perf5 = &perf5;

int perf6 = 0;
int final_perf6 = 777;
int *ptr_perf6 = &perf6;

int perf7 = 0;
int final_perf7 = 777;
int *ptr_perf7 = &perf7;

void matrix_print(int* pt, int size, int mode);
void matrix_check( int* mat1, int* mat2, int size );
void matrix_check_thread( int* mat1, int* mat2, int size, int thread);
void matrix_check_v2( int* mat1, int* mat2, int size);
void matrix_check_v3( int* mat1, int* mat2, int size );

void convolution2D_Zeropadding(int size, int (*matrix)[size], int *kernel_tmp, int *out);
void convolution2D_Zeropadding_3(int size, int (*matrix)[size], int *kernel_tmp, int *out);
void convolution2D_Zeropadding_5(int size, int (*matrix)[size], int *kernel_tmp, int *out);
void convolution2D_Zeropadding_7(int size, int (*matrix)[size], int *kernel_tmp, int *out);
void convolution2D_Zeropadding_9(int size, int (*matrix)[size], int *kernel_tmp, int *out);
void convolution2D_Zeropadding_11(int size, int (*matrix)[size], int *kernel_tmp, int *out);
//------------------------------------------------------------------------------------------------------------
#if B_ORDER == 3
	void conv2D_Zeropad_excplicit_3(int size, int (*matrix)[size], int *kernel_tmp, int *out);
#endif
#if B_ORDER == 5
	void conv2D_Zeropad_excplicit_5(int size, int (*matrix)[size], int *kernel_tmp, int *out);
#endif
#if B_ORDER == 7
	void conv2D_Zeropad_excplicit_7(int size, int (*matrix)[size], int *kernel_tmp, int *out);
#endif
#if B_ORDER == 9
	void conv2D_Zeropad_excplicit_9(int size, int (*matrix)[size], int *kernel_tmp, int *out);
#endif
#if B_ORDER == 11
	void conv2D_Zeropad_excplicit_11(int size, int (*matrix)[size], int *kernel_tmp, int *out);
#endif

//------------------------------------------------------------------------------------------------------------
void convolution2D_Zeropadding_region_0(int size, int (*matrix)[size], int *kernel_tmp, int *out);
void convolution2D_Zeropadding_region_1(int size, int (*matrix)[size], int *kernel_tmp, int *out);
void convolution2D_Zeropadding_region_2(int size, int (*matrix)[size], int *kernel_tmp, int *out);
//------------------------------------------------------------------------------------------------------------
void convolution2D_Subkernels(int size, int (*matrix)[size], int *kernel_tmp, int *out);
void convolution2D_Subkernels_0(int size, int (*matrix)[size], int *kernel_tmp, int *out);
void convolution2D_Subkernels_1(int size, int (*matrix)[size], int *kernel_tmp, int *out);
void convolution2D_Subkernels_2(int size, int (*matrix)[size], int *kernel_tmp, int *out);

//------------------------------------------------------------------------------------------------------------
// 													MAIN
//------------------------------------------------------------------------------------------------------------
int main(){
	int off_idx=0;
	int squares[A_ORDER*A_ORDER]={0};
	int padded[Z_ORDER][Z_ORDER]={0};
	int junk=0;
	print_global_k =0;
	print_global_id=0;
	print_global_dbg=0;;
	warn[0]=2;
	warn[1]=2;
	warn[2]=2;
	sign=1;
	int increment=1000;
	// int increment=1;
	for(int i=0; i<B_ORDER*B_ORDER; i++){
		matB[i]=(increment*1)<<8;
		// matB[i]=(i+1)*increment<<8;
  }
	for(int i =0; i<A_ORDER*A_ORDER; i++){
    // matA0[i]=(1000*sign*(i+1))<<8;
    matA0[i]=(1000*1)<<8;
		matA1[i]=(20*sign*(i+1))<<8;
		matA2[i]=(3*sign*(i+1))<<8;
		sign=sign*(-1);
		output_compare_s0[i]=777;
		output_compare_s1[i]=777;
		output_compare_s2[i]=777;
		output_compare_zero[i]=777;
  }
	sign = 1;
  for(int i =0;i<A_ORDER; i++)
  {
    for(int j=0; j<A_ORDER; j++)
		{
      mat_second_A[0][i][j]=(increment*1)<<8;
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
	
	#ifdef MULTI_TH
		//--------------------------------------CHECK RESULTS--------------------------------------------------
		//--------------------------------------CHECK RESULTS--------------------------------------------------
		//--------------------------------------CHECK RESULTS--------------------------------------------------
		#ifdef PRINT_NUM_CYCLES
			// ENABLE COUNTING -------------------------------------------------------------------------
			int enable_perf_cnt = 0;
			final_perf0=0;
			final_perf1=0;
			final_perf2=0;
			final_perf3=0;
			final_perf4=0;
			final_perf5=0;
			final_perf6=0;
			final_perf7=0;
			__asm__("csrrw zero, 0x780, zero;"  // reset cycle count
					"csrrw zero, 0x781, zero;"  // reset instruction count
					"csrrw zero, 0x784, zero;"  // reset instruction wait count
					"csrrw zero, 0x785, zero;"  // reset memory load count
					"csrrw zero, 0x786, zero;"  // reset memory store count
					"csrrw zero, 0x787, zero;"  // reset uncoditional jump count
					"csrrw zero, 0x788, zero;"  // reset branch count
					"csrrw zero, 0x789, zero;"  // reset taken branch count
					"li %[enable], 0x000003F3;"  // 
					"csrrw zero, 0x7A0, %[enable]" // enable performance counters
					:
					:[enable] "r" (enable_perf_cnt)
			);
		#endif
		//------------------------------------------------------------------------------------------
			
			#if EXPLICIT == 0
				#if B_ORDER == 3
				for (int l=0; l<loop_index; l++) convolution2D_Zeropadding_3(A_ORDER, mat_second_A[0],(int*)matB, (int*)output_compare1); 
				#endif
				#if B_ORDER == 5
				for (int l=0; l<loop_index; l++) convolution2D_Zeropadding_5(A_ORDER, mat_second_A[0],(int*)matB, (int*)output_compare1); 
				#endif
				#if B_ORDER == 7
				for (int l=0; l<loop_index; l++) convolution2D_Zeropadding_7(A_ORDER, mat_second_A[0],(int*)matB, (int*)output_compare1); 
				#endif
				#if B_ORDER == 9
				for (int l=0; l<loop_index; l++) convolution2D_Zeropadding_9(A_ORDER, mat_second_A[0],(int*)matB, (int*)output_compare1); 
				#endif
				#if B_ORDER == 11
				for (int l=0; l<loop_index; l++) convolution2D_Zeropadding_11(A_ORDER, mat_second_A[0],(int*)matB, (int*)output_compare1); 
				#endif
			#endif
			
			#if EXPLICIT == 1
				#if B_ORDER == 3
				for (int l=0; l<loop_index; l++) conv2D_Zeropad_excplicit_3(A_ORDER, mat_second_A[0],(int*)matB, (int*)output_compare1); 
				#endif
				#if B_ORDER == 5
				for (int l=0; l<loop_index; l++) conv2D_Zeropad_excplicit_5(A_ORDER, mat_second_A[0],(int*)matB, (int*)output_compare1); 
				#endif
				#if B_ORDER == 7
				for (int l=0; l<loop_index; l++) conv2D_Zeropad_excplicit_7(A_ORDER, mat_second_A[0],(int*)matB, (int*)output_compare1); 
				#endif
				#if B_ORDER == 9
				for (int l=0; l<loop_index; l++) conv2D_Zeropad_excplicit_9(A_ORDER, mat_second_A[0],(int*)matB, (int*)output_compare1); 
				#endif
				#if B_ORDER == 11
				for (int l=0; l<loop_index; l++) conv2D_Zeropad_excplicit_11(A_ORDER, mat_second_A[0],(int*)matB, (int*)output_compare1); 
				#endif
			#endif
			
		// DISABLE COUNTING AND SAVE MCYCLE -------------------------------------------------------
		#ifdef PRINT_NUM_CYCLES
		// -------------------------------------------------------------------------------------------------------------------
			// DISABLE COUNTING AND SAVE MCYCLE -------------------------------------------------------
			__asm__("csrrw zero, 0x7A0, 0x00000000;" // disable performance counters
					"csrrw %[perf0], 0x780, zero;"
					"sw %[perf0], 0(%[ptr_perf0]);"
					"csrrw %[perf1], 0x781, zero;"
					"sw %[perf1], 0(%[ptr_perf1]);"
					"csrrw %[perf2], 0x784, zero;"
					"sw %[perf2], 0(%[ptr_perf2]);"
					"csrrw %[perf3], 0x785, zero;"
					"sw %[perf3], 0(%[ptr_perf3]);"
					"csrrw %[perf4], 0x786, zero;"
					"sw %[perf4], 0(%[ptr_perf4]);"
					"csrrw %[perf5], 0x787, zero;"
					"sw %[perf5], 0(%[ptr_perf5]);"
					:
					:[perf0] "r" (perf0), [ptr_perf0] "r" (ptr_perf0),
					 [perf1] "r" (perf1), [ptr_perf1] "r" (ptr_perf1),
					 [perf2] "r" (perf2), [ptr_perf2] "r" (ptr_perf2),
					 [perf3] "r" (perf3), [ptr_perf3] "r" (ptr_perf3),
					 [perf4] "r" (perf4), [ptr_perf4] "r" (ptr_perf4),
					 [perf5] "r" (perf5), [ptr_perf5] "r" (ptr_perf5)
			);
			__asm__("csrrw %[perf6], 0x788, zero;"
					"sw %[perf6], 0(%[ptr_perf6]);"
					"csrrw %[perf7], 0x789, zero;"
					"sw %[perf7], 0(%[ptr_perf7]);"
					:
					:[perf6] "r" (perf6), [ptr_perf6] "r" (ptr_perf6),
					 [perf7] "r" (perf7), [ptr_perf7] "r" (ptr_perf7)
			);
			final_perf0=*(ptr_perf0);
			final_perf1=*(ptr_perf1);
			final_perf2=*(ptr_perf2);
			final_perf3=*(ptr_perf3);
			final_perf4=*(ptr_perf4);
			final_perf5=*(ptr_perf5);
			final_perf6=*(ptr_perf6);
			final_perf7=*(ptr_perf7);
		#endif
		//------------------------------------------------------------------------------------------
		#ifdef PRINT_NUM_CYCLES
			printf("--------Test: RISCY ZEROPADDED_FM[%dx%d] & KM[%dx%d]--------\n", A_ORDER,A_ORDER,B_ORDER,B_ORDER);
			printf("N of loops:%d\n\n",loop_index);
			printf(" Cycle Count = %d \n Instruction Count = %d \n Instruction wait = %d \n Load Count = %d \n Store Count = %d \n Unconditional Jump Count = %d \n Branch Count = %d \n Taken Count = %d \n \n", final_perf0, final_perf1, final_perf2, final_perf3, final_perf4, final_perf5, final_perf6, final_perf7);
		#endif
		//matrix_print((int*)output_compare1, A_ORDER, 0);
	#endif
	return 0;
}
//------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------
// Functions
//------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------
#if B_ORDER == 3
	void conv2D_Zeropad_excplicit_3(int size, int (*matrix)[size], int *kernel_tmp, int *out){
	#define KERN_EXPLICIT_3 3
	#define ZEROPAD_EXPLICIT_struct_3 2
	#define ZEROPAD_EXPLICIT_offset_3 1
	int print=0;
	int kernel[KERN_EXPLICIT_3*KERN_EXPLICIT_3];
	int conv2D_scaling_factor=8;
	int conv2D_out_scal=5;
	for(int i=0;i<KERN_EXPLICIT_3*KERN_EXPLICIT_3;i++){
    	kernel[i]=(kernel_tmp[i]>>conv2D_scaling_factor);
	}
	int i, j;
	int pt=0;
	int zeropad[Z_ORDER][Z_ORDER]={0};
	for (int i=ZEROPAD_EXPLICIT_offset_3; i< size+ZEROPAD_EXPLICIT_struct_3-ZEROPAD_EXPLICIT_offset_3; i++)
		for (int j=ZEROPAD_EXPLICIT_offset_3; j< size+ZEROPAD_EXPLICIT_struct_3-ZEROPAD_EXPLICIT_offset_3; j++)
			zeropad[i][j]=matrix[i-ZEROPAD_EXPLICIT_offset_3][j-ZEROPAD_EXPLICIT_offset_3];

	for (i = 1; i < (size+(2))-(1); i++)                                                          
	{                                                                                         
		for (j = (1); j < (size+(2))-(1); j++)                                                          
		{                                                                                         
			pt=(i+(-1))*size+(j+(-1));                                                                      
			out[pt] +=	                                                                              
			(	(	(zeropad	[i+(-1)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[0])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(-1)][j+(0)]		>>conv2D_scaling_factor)	* kernel[1])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(-1)][j+(1)]		>>conv2D_scaling_factor)	* kernel[2])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(0)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[3])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(0)][j+(0)]		>>conv2D_scaling_factor)	* kernel[4])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(0)][j+(1)]		>>conv2D_scaling_factor)	* kernel[5])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(1)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[6])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(1)][j+(0)]		>>conv2D_scaling_factor)	* kernel[7])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(1)][j+(1)]		>>conv2D_scaling_factor)	* kernel[8])>>		conv2D_out_scal)   	;   
		}                                                                                         
	}                                                                                         
}
#endif
#if B_ORDER == 5
	void conv2D_Zeropad_excplicit_5(int size, int (*matrix)[size], int *kernel_tmp, int *out){
	#define KERN_EXPLICIT_5 5
	#define ZEROPAD_EXPLICIT_struct_5 4
	#define ZEROPAD_EXPLICIT_offset_5 2
	int print=0;
	int kernel[KERN_EXPLICIT_5*KERN_EXPLICIT_5];
	int conv2D_scaling_factor=8;
	int conv2D_out_scal=5;
	for(int i=0;i<KERN_EXPLICIT_5*KERN_EXPLICIT_5;i++){
    	kernel[i]=(kernel_tmp[i]>>conv2D_scaling_factor);
	}
	int i, j;
	int pt=0;
	int zeropad[Z_ORDER][Z_ORDER]={0};
	for (int i=ZEROPAD_EXPLICIT_offset_5; i< size+ZEROPAD_EXPLICIT_struct_5-ZEROPAD_EXPLICIT_offset_5; i++)
		for (int j=ZEROPAD_EXPLICIT_offset_5; j< size+ZEROPAD_EXPLICIT_struct_5-ZEROPAD_EXPLICIT_offset_5; j++)
			zeropad[i][j]=matrix[i-ZEROPAD_EXPLICIT_offset_5][j-ZEROPAD_EXPLICIT_offset_5];

	for (i = 2; i < (size+(4))-(2); i++)                                                          
	{                                                                                         
		for (j = (2); j < (size+(4))-(2); j++)                                                          
		{                                                                                         
			pt=(i+(-2))*size+(j+(-2));                                                                      
			out[pt] +=	                                                                              
			(	(	(zeropad	[i+(-2)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[0])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(-2)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[1])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(-2)][j+(0)]		>>conv2D_scaling_factor)	* kernel[2])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(-2)][j+(1)]		>>conv2D_scaling_factor)	* kernel[3])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(-2)][j+(2)]		>>conv2D_scaling_factor)	* kernel[4])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(-1)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[5])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(-1)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[6])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(-1)][j+(0)]		>>conv2D_scaling_factor)	* kernel[7])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(-1)][j+(1)]		>>conv2D_scaling_factor)	* kernel[8])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(-1)][j+(2)]		>>conv2D_scaling_factor)	* kernel[9])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(0)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[10])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(0)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[11])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(0)][j+(0)]		>>conv2D_scaling_factor)	* kernel[12])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(0)][j+(1)]		>>conv2D_scaling_factor)	* kernel[13])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(0)][j+(2)]		>>conv2D_scaling_factor)	* kernel[14])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(1)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[15])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(1)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[16])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(1)][j+(0)]		>>conv2D_scaling_factor)	* kernel[17])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(1)][j+(1)]		>>conv2D_scaling_factor)	* kernel[18])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(1)][j+(2)]		>>conv2D_scaling_factor)	* kernel[19])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(2)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[20])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(2)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[21])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(2)][j+(0)]		>>conv2D_scaling_factor)	* kernel[22])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(2)][j+(1)]		>>conv2D_scaling_factor)	* kernel[23])>>		conv2D_out_scal)    +   
			(	(	(zeropad	[i+(2)][j+(2)]		>>conv2D_scaling_factor)	* kernel[24])>>		conv2D_out_scal)    ;   
		}                                                                                         
	}                                                                                                                                                                                                                                                     
}
#endif
#if B_ORDER == 7
	void conv2D_Zeropad_excplicit_7(int size, int (*matrix)[size], int *kernel_tmp, int *out){									
	#define KERN_EXPLICIT_7 7                                                                                 
	#define ZEROPAD_EXPLICIT_struct_7 6                                                                       
	#define ZEROPAD_EXPLICIT_offset_7 3                                                                       
	int print=0;                                                                                              	
	int kernel[KERN_EXPLICIT_7*KERN_EXPLICIT_7];                                                              
	int conv2D_scaling_factor=8;                                                                              	
	int conv2D_out_scal=5;                                                                                    	
	for(int i=0;i<KERN_EXPLICIT_7*KERN_EXPLICIT_7;i++){                                                       
		kernel[i]=(kernel_tmp[i]>>conv2D_scaling_factor);                                                       	
	}                                                                                                         	
	int i, j;                                                                                                 	
	int pt=0;                                                                                                 	
	int zeropad[Z_ORDER][Z_ORDER]={0};                                                                        	
	for (int i=ZEROPAD_EXPLICIT_offset_7; i< size+ZEROPAD_EXPLICIT_struct_7-ZEROPAD_EXPLICIT_offset_7; i++)  
		for (int j=ZEROPAD_EXPLICIT_offset_7; j< size+ZEROPAD_EXPLICIT_struct_7-ZEROPAD_EXPLICIT_offset_7; j++)
			zeropad[i][j]=matrix[i-ZEROPAD_EXPLICIT_offset_7][j-ZEROPAD_EXPLICIT_offset_7];                       
	for (i = 3; i < (size+(6))-(3); i++)                                                          
	{                                                                                         
		for (j = (3); j < (size+(6))-(3); j++)                                                          
		{                                                                                         
			pt=(i+(-3))*size+(j+(-3));                                                                      
			out[pt] +=	                                                                              
		(	(	(zeropad	[i+(-3)][j+(-3)]		>>conv2D_scaling_factor)	* kernel[0])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-3)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[1])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-3)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[2])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-3)][j+(0)]		>>conv2D_scaling_factor)	* kernel[3])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-3)][j+(1)]		>>conv2D_scaling_factor)	* kernel[4])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-3)][j+(2)]		>>conv2D_scaling_factor)	* kernel[5])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-3)][j+(3)]		>>conv2D_scaling_factor)	* kernel[6])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-2)][j+(-3)]		>>conv2D_scaling_factor)	* kernel[7])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-2)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[8])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-2)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[9])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-2)][j+(0)]		>>conv2D_scaling_factor)	* kernel[10])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-2)][j+(1)]		>>conv2D_scaling_factor)	* kernel[11])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-2)][j+(2)]		>>conv2D_scaling_factor)	* kernel[12])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-2)][j+(3)]		>>conv2D_scaling_factor)	* kernel[13])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-1)][j+(-3)]		>>conv2D_scaling_factor)	* kernel[14])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-1)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[15])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-1)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[16])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-1)][j+(0)]		>>conv2D_scaling_factor)	* kernel[17])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-1)][j+(1)]		>>conv2D_scaling_factor)	* kernel[18])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-1)][j+(2)]		>>conv2D_scaling_factor)	* kernel[19])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-1)][j+(3)]		>>conv2D_scaling_factor)	* kernel[20])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(0)][j+(-3)]		>>conv2D_scaling_factor)	* kernel[21])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(0)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[22])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(0)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[23])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(0)][j+(0)]		>>conv2D_scaling_factor)	* kernel[24])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(0)][j+(1)]		>>conv2D_scaling_factor)	* kernel[25])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(0)][j+(2)]		>>conv2D_scaling_factor)	* kernel[26])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(0)][j+(3)]		>>conv2D_scaling_factor)	* kernel[27])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(1)][j+(-3)]		>>conv2D_scaling_factor)	* kernel[28])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(1)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[29])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(1)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[30])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(1)][j+(0)]		>>conv2D_scaling_factor)	* kernel[31])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(1)][j+(1)]		>>conv2D_scaling_factor)	* kernel[32])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(1)][j+(2)]		>>conv2D_scaling_factor)	* kernel[33])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(1)][j+(3)]		>>conv2D_scaling_factor)	* kernel[34])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(2)][j+(-3)]		>>conv2D_scaling_factor)	* kernel[35])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(2)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[36])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(2)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[37])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(2)][j+(0)]		>>conv2D_scaling_factor)	* kernel[38])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(2)][j+(1)]		>>conv2D_scaling_factor)	* kernel[39])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(2)][j+(2)]		>>conv2D_scaling_factor)	* kernel[40])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(2)][j+(3)]		>>conv2D_scaling_factor)	* kernel[41])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(3)][j+(-3)]		>>conv2D_scaling_factor)	* kernel[42])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(3)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[43])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(3)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[44])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(3)][j+(0)]		>>conv2D_scaling_factor)	* kernel[45])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(3)][j+(1)]		>>conv2D_scaling_factor)	* kernel[46])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(3)][j+(2)]		>>conv2D_scaling_factor)	* kernel[47])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(3)][j+(3)]		>>conv2D_scaling_factor)	* kernel[48])>>		conv2D_out_scal)    ;   
		}                                                                                         
	}                                                                                         
}// // --------------------------------------------------------------------------------------------------------------------------------
#endif
#if B_ORDER == 9
	void conv2D_Zeropad_excplicit_9(int size, int (*matrix)[size], int *kernel_tmp, int *out){									
	#define KERN_EXPLICIT_9 9                                                                                 
	#define ZEROPAD_EXPLICIT_struct_9 8                                                                       
	#define ZEROPAD_EXPLICIT_offset_9 4                                                                       
	int print=0;                                                                                              	
	int kernel[KERN_EXPLICIT_9*KERN_EXPLICIT_9];                                                              
	int conv2D_scaling_factor=8;                                                                              	
	int conv2D_out_scal=5;                                                                                    	
	for(int i=0;i<KERN_EXPLICIT_9*KERN_EXPLICIT_9;i++){                                                       
		kernel[i]=(kernel_tmp[i]>>conv2D_scaling_factor);                                                       	
	}                                                                                                         	
	int i, j;                                                                                                 	
	int pt=0;                                                                                                 	
	int zeropad[Z_ORDER][Z_ORDER]={0};                                                                        	
	for (int i=ZEROPAD_EXPLICIT_offset_9; i< size+ZEROPAD_EXPLICIT_struct_9-ZEROPAD_EXPLICIT_offset_9; i++)  
		for (int j=ZEROPAD_EXPLICIT_offset_9; j< size+ZEROPAD_EXPLICIT_struct_9-ZEROPAD_EXPLICIT_offset_9; j++)
			zeropad[i][j]=matrix[i-ZEROPAD_EXPLICIT_offset_9][j-ZEROPAD_EXPLICIT_offset_9];                       
	for (i = 4; i < (size+(8))-(4); i++)                                                          
	{                                                                                         
		for (j = (4); j < (size+(8))-(4); j++)                                                          
		{                                                                                         
			pt=(i+(-4))*size+(j+(-4));                                                                      
			out[pt] +=	                                                                              
		(	(	(zeropad	[i+(-4)][j+(-4)]		>>conv2D_scaling_factor)	* kernel[0])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-4)][j+(-3)]		>>conv2D_scaling_factor)	* kernel[1])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-4)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[2])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-4)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[3])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-4)][j+(0)]		>>conv2D_scaling_factor)	* kernel[4])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-4)][j+(1)]		>>conv2D_scaling_factor)	* kernel[5])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-4)][j+(2)]		>>conv2D_scaling_factor)	* kernel[6])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-4)][j+(3)]		>>conv2D_scaling_factor)	* kernel[7])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-4)][j+(4)]		>>conv2D_scaling_factor)	* kernel[8])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-3)][j+(-4)]		>>conv2D_scaling_factor)	* kernel[9])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-3)][j+(-3)]		>>conv2D_scaling_factor)	* kernel[10])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-3)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[11])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-3)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[12])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-3)][j+(0)]		>>conv2D_scaling_factor)	* kernel[13])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-3)][j+(1)]		>>conv2D_scaling_factor)	* kernel[14])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-3)][j+(2)]		>>conv2D_scaling_factor)	* kernel[15])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-3)][j+(3)]		>>conv2D_scaling_factor)	* kernel[16])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-3)][j+(4)]		>>conv2D_scaling_factor)	* kernel[17])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-2)][j+(-4)]		>>conv2D_scaling_factor)	* kernel[18])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-2)][j+(-3)]		>>conv2D_scaling_factor)	* kernel[19])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-2)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[20])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-2)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[21])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-2)][j+(0)]		>>conv2D_scaling_factor)	* kernel[22])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-2)][j+(1)]		>>conv2D_scaling_factor)	* kernel[23])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-2)][j+(2)]		>>conv2D_scaling_factor)	* kernel[24])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-2)][j+(3)]		>>conv2D_scaling_factor)	* kernel[25])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-2)][j+(4)]		>>conv2D_scaling_factor)	* kernel[26])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-1)][j+(-4)]		>>conv2D_scaling_factor)	* kernel[27])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-1)][j+(-3)]		>>conv2D_scaling_factor)	* kernel[28])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-1)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[29])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-1)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[30])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-1)][j+(0)]		>>conv2D_scaling_factor)	* kernel[31])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-1)][j+(1)]		>>conv2D_scaling_factor)	* kernel[32])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-1)][j+(2)]		>>conv2D_scaling_factor)	* kernel[33])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-1)][j+(3)]		>>conv2D_scaling_factor)	* kernel[34])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-1)][j+(4)]		>>conv2D_scaling_factor)	* kernel[35])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(0)][j+(-4)]		>>conv2D_scaling_factor)	* kernel[36])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(0)][j+(-3)]		>>conv2D_scaling_factor)	* kernel[37])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(0)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[38])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(0)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[39])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(0)][j+(0)]		>>conv2D_scaling_factor)	* kernel[40])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(0)][j+(1)]		>>conv2D_scaling_factor)	* kernel[41])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(0)][j+(2)]		>>conv2D_scaling_factor)	* kernel[42])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(0)][j+(3)]		>>conv2D_scaling_factor)	* kernel[43])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(0)][j+(4)]		>>conv2D_scaling_factor)	* kernel[44])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(1)][j+(-4)]		>>conv2D_scaling_factor)	* kernel[45])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(1)][j+(-3)]		>>conv2D_scaling_factor)	* kernel[46])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(1)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[47])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(1)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[48])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(1)][j+(0)]		>>conv2D_scaling_factor)	* kernel[49])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(1)][j+(1)]		>>conv2D_scaling_factor)	* kernel[50])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(1)][j+(2)]		>>conv2D_scaling_factor)	* kernel[51])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(1)][j+(3)]		>>conv2D_scaling_factor)	* kernel[52])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(1)][j+(4)]		>>conv2D_scaling_factor)	* kernel[53])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(2)][j+(-4)]		>>conv2D_scaling_factor)	* kernel[54])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(2)][j+(-3)]		>>conv2D_scaling_factor)	* kernel[55])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(2)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[56])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(2)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[57])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(2)][j+(0)]		>>conv2D_scaling_factor)	* kernel[58])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(2)][j+(1)]		>>conv2D_scaling_factor)	* kernel[59])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(2)][j+(2)]		>>conv2D_scaling_factor)	* kernel[60])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(2)][j+(3)]		>>conv2D_scaling_factor)	* kernel[61])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(2)][j+(4)]		>>conv2D_scaling_factor)	* kernel[62])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(3)][j+(-4)]		>>conv2D_scaling_factor)	* kernel[63])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(3)][j+(-3)]		>>conv2D_scaling_factor)	* kernel[64])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(3)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[65])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(3)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[66])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(3)][j+(0)]		>>conv2D_scaling_factor)	* kernel[67])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(3)][j+(1)]		>>conv2D_scaling_factor)	* kernel[68])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(3)][j+(2)]		>>conv2D_scaling_factor)	* kernel[69])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(3)][j+(3)]		>>conv2D_scaling_factor)	* kernel[70])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(3)][j+(4)]		>>conv2D_scaling_factor)	* kernel[71])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(4)][j+(-4)]		>>conv2D_scaling_factor)	* kernel[72])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(4)][j+(-3)]		>>conv2D_scaling_factor)	* kernel[73])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(4)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[74])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(4)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[75])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(4)][j+(0)]		>>conv2D_scaling_factor)	* kernel[76])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(4)][j+(1)]		>>conv2D_scaling_factor)	* kernel[77])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(4)][j+(2)]		>>conv2D_scaling_factor)	* kernel[78])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(4)][j+(3)]		>>conv2D_scaling_factor)	* kernel[79])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(4)][j+(4)]		>>conv2D_scaling_factor)	* kernel[80])>>		conv2D_out_scal)    ;   
		}                                                                                         
	}                                                                                         
}                                                                                         
#endif
#if B_ORDER == 11
	void conv2D_Zeropad_excplicit_11(int size, int (*matrix)[size], int *kernel_tmp, int *out){									
	#define KERN_EXPLICIT_11 11                                                                                 
	#define ZEROPAD_EXPLICIT_struct_11 10                                                                       
	#define ZEROPAD_EXPLICIT_offset_11 5                                                                       
	int print=0;                                                                                              	
	int kernel[KERN_EXPLICIT_11*KERN_EXPLICIT_11];                                                              
	int conv2D_scaling_factor=8;                                                                              	
	int conv2D_out_scal=5;                                                                                    	
	for(int i=0;i<KERN_EXPLICIT_11*KERN_EXPLICIT_11;i++){                                                       
		kernel[i]=(kernel_tmp[i]>>conv2D_scaling_factor);                                                       	
	}                                                                                                         	
	int i, j;                                                                                                 	
	int pt=0;                                                                                                 	
	int zeropad[Z_ORDER][Z_ORDER]={0};                                                                        	
	for (int i=ZEROPAD_EXPLICIT_offset_11; i< size+ZEROPAD_EXPLICIT_struct_11-ZEROPAD_EXPLICIT_offset_11; i++)  
		for (int j=ZEROPAD_EXPLICIT_offset_11; j< size+ZEROPAD_EXPLICIT_struct_11-ZEROPAD_EXPLICIT_offset_11; j++)
			zeropad[i][j]=matrix[i-ZEROPAD_EXPLICIT_offset_11][j-ZEROPAD_EXPLICIT_offset_11];                       
	for (i = 5; i < (size+(10))-(5); i++)                                                          
	{                                                                                         
		for (j = (5); j < (size+(10))-(5); j++)                                                          
		{                                                                                         
			pt=(i+(-5))*size+(j+(-5));                                                                      
			out[pt] +=	                                                                              
		(	(	(zeropad	[i+(-5)][j+(-5)]		>>conv2D_scaling_factor)	* kernel[0])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-5)][j+(-4)]		>>conv2D_scaling_factor)	* kernel[1])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-5)][j+(-3)]		>>conv2D_scaling_factor)	* kernel[2])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-5)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[3])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-5)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[4])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-5)][j+(0)]		>>conv2D_scaling_factor)	* kernel[5])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-5)][j+(1)]		>>conv2D_scaling_factor)	* kernel[6])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-5)][j+(2)]		>>conv2D_scaling_factor)	* kernel[7])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-5)][j+(3)]		>>conv2D_scaling_factor)	* kernel[8])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-5)][j+(4)]		>>conv2D_scaling_factor)	* kernel[9])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-5)][j+(5)]		>>conv2D_scaling_factor)	* kernel[10])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-4)][j+(-5)]		>>conv2D_scaling_factor)	* kernel[11])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-4)][j+(-4)]		>>conv2D_scaling_factor)	* kernel[12])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-4)][j+(-3)]		>>conv2D_scaling_factor)	* kernel[13])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-4)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[14])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-4)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[15])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-4)][j+(0)]		>>conv2D_scaling_factor)	* kernel[16])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-4)][j+(1)]		>>conv2D_scaling_factor)	* kernel[17])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-4)][j+(2)]		>>conv2D_scaling_factor)	* kernel[18])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-4)][j+(3)]		>>conv2D_scaling_factor)	* kernel[19])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-4)][j+(4)]		>>conv2D_scaling_factor)	* kernel[20])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-4)][j+(5)]		>>conv2D_scaling_factor)	* kernel[21])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-3)][j+(-5)]		>>conv2D_scaling_factor)	* kernel[22])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-3)][j+(-4)]		>>conv2D_scaling_factor)	* kernel[23])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-3)][j+(-3)]		>>conv2D_scaling_factor)	* kernel[24])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-3)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[25])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-3)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[26])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-3)][j+(0)]		>>conv2D_scaling_factor)	* kernel[27])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-3)][j+(1)]		>>conv2D_scaling_factor)	* kernel[28])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-3)][j+(2)]		>>conv2D_scaling_factor)	* kernel[29])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-3)][j+(3)]		>>conv2D_scaling_factor)	* kernel[30])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-3)][j+(4)]		>>conv2D_scaling_factor)	* kernel[31])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-3)][j+(5)]		>>conv2D_scaling_factor)	* kernel[32])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-2)][j+(-5)]		>>conv2D_scaling_factor)	* kernel[33])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-2)][j+(-4)]		>>conv2D_scaling_factor)	* kernel[34])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-2)][j+(-3)]		>>conv2D_scaling_factor)	* kernel[35])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-2)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[36])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-2)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[37])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-2)][j+(0)]		>>conv2D_scaling_factor)	* kernel[38])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-2)][j+(1)]		>>conv2D_scaling_factor)	* kernel[39])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-2)][j+(2)]		>>conv2D_scaling_factor)	* kernel[40])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-2)][j+(3)]		>>conv2D_scaling_factor)	* kernel[41])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-2)][j+(4)]		>>conv2D_scaling_factor)	* kernel[42])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-2)][j+(5)]		>>conv2D_scaling_factor)	* kernel[43])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-1)][j+(-5)]		>>conv2D_scaling_factor)	* kernel[44])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-1)][j+(-4)]		>>conv2D_scaling_factor)	* kernel[45])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-1)][j+(-3)]		>>conv2D_scaling_factor)	* kernel[46])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-1)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[47])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-1)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[48])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-1)][j+(0)]		>>conv2D_scaling_factor)	* kernel[49])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-1)][j+(1)]		>>conv2D_scaling_factor)	* kernel[50])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-1)][j+(2)]		>>conv2D_scaling_factor)	* kernel[51])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-1)][j+(3)]		>>conv2D_scaling_factor)	* kernel[52])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-1)][j+(4)]		>>conv2D_scaling_factor)	* kernel[53])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(-1)][j+(5)]		>>conv2D_scaling_factor)	* kernel[54])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(0)][j+(-5)]		>>conv2D_scaling_factor)	* kernel[55])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(0)][j+(-4)]		>>conv2D_scaling_factor)	* kernel[56])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(0)][j+(-3)]		>>conv2D_scaling_factor)	* kernel[57])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(0)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[58])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(0)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[59])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(0)][j+(0)]		>>conv2D_scaling_factor)	* kernel[60])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(0)][j+(1)]		>>conv2D_scaling_factor)	* kernel[61])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(0)][j+(2)]		>>conv2D_scaling_factor)	* kernel[62])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(0)][j+(3)]		>>conv2D_scaling_factor)	* kernel[63])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(0)][j+(4)]		>>conv2D_scaling_factor)	* kernel[64])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(0)][j+(5)]		>>conv2D_scaling_factor)	* kernel[65])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(1)][j+(-5)]		>>conv2D_scaling_factor)	* kernel[66])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(1)][j+(-4)]		>>conv2D_scaling_factor)	* kernel[67])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(1)][j+(-3)]		>>conv2D_scaling_factor)	* kernel[68])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(1)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[69])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(1)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[70])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(1)][j+(0)]		>>conv2D_scaling_factor)	* kernel[71])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(1)][j+(1)]		>>conv2D_scaling_factor)	* kernel[72])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(1)][j+(2)]		>>conv2D_scaling_factor)	* kernel[73])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(1)][j+(3)]		>>conv2D_scaling_factor)	* kernel[74])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(1)][j+(4)]		>>conv2D_scaling_factor)	* kernel[75])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(1)][j+(5)]		>>conv2D_scaling_factor)	* kernel[76])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(2)][j+(-5)]		>>conv2D_scaling_factor)	* kernel[77])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(2)][j+(-4)]		>>conv2D_scaling_factor)	* kernel[78])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(2)][j+(-3)]		>>conv2D_scaling_factor)	* kernel[79])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(2)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[80])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(2)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[81])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(2)][j+(0)]		>>conv2D_scaling_factor)	* kernel[82])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(2)][j+(1)]		>>conv2D_scaling_factor)	* kernel[83])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(2)][j+(2)]		>>conv2D_scaling_factor)	* kernel[84])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(2)][j+(3)]		>>conv2D_scaling_factor)	* kernel[85])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(2)][j+(4)]		>>conv2D_scaling_factor)	* kernel[86])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(2)][j+(5)]		>>conv2D_scaling_factor)	* kernel[87])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(3)][j+(-5)]		>>conv2D_scaling_factor)	* kernel[88])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(3)][j+(-4)]		>>conv2D_scaling_factor)	* kernel[89])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(3)][j+(-3)]		>>conv2D_scaling_factor)	* kernel[90])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(3)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[91])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(3)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[92])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(3)][j+(0)]		>>conv2D_scaling_factor)	* kernel[93])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(3)][j+(1)]		>>conv2D_scaling_factor)	* kernel[94])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(3)][j+(2)]		>>conv2D_scaling_factor)	* kernel[95])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(3)][j+(3)]		>>conv2D_scaling_factor)	* kernel[96])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(3)][j+(4)]		>>conv2D_scaling_factor)	* kernel[97])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(3)][j+(5)]		>>conv2D_scaling_factor)	* kernel[98])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(4)][j+(-5)]		>>conv2D_scaling_factor)	* kernel[99])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(4)][j+(-4)]		>>conv2D_scaling_factor)	* kernel[100])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(4)][j+(-3)]		>>conv2D_scaling_factor)	* kernel[101])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(4)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[102])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(4)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[103])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(4)][j+(0)]		>>conv2D_scaling_factor)	* kernel[104])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(4)][j+(1)]		>>conv2D_scaling_factor)	* kernel[105])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(4)][j+(2)]		>>conv2D_scaling_factor)	* kernel[106])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(4)][j+(3)]		>>conv2D_scaling_factor)	* kernel[107])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(4)][j+(4)]		>>conv2D_scaling_factor)	* kernel[108])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(4)][j+(5)]		>>conv2D_scaling_factor)	* kernel[109])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(5)][j+(-5)]		>>conv2D_scaling_factor)	* kernel[110])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(5)][j+(-4)]		>>conv2D_scaling_factor)	* kernel[111])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(5)][j+(-3)]		>>conv2D_scaling_factor)	* kernel[112])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(5)][j+(-2)]		>>conv2D_scaling_factor)	* kernel[113])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(5)][j+(-1)]		>>conv2D_scaling_factor)	* kernel[114])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(5)][j+(0)]		>>conv2D_scaling_factor)	* kernel[115])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(5)][j+(1)]		>>conv2D_scaling_factor)	* kernel[116])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(5)][j+(2)]		>>conv2D_scaling_factor)	* kernel[117])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(5)][j+(3)]		>>conv2D_scaling_factor)	* kernel[118])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(5)][j+(4)]		>>conv2D_scaling_factor)	* kernel[119])>>		conv2D_out_scal)    +   
		(	(	(zeropad	[i+(5)][j+(5)]		>>conv2D_scaling_factor)	* kernel[120])>>		conv2D_out_scal)    ;   
		}                                                                                         
	}                                                                                         
}                                                                                         // // --------------------------------------------------------------------------------------------------------------------------------
#endif

//------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------
void convolution2D_Zeropadding(int size, int (*matrix)[size], int *kernel_tmp, int *out){
	int print=0;
	int kernel[9];
	int conv2D_scaling_factor=8;
	int conv2D_out_scal=5;
	for(int i=0;i<9;i++){
    	kernel[i]=(kernel_tmp[i]>>conv2D_scaling_factor);
	}
	int i, j;
	int pt=0;
	int zeropad[Z_ORDER][Z_ORDER]={0};
	
	for (int i=1; i< size+2-1; i++)
		for (int j=1; j< size+2-1; j++)
			zeropad[i][j]=matrix[i-1][j-1];
	
	// for (int i=0; i<Z_ORDER; i++){
		// for (int j=0; j< Z_ORDER; j++){
			// printf("%d ",zeropadd[i][j]);
		// }
		// printf("\n");
	// }

	// kernel 										E centrale
	// for (i = 1; i < (size+2)-1; i++)
	// {
		// for (j = 1; j < (size+2)-1; j++)
		// {
			// pt=(i-1)*size+(j-1);
			// out[pt] +=	(	(	(zeropad[i-1][j-1]>>conv2D_scaling_factor) 	* kernel[0])>>		conv2D_out_scal)    +
									// (	(	(zeropad[i-1][j]	>>conv2D_scaling_factor)	* kernel[1])>>		conv2D_out_scal)    +
									// (	(	(zeropad[i-1][j+1]>>conv2D_scaling_factor)	* kernel[2])>>		conv2D_out_scal)    +
									// (	(	(zeropad[i][j-1]	>>conv2D_scaling_factor)	* kernel[3])>>		conv2D_out_scal)    +
									// (	(	(zeropad[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>		conv2D_out_scal)    +
									// (	(	(zeropad[i][j+1]	>>conv2D_scaling_factor)	* kernel[5])>>		conv2D_out_scal)    +
									// (	(	(zeropad[i+1][j-1]>>conv2D_scaling_factor) 	* kernel[6])>>		conv2D_out_scal)    +
									// (	(	(zeropad[i+1][j] >>conv2D_scaling_factor)		* kernel[7])>>		conv2D_out_scal)    +
									// (	(	(zeropad[i+1][j+1]>>conv2D_scaling_factor) 	* kernel[8])>>		conv2D_out_scal)   ;
		// }
	// }
	for (i = 1; i < (size+2)-1; i++)
	{
		for (j = 1; j < (size+2)-1; j++)
			out[(i-1)*size+(j-1)] +=	(	(	(zeropad[i-1][j-1]>>conv2D_scaling_factor) 	* kernel[0])>>		conv2D_out_scal);
		for (j = 1; j < (size+2)-1; j++)
			out[(i-1)*size+(j-1)] +=	(	(	(zeropad[i-1][j]	>>conv2D_scaling_factor)	* kernel[1])>>		conv2D_out_scal);
		for (j = 1; j < (size+2)-1; j++)
			out[(i-1)*size+(j-1)] +=	(	(	(zeropad[i-1][j+1]>>conv2D_scaling_factor)	* kernel[2])>>		conv2D_out_scal);
		for (j = 1; j < (size+2)-1; j++)
			out[(i-1)*size+(j-1)] +=	(	(	(zeropad[i][j-1]	>>conv2D_scaling_factor)	* kernel[3])>>		conv2D_out_scal);
		for (j = 1; j < (size+2)-1; j++)
			out[(i-1)*size+(j-1)] +=	(	(	(zeropad[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>		conv2D_out_scal);
		for (j = 1; j < (size+2)-1; j++)
			out[(i-1)*size+(j-1)] +=	(	(	(zeropad[i][j+1]	>>conv2D_scaling_factor)	* kernel[5])>>		conv2D_out_scal);
		for (j = 1; j < (size+2)-1; j++)
			out[(i-1)*size+(j-1)] +=	(	(	(zeropad[i+1][j-1]>>conv2D_scaling_factor) 	* kernel[6])>>		conv2D_out_scal);
		for (j = 1; j < (size+2)-1; j++)
			out[(i-1)*size+(j-1)] +=	(	(	(zeropad[i+1][j] >>conv2D_scaling_factor)		* kernel[7])>>		conv2D_out_scal);
		for (j = 1; j < (size+2)-1; j++)
			out[(i-1)*size+(j-1)] +=	(	(	(zeropad[i+1][j+1]>>conv2D_scaling_factor) 	* kernel[8])>>		conv2D_out_scal);
	}
}
void convolution2D_Zeropadding_3(int size, int (*matrix)[size], int *kernel_tmp, int *out){
	#define Krn_3 3
	#define structural_diff_3 2
		#define Z_MAT_3 A_ORDER + structural_diff_3
	int str_diff=2;
	int centering_offset=1;
	
	int print=0;
	int conv2D_scaling_factor=8;
	int conv2D_out_scal=5;
	int i, j;
	int pt=0;
	int k_index=0;
	
	int kernel[Krn_3*Krn_3];
	for(int i=0;i<Krn_3*Krn_3;i++){
    	kernel[i]=(kernel_tmp[i]>>conv2D_scaling_factor);
	}
	
	// int zeropad[A_ORDER+str_diff][A_ORDER+str_diff]={0};	
	int zeropad[Z_MAT_3][Z_MAT_3]={0};	
	for (int i= centering_offset; i	< A_ORDER	+	str_diff	-	centering_offset	; i++) {
		for (int j= centering_offset; j	< A_ORDER	+	str_diff	-	centering_offset	; j++) {
			zeropad[i][j]=matrix[i-centering_offset][j-centering_offset];
		}
	}
	
	// kernel 	E centrale
	for (i = centering_offset ; i < A_ORDER	+	str_diff	-centering_offset	; i++)
	{
		for (int ROW_k_SCAN= -centering_offset; ROW_k_SCAN <= centering_offset; ROW_k_SCAN++){
			for (int CLM_k_SCAN= -centering_offset; CLM_k_SCAN <= centering_offset; CLM_k_SCAN++){
				for (j = centering_offset ; j < A_ORDER	+	str_diff	-centering_offset	; j++){
					out[(i-centering_offset)*size+(j-centering_offset)] +=		(	(	(zeropad[i + ROW_k_SCAN][j + CLM_k_SCAN]>>conv2D_scaling_factor) 	* kernel[k_index])>>		conv2D_out_scal);
				}
				k_index++;
			}
		}
		k_index=0;
	}

}
void convolution2D_Zeropadding_5(int size, int (*matrix)[size], int *kernel_tmp, int *out){
	#define Krn_5 5
	#define structural_diff_5 4
		#define Z_MAT_5 A_ORDER + structural_diff_5
	int str_diff=4;
	int centering_offset=2;
	
	int print=0;
	int conv2D_scaling_factor=8;
	int conv2D_out_scal=5;
	int i, j;
	int pt=0;
	int k_index=0;
	
	int kernel[Krn_5*Krn_5];
	for(int i=0;i<Krn_5*Krn_5;i++){
    	kernel[i]=(kernel_tmp[i]>>conv2D_scaling_factor);
	}
	
	// int zeropad[A_ORDER+str_diff][A_ORDER+str_diff]={0};	
	int zeropad[Z_MAT_5][Z_MAT_5]={0};	
	for (int i= centering_offset; i	< A_ORDER	+	str_diff	-	centering_offset	; i++) {
		for (int j= centering_offset; j	< A_ORDER	+	str_diff	-	centering_offset	; j++) {
			zeropad[i][j]=matrix[ -centering_offset + i ][ -centering_offset + j];
		}
	}
	
	// kernel 	E centrale
	for (i = centering_offset ; i < A_ORDER	+	str_diff	-centering_offset	; i++)
	{
		for (int ROW_k_SCAN= -centering_offset; ROW_k_SCAN <= centering_offset; ROW_k_SCAN++){
			for (int CLM_k_SCAN= -centering_offset; CLM_k_SCAN <= centering_offset; CLM_k_SCAN++){
				for (j = centering_offset ; j < A_ORDER	+	str_diff	-centering_offset	; j++){
					out[(i-centering_offset)*size+(j-centering_offset)] +=		(	(	(zeropad[i + ROW_k_SCAN][j + CLM_k_SCAN]>>conv2D_scaling_factor) 	* kernel[k_index])>>		conv2D_out_scal);
				}
				k_index++;
			}
		}
		k_index=0;
	}

}
void convolution2D_Zeropadding_7(int size, int (*matrix)[size], int *kernel_tmp, int *out){
	#define Krn_7 7
	#define structural_diff_7 6
		#define Z_MAT_7 A_ORDER + structural_diff_7
	int str_diff=6;
	int centering_offset=3;
	
	int print=0;
	int conv2D_scaling_factor=8;
	int conv2D_out_scal=5;
	int i, j;
	int pt=0;
	int k_index=0;
	
	int kernel[Krn_7*Krn_7];
	for(int i=0;i<Krn_7*Krn_7;i++){
    	kernel[i]=(kernel_tmp[i]>>conv2D_scaling_factor);
	}
	
	// int zeropad[A_ORDER+str_diff][A_ORDER+str_diff]={0};	
	int zeropad[Z_MAT_7][Z_MAT_7]={0};	
	for (int i= centering_offset; i	< A_ORDER	+	str_diff	-	centering_offset	; i++) {
		for (int j= centering_offset; j	< A_ORDER	+	str_diff	-	centering_offset	; j++) {
			zeropad[i][j]=matrix[ -centering_offset + i ][ -centering_offset + j];
		}
	}
	
	// kernel 	E centrale
	for (i = centering_offset ; i < A_ORDER	+	str_diff	-centering_offset	; i++)
	{
		for (int ROW_k_SCAN= -centering_offset; ROW_k_SCAN <= centering_offset; ROW_k_SCAN++){
			for (int CLM_k_SCAN= -centering_offset; CLM_k_SCAN <= centering_offset; CLM_k_SCAN++){
				for (j = centering_offset ; j < A_ORDER	+	str_diff	-centering_offset	; j++){
					out[(i-centering_offset)*size+(j-centering_offset)] +=		(	(	(zeropad[i + ROW_k_SCAN][j + CLM_k_SCAN]>>conv2D_scaling_factor) 	* kernel[k_index])>>		conv2D_out_scal);
				}
				k_index++;
			}
		}
		k_index=0;
	}

}
void convolution2D_Zeropadding_9(int size, int (*matrix)[size], int *kernel_tmp, int *out){
	#define Krn_9 9
	#define structural_diff_9 8
		#define Z_MAT_9 A_ORDER + structural_diff_9
	int str_diff=8;
	int centering_offset=4;
	
	int print=0;
	int conv2D_scaling_factor=8;
	int conv2D_out_scal=5;
	int i, j;
	int pt=0;
	int k_index=0;
	
	int kernel[Krn_9*Krn_9];
	for(int i=0;i<Krn_9*Krn_9;i++){
    	kernel[i]=(kernel_tmp[i]>>conv2D_scaling_factor);
	}
	
	// int zeropad[A_ORDER+str_diff][A_ORDER+str_diff]={0};	
	int zeropad[Z_MAT_9][Z_MAT_9]={0};	
	for (int i= centering_offset; i	< A_ORDER	+	str_diff	-	centering_offset	; i++) {
		for (int j= centering_offset; j	< A_ORDER	+	str_diff	-	centering_offset	; j++) {
			zeropad[i][j]=matrix[ -centering_offset + i ][ -centering_offset + j];
		}
	}
	
	// kernel 	E centrale
	for (i = centering_offset ; i < A_ORDER	+	str_diff	-centering_offset	; i++)
	{
		for (int ROW_k_SCAN= -centering_offset; ROW_k_SCAN <= centering_offset; ROW_k_SCAN++){
			for (int CLM_k_SCAN= -centering_offset; CLM_k_SCAN <= centering_offset; CLM_k_SCAN++){
				for (j = centering_offset ; j < A_ORDER	+	str_diff	-centering_offset	; j++){
					out[(i-centering_offset)*size+(j-centering_offset)] +=		(	(	(zeropad[i + ROW_k_SCAN][j + CLM_k_SCAN]>>conv2D_scaling_factor) 	* kernel[k_index])>>		conv2D_out_scal);
				}
				k_index++;
			}
		}
		k_index=0;
	}

}
void convolution2D_Zeropadding_11(int size, int (*matrix)[size], int *kernel_tmp, int *out){
	#define Krn_11 11
	#define structural_diff_11 10
		#define Z_MAT_11 A_ORDER + structural_diff_11
	int str_diff=10;
	int centering_offset=5;
	
	int print=0;
	int conv2D_scaling_factor=8;
	int conv2D_out_scal=5;
	int i, j;
	int pt=0;
	int k_index=0;
	
	int kernel[Krn_11*Krn_11];
	for(int i=0;i<Krn_11*Krn_11;i++){
    	kernel[i]=(kernel_tmp[i]>>conv2D_scaling_factor);
	}
	
	// int zeropad[A_ORDER+str_diff][A_ORDER+str_diff]={0};	
	int zeropad[Z_MAT_11][Z_MAT_11]={0};	
	for (int i= centering_offset; i	< A_ORDER	+	str_diff	-	centering_offset	; i++) {
		for (int j= centering_offset; j	< A_ORDER	+	str_diff	-	centering_offset	; j++) {
			zeropad[i][j]=matrix[ -centering_offset + i ][ -centering_offset + j];
		}
	}
	
	// kernel 	E centrale
	for (i = centering_offset ; i < A_ORDER	+	str_diff	-centering_offset	; i++)
	{
		for (int ROW_k_SCAN= -centering_offset; ROW_k_SCAN <= centering_offset; ROW_k_SCAN++){
			for (int CLM_k_SCAN= -centering_offset; CLM_k_SCAN <= centering_offset; CLM_k_SCAN++){
				for (j = centering_offset ; j < A_ORDER	+	str_diff	-centering_offset	; j++){
					out[(i-centering_offset)*size+(j-centering_offset)] +=		(	(	(zeropad[i + ROW_k_SCAN][j + CLM_k_SCAN]>>conv2D_scaling_factor) 	* kernel[k_index])>>		conv2D_out_scal);
				}
				k_index++;
			}
		}
		k_index=0;
	}

}
// // --------------------------------------------------------------------------------------------------------------------------------
// // --------------------------------------------------------------------------------------------------------------------------------
// // --------------------------------------------------------------------------------------------------------------------------------
//base algorithm for check pourposes
void matrix_check( int* mat1, int* mat2, int size ){
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
void matrix_check_thread( int* mat1, int* mat2, int size, int thread){
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
void matrix_check_v2( int* mat1, int* mat2, int size){
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
void matrix_check_v3( int* mat1, int* mat2, int size ){
	printf("Checking if there is an error...");
  int err=0;
	for(int i=0; i<size; i++)
	{
		for(int j=0; j<size; j++)
		{
			if ( *((int*)mat1+i*size+j) != *((int*)mat2+i*size+j) ) {
        err++;
			}
		}
	}
  if (err==0)  printf("No errors.\n");
	else  printf("There are %d errors\n",err);
}
// // --------------------------------------------------------------------------------------------------------------------------------
// // --------------------------------------------------------------------------------------------------------------------------------
// // --------------------------------------------------------------------------------------------------------------------------------
void matrix_print(int* pt, int size, int mode){
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
// // --------------------------------------------------------------------------------------------------------------------------------
// // --------------------------------------------------------------------------------------------------------------------------------// // --------------------------------------------------------------------------------------------------------------------------------
// // --------------------------------------------------------------------------------------------------------------------------------
void convolution2D_Zeropadding_region_0(int size, int (*matrix)[size], int *kernel_tmp, int *out){
	int print=0;
	int kernel[9];
	int conv2D_scaling_factor=8;
	int conv2D_out_scal=5;
	for(int i=0;i<9;i++){
    	kernel[i]=(kernel_tmp[i]>>conv2D_scaling_factor);
	}
	int i, j;
	int pt=0;
	int zeropad[Z_ORDER][Z_ORDER]={0};
	for (int i=1; i< size+2-1; i++)
		for (int j=1; j< size+2-1; j++)
			zeropad[i][j]=matrix[i-1][j-1];

	int region[2];
	region[0]=(size+2)/3;
	region[1]=region[0]*2;
	
	for (i = 1; i < region[0]; i++)
	// for (i = region[0]; i < region[1]; i++)
	// for (i = region[1]; i < (size+2)-1; i++)
	{
		for (j = 1; j < (size+2)-1; j++)
		{
			pt=(i-1)*size+(j-1);
			out[pt] +=	(	(	(zeropad[i-1][j-1]>>conv2D_scaling_factor) 	* kernel[0])>>		conv2D_out_scal)    +
									(	(	(zeropad[i-1][j]	>>conv2D_scaling_factor)	* kernel[1])>>		conv2D_out_scal)    +
									(	(	(zeropad[i-1][j+1]>>conv2D_scaling_factor)	* kernel[2])>>		conv2D_out_scal)    +
									(	(	(zeropad[i][j-1]	>>conv2D_scaling_factor)	* kernel[3])>>		conv2D_out_scal)    +
									(	(	(zeropad[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>		conv2D_out_scal)    +
									(	(	(zeropad[i][j+1]	>>conv2D_scaling_factor)	* kernel[5])>>		conv2D_out_scal)    +
									(	(	(zeropad[i+1][j-1]>>conv2D_scaling_factor) 	* kernel[6])>>		conv2D_out_scal)    +
									(	(	(zeropad[i+1][j] >>conv2D_scaling_factor)		* kernel[7])>>		conv2D_out_scal)    +
									(	(	(zeropad[i+1][j+1]>>conv2D_scaling_factor) 	* kernel[8])>>		conv2D_out_scal)   ;
		}
	}
}
void convolution2D_Zeropadding_region_1(int size, int (*matrix)[size], int *kernel_tmp, int *out){
	int print=0;
	int kernel[9];
	int conv2D_scaling_factor=8;
	int conv2D_out_scal=5;
	for(int i=0;i<9;i++){
    	kernel[i]=(kernel_tmp[i]>>conv2D_scaling_factor);
	}
	int i, j;
	int pt=0;
	int zeropad[Z_ORDER][Z_ORDER]={0};
	for (int i=1; i< size+2-1; i++)
		for (int j=1; j< size+2-1; j++)
			zeropad[i][j]=matrix[i-1][j-1];

	int region[2];
	region[0]=(size+2)/3;
	region[1]=region[0]*2;
	
	// for (i = 1; i < region[0]; i++)
	for (i = region[0]; i < region[1]; i++)
	// for (i = region[1]; i < (size+2)-1; i++)
	{
		for (j = 1; j < (size+2)-1; j++)
		{
			pt=(i-1)*size+(j-1);
			out[pt] +=	(	(	(zeropad[i-1][j-1]>>conv2D_scaling_factor) 	* kernel[0])>>		conv2D_out_scal)    +
									(	(	(zeropad[i-1][j]	>>conv2D_scaling_factor)	* kernel[1])>>		conv2D_out_scal)    +
									(	(	(zeropad[i-1][j+1]>>conv2D_scaling_factor)	* kernel[2])>>		conv2D_out_scal)    +
									(	(	(zeropad[i][j-1]	>>conv2D_scaling_factor)	* kernel[3])>>		conv2D_out_scal)    +
									(	(	(zeropad[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>		conv2D_out_scal)    +
									(	(	(zeropad[i][j+1]	>>conv2D_scaling_factor)	* kernel[5])>>		conv2D_out_scal)    +
									(	(	(zeropad[i+1][j-1]>>conv2D_scaling_factor) 	* kernel[6])>>		conv2D_out_scal)    +
									(	(	(zeropad[i+1][j] >>conv2D_scaling_factor)		* kernel[7])>>		conv2D_out_scal)    +
									(	(	(zeropad[i+1][j+1]>>conv2D_scaling_factor) 	* kernel[8])>>		conv2D_out_scal)   ;
		}
	}
}
void convolution2D_Zeropadding_region_2(int size, int (*matrix)[size], int *kernel_tmp, int *out){
	int print=0;
	int kernel[9];
	int conv2D_scaling_factor=8;
	int conv2D_out_scal=5;
	for(int i=0;i<9;i++){
    	kernel[i]=(kernel_tmp[i]>>conv2D_scaling_factor);
	}
	int i, j;
	int pt=0;
	int zeropad[Z_ORDER][Z_ORDER]={0};
	for (int i=1; i< size+2-1; i++)
		for (int j=1; j< size+2-1; j++)
			zeropad[i][j]=matrix[i-1][j-1];

	int region[2];
	region[0]=(size+2)/3;
	region[1]=region[0]*2;
	
	// for (i = 1; i < region[0]; i++)
	// for (i = region[0]; i < region[1]; i++)
	for (i = region[1]; i < (size+2)-1; i++)
	{
		for (j = 1; j < (size+2)-1; j++)
		{
			pt=(i-1)*size+(j-1);
			out[pt] +=	(	(	(zeropad[i-1][j-1]>>conv2D_scaling_factor) 	* kernel[0])>>		conv2D_out_scal)    +
									(	(	(zeropad[i-1][j]	>>conv2D_scaling_factor)	* kernel[1])>>		conv2D_out_scal)    +
									(	(	(zeropad[i-1][j+1]>>conv2D_scaling_factor)	* kernel[2])>>		conv2D_out_scal)    +
									(	(	(zeropad[i][j-1]	>>conv2D_scaling_factor)	* kernel[3])>>		conv2D_out_scal)    +
									(	(	(zeropad[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>		conv2D_out_scal)    +
									(	(	(zeropad[i][j+1]	>>conv2D_scaling_factor)	* kernel[5])>>		conv2D_out_scal)    +
									(	(	(zeropad[i+1][j-1]>>conv2D_scaling_factor) 	* kernel[6])>>		conv2D_out_scal)    +
									(	(	(zeropad[i+1][j] >>conv2D_scaling_factor)		* kernel[7])>>		conv2D_out_scal)    +
									(	(	(zeropad[i+1][j+1]>>conv2D_scaling_factor) 	* kernel[8])>>		conv2D_out_scal)   ;
		}
	}
}
// // --------------------------------------------------------------------------------------------------------------------------------
// // --------------------------------------------------------------------------------------------------------------------------------
// // --------------------------------------------------------------------------------------------------------------------------------
void convolution2D_Subkernels(int size, int (*matrix)[size], int *kernel_tmp, int *out){
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
								(((matrix[i-1][j]	>>conv2D_scaling_factor)		* kernel[1])>>		conv2D_out_scal)     +
								(((matrix[i][j-1]	>>conv2D_scaling_factor)		* kernel[3])>>		conv2D_out_scal)     +
								(((matrix[i][j]	>>conv2D_scaling_factor)			* kernel[4])>>		conv2D_out_scal)     +
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
void convolution2D_Subkernels_0(int size, int (*matrix)[size], int *kernel_tmp, int *out){
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
		int region[2];
	region[0]=(size+2)/3;
	region[1]=region[0]*2;
	
	// for (i = 1; i < region[0]; i++)
	// for (i = region[0]; i < region[1]; i++)
	// for (i = region[1]; i < (size+2)-1; i++)

		///////////////////////////////////

	//scandisci tutta l'ultima						colonna	F
	j=(size-1);
	for (i = 1; i < region[0]; i++)
	{
		pt=i*size+j;
		out[pt] +=	(((matrix[i-1][j-1]>>conv2D_scaling_factor) 	* kernel[0])>>		conv2D_out_scal)     +
					(((matrix[i-1][j]	>>conv2D_scaling_factor)	* kernel[1])>>		conv2D_out_scal)     +
					(((matrix[i][j-1]	>>conv2D_scaling_factor)	* kernel[3])>>		conv2D_out_scal)     +
					(((matrix[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>		conv2D_out_scal)     +
					(((matrix[i+1][j-1]>>conv2D_scaling_factor) 	* kernel[6])>>		conv2D_out_scal)     +
					(((matrix[i+1][j] >>conv2D_scaling_factor)		* kernel[7])>>		conv2D_out_scal)    ;
	}
													//alto sinistra A
	i=0;
	j=0;
	pt=i*size+j;
		out[pt] +=	(((matrix[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>			conv2D_out_scal) 	 +
					(((matrix[i][j+1]>>conv2D_scaling_factor)		* kernel[5])>>			conv2D_out_scal)	 +
					(((matrix[i+1][j] >>conv2D_scaling_factor)		* kernel[7])>>			conv2D_out_scal)	 +
					(((matrix[i+1][j+1]>>conv2D_scaling_factor) 	* kernel[8])>>			conv2D_out_scal)	;
	///////////////////////////////////
	//vertice alto a destra 						C
	i=0;
	j=(size-1);
	pt=i*size+j;
		out[pt] +=	(((matrix[i][j-1]>>conv2D_scaling_factor)		* kernel[3])>>			conv2D_out_scal) 	  +
					(((matrix[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>			conv2D_out_scal) 	  +
					(((matrix[i+1][j-1]>>conv2D_scaling_factor) 	* kernel[6])>>			conv2D_out_scal) 	  +
					(((matrix[i+1][j] >>conv2D_scaling_factor)		* kernel[7])>>			conv2D_out_scal) 	 ;
	//scandisci tutta la prima colonna 				D
	j=0;
	for (i = 1; i < region[0]; i++)
	{
		pt=i*size+j;
		out[pt] +=	(((matrix[i-1][j]>>conv2D_scaling_factor)	* kernel[1])>>			conv2D_out_scal) 	   +
					(((matrix[i-1][j+1]>>conv2D_scaling_factor)	* kernel[2])>>			conv2D_out_scal) 	   +
					(((matrix[i][j]	>>conv2D_scaling_factor)	* kernel[4])>>			conv2D_out_scal) 	   +
					(((matrix[i][j+1]>>conv2D_scaling_factor)	* kernel[5])>>			conv2D_out_scal) 	   +
					(((matrix[i+1][j] >>conv2D_scaling_factor)	* kernel[7])>>			conv2D_out_scal) 	   +
					(((matrix[i+1][j+1]>>conv2D_scaling_factor) * kernel[8])>>			conv2D_out_scal) 	  ;
	}
	///////////////////////////////////
	// kernel 										E centrale
	for (i = 1; i < region[0]; i++)
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

}
void convolution2D_Subkernels_1(int size, int (*matrix)[size], int *kernel_tmp, int *out){
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
		int region[2];
	region[0]=(size+2)/3;
	region[1]=region[0]*2;
	
	// for (i = 1; i < region[0]; i++)
	// for (i = region[0]; i < region[1]; i++)
	// for (i = region[1]; i < (size+2)-1; i++)

		///////////////////////////////////

	//scandisci tutta l'ultima						colonna	F
	j=(size-1);
	for (i = region[0]; i < region[1]; i++)
	{
		pt=i*size+j;
		out[pt] +=	(((matrix[i-1][j-1]>>conv2D_scaling_factor) 	* kernel[0])>>		conv2D_out_scal)     +
					(((matrix[i-1][j]	>>conv2D_scaling_factor)	* kernel[1])>>		conv2D_out_scal)     +
					(((matrix[i][j-1]	>>conv2D_scaling_factor)	* kernel[3])>>		conv2D_out_scal)     +
					(((matrix[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>		conv2D_out_scal)     +
					(((matrix[i+1][j-1]>>conv2D_scaling_factor) 	* kernel[6])>>		conv2D_out_scal)     +
					(((matrix[i+1][j] >>conv2D_scaling_factor)		* kernel[7])>>		conv2D_out_scal)    ;

	//scandisci tutta la prima colonna 				D
	j=0;
	for (i = region[0]; i < region[1]; i++)
	{
		pt=i*size+j;
		out[pt] +=	(((matrix[i-1][j]>>conv2D_scaling_factor)	* kernel[1])>>			conv2D_out_scal) 	   +
					(((matrix[i-1][j+1]>>conv2D_scaling_factor)	* kernel[2])>>			conv2D_out_scal) 	   +
					(((matrix[i][j]	>>conv2D_scaling_factor)	* kernel[4])>>			conv2D_out_scal) 	   +
					(((matrix[i][j+1]>>conv2D_scaling_factor)	* kernel[5])>>			conv2D_out_scal) 	   +
					(((matrix[i+1][j] >>conv2D_scaling_factor)	* kernel[7])>>			conv2D_out_scal) 	   +
					(((matrix[i+1][j+1]>>conv2D_scaling_factor) * kernel[8])>>			conv2D_out_scal) 	  ;
	}
	///////////////////////////////////
	// kernel 										E centrale
	for (i = region[0]; i < region[1]; i++)
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
	///////////////////////////////////
}
}
void convolution2D_Subkernels_2(int size, int (*matrix)[size], int *kernel_tmp, int *out){
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
		int region[2];
	region[0]=(size+2)/3;
	region[1]=region[0]*2;
	
	// for (i = 1; i < region[0]; i++)
	// for (i = region[0]; i < region[1]; i++)
	// for (i = region[1]; i < (size+2)-1; i++)

		///////////////////////////////////

	//scandisci tutta l'ultima						colonna	F
	j=(size-1);
	for (i = region[1]; i < (size+2)-1; i++)
	{
		pt=i*size+j;
		out[pt] +=	(((matrix[i-1][j-1]>>conv2D_scaling_factor) 	* kernel[0])>>		conv2D_out_scal)     +
					(((matrix[i-1][j]	>>conv2D_scaling_factor)	* kernel[1])>>		conv2D_out_scal)     +
					(((matrix[i][j-1]	>>conv2D_scaling_factor)	* kernel[3])>>		conv2D_out_scal)     +
					(((matrix[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>		conv2D_out_scal)     +
					(((matrix[i+1][j-1]>>conv2D_scaling_factor) 	* kernel[6])>>		conv2D_out_scal)     +
					(((matrix[i+1][j] >>conv2D_scaling_factor)		* kernel[7])>>		conv2D_out_scal)    ;
	}
	//in basso a 									sinistra G
	j=0;
	i=size-1;
	pt=i*size+j;
		out[pt] +=	(((matrix[i-1][j]	>>conv2D_scaling_factor)	* kernel[1])>>		conv2D_out_scal)     +
					(((matrix[i-1][j+1]>>conv2D_scaling_factor)		* kernel[2])>>		conv2D_out_scal)     +
					(((matrix[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>		conv2D_out_scal)     +
					(((matrix[i][j+1]	>>conv2D_scaling_factor)	* kernel[5])>>		conv2D_out_scal)    ;
	///////////////////////////////////
	//in basso a 									destra	I
	i=(size-1);
	j=size-1;
	pt=i*size+j;
		out[pt] +=	(((matrix[i-1][j-1]>>conv2D_scaling_factor) 	* kernel[0])>>		conv2D_out_scal)     +
					(((matrix[i-1][j]	>>conv2D_scaling_factor)	* kernel[1])>>		conv2D_out_scal)     +
					(((matrix[i][j-1]	>>conv2D_scaling_factor)	* kernel[3])>>		conv2D_out_scal)     +
					(((matrix[i][j]	>>conv2D_scaling_factor)		* kernel[4])>>		conv2D_out_scal)    ;
	///////////////////////////////////
	//scandisci tutta la prima colonna 				D
	j=0;
	for (i = region[1]; i < (size+2)-1; i++)
	{
		pt=i*size+j;
		out[pt] +=	(((matrix[i-1][j]>>conv2D_scaling_factor)	* kernel[1])>>			conv2D_out_scal) 	   +
					(((matrix[i-1][j+1]>>conv2D_scaling_factor)	* kernel[2])>>			conv2D_out_scal) 	   +
					(((matrix[i][j]	>>conv2D_scaling_factor)	* kernel[4])>>			conv2D_out_scal) 	   +
					(((matrix[i][j+1]>>conv2D_scaling_factor)	* kernel[5])>>			conv2D_out_scal) 	   +
					(((matrix[i+1][j] >>conv2D_scaling_factor)	* kernel[7])>>			conv2D_out_scal) 	   +
					(((matrix[i+1][j+1]>>conv2D_scaling_factor) * kernel[8])>>			conv2D_out_scal) 	  ;
	}
	///////////////////////////////////
	// kernel 										E centrale
	for (i = region[1]; i < (size+2)-1; i++)
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
}
