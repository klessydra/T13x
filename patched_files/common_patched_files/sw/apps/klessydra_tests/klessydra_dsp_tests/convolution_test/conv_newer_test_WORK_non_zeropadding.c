#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include "dsp_functions.h"
#include "functions.h"
#include "klessydra_defs.h"

#define A_ORDER 7
#define B_ORDER 3
#define K_COL (B_ORDER+1)
// #define A_ORDER A_ORDER

int matA[A_ORDER*A_ORDER];
int dimension_A=A_ORDER*A_ORDER*sizeof(int);

int zeros[A_ORDER*A_ORDER] = {0};
// int dimension_A=A_ORDER*A_ORDER*sizeof(int);

int matB[B_ORDER*B_ORDER] = {0};
int dimension_B=B_ORDER*B_ORDER*sizeof(int);

int temp_arr[A_ORDER*A_ORDER]={0};
int temp_arr_1[A_ORDER*A_ORDER]={0};
int pref_buff[4]={0};
int temp=16;
int result[A_ORDER*A_ORDER]; //delle stesse dimensioni di matrice A
int perf=0;
int perf32=0;
int* ptr_perf = &perf;

void spegni_threads();
void zeropadding (int * matrix, int size, int* padding);
void display_spm_matrix(int size_r,int size_c,void* pt_spm_mat);
void matrix_print(int* pt, int size);
void convolution2D(int size, int *input, int size_k, int *kernel, int *output);
void convolution2D_kernels(int size, int (*matrix)[size], int *kernel, int *out);
void matrix_check( int* mat1, int* mat2, int size );

//------------------------------------------------------------------------------------------------------------
// 													MAIN
//------------------------------------------------------------------------------------------------------------
int main()
{
  spegni_threads();
  printf("\n********Test %dx%d*********\n",A_ORDER,A_ORDER);
  CSR_MVSIZE(9*sizeof(int));
  __asm__("csrrw zero, mcycle, zero");
	int clean[A_ORDER*A_ORDER];
	for(int i =0;i<A_ORDER*A_ORDER; i++)
  {
    clean[i]=0;
  }
	kmemld((void*)spmaddrC, (void*)clean, dimension_A); //così da riempire preventivamente la scpm con valori zero
	kmemld((void*)spmaddrD, (void*)clean, dimension_A); //così da riempire preventivamente la scpm con valori zero

	// for(int i =0;i<A_ORDER*A_ORDER; i++)
  // {
  //   matA[i]=(1+i);
  // }
	// Test for the shifting of ksrav32_v2 works fine
	int shifting=0;
	for(int i =0;i<A_ORDER*A_ORDER; i++)
  {
    matA[i]=(1+i)<<shifting;
  }

	zeropadding((int*)matA,A_ORDER,(int*)zeros);
	// matrix_print((int*)zeros,A_ORDER);
	kmemld((void*)spmaddrD, (void*)zeros, dimension_A);
  //I make the counter-shift and save in spmaddrA the intended matrix
  ksrav32_v2((void*)spmaddrA,(void*)spmaddrD,(int*)shifting,dimension_A);
	// display_spm_matrix(A_ORDER,A_ORDER, (void*)spmaddrA);
  // I clean spmaddrD, since i used it for making the ksrav32
	kmemld((void*)spmaddrD, (void*)clean, dimension_A);
	// display_spm_matrix(A_ORDER,A_ORDER, (void*)spmaddrZ);

	for(int i=0; i<B_ORDER*B_ORDER; i++) //scrivo dei valori randomici sul kernel
  {
    matB[i]=1+i;
  }
	kmemld((void*)spmaddrB, (void*)matB, dimension_B);
	// display_spm_matrix(B_ORDER,B_ORDER, (void*)spmaddrB);


	//------------------------------------------------------------------------------------------------------------
  //	Convolution with Ksvmulsc&Kaddv32 + Kdotp32&Kaddv32. Mixed approach and no zeropadding of input matrix
  //------------------------------------------------------------------------------------------------------------
  //Scrivo in spmD la matrice A non zeropadded
  kmemld((void*)spmaddrD, (void*)matA, dimension_A);
  //rimetto sulla matrice A la matrice dopo aver fatto lo shifting a destra
  ksrav32_v2((void*)spmaddrA,(void*)spmaddrD,(int*)shifting,dimension_A);
 	// display_spm_matrix(A_ORDER,A_ORDER, (void*)spmaddrA);

  //I clean every other scratchpad
  kmemld((void*)spmaddrC, (void*)clean, dimension_A);
  kmemld((void*)spmaddrB, (void*)clean, dimension_A);
  kmemld((void*)spmaddrD, (void*)clean, dimension_A);
	void* dest_in_C_zero=(void*)(	(int*)(spmaddrC)	);
	void* dest_in_B_zero=(void*)(	(int*)(spmaddrB)	);
	void* dest_in_D_zero=(void*)(	(int*)(spmaddrD)	);
  //Pointers to Spms and other index that i'll need for the convolution
	void* dest_in_C=(void*)(	(int*)	(spmaddrC)	);
  void* dest_in_B=(void*)(	(int*)	(spmaddrB)	);
  void* dest_in_D=(void*)(	(int*)	(spmaddrD)	);

  int k_element=0;
  int mat_int_shift=0; //internal shifting for properly pointing insied the spms while making kaddv32
	int size=A_ORDER; //si riferisce alla matrice in input
	int jump_fm_row=A_ORDER; // determina il salto della ·matrice zeropadded
	int jump_kr_row=B_ORDER; // determina il salto della riga per la matrice kernel zeropadded
	int kern_offset=0;
	int fm_offset=0;
	kmemld((void*)spmaddrB, (void*)matB, dimension_B);



  // // ENABLE COUNTING -------------------------------------------------------------------------
  // perf32=0;
  // __asm__("csrrw zero, mcycle, zero;"
  //     "csrrw zero, 0x7A0, 0x00000001");
  // //------------------------------------------------------------------------------------------

	//______________________________sub_kernel A
	CSR_MVSIZE(2*sizeof(int));
	dest_in_C	=		dest_in_C_zero + sizeof(int)*(0)*(jump_fm_row-1); //[0]
	dest_in_D	=		dest_in_D_zero + sizeof(int)*(0)*(jump_fm_row-1);
	kern_offset	=	1;
	fm_offset		=	0;
	kdotp32(dest_in_D,		(void*)(	(int*)spmaddrA+	(0)*jump_fm_row			+fm_offset	),	(void*) ( (int*)spmaddrB+(1)*jump_kr_row+	kern_offset ));
	kdotp32(dest_in_C,		(void*)(	(int*)spmaddrA+	(1)*jump_fm_row			+fm_offset	),	(void*) ( (int*)spmaddrB+(2)*jump_kr_row+	kern_offset ));

	//______________________________sub_kernel C
	dest_in_C	=		dest_in_C_zero + sizeof(int)*(1)*(jump_fm_row-1); //[4]
	dest_in_D	=		dest_in_D_zero + sizeof(int)*(1)*(jump_fm_row-1);
	kern_offset	=	0;
	fm_offset		=	(jump_fm_row-1-1);
	kdotp32(dest_in_D,		(void*)(	(int*)spmaddrA+	(0)*jump_fm_row			+ fm_offset	),	(void*) ( (int*)spmaddrB+(1)*jump_kr_row+	kern_offset ));
	kdotp32(dest_in_C,		(void*)(	(int*)spmaddrA+	(1)*jump_fm_row			+ fm_offset	),	(void*) ( (int*)spmaddrB+(2)*jump_kr_row+	kern_offset ));

	//______________________________sub_kernel G
	dest_in_C	=		dest_in_C_zero + sizeof(int)*(size)*(jump_fm_row-1); //[20]
	dest_in_D	=		dest_in_D_zero + sizeof(int)*(size)*(jump_fm_row-1);
	kern_offset	=	1;
	fm_offset		=	0;
	kdotp32(dest_in_D,		(void*)(	(int*)spmaddrA+	(size-1-1)*jump_fm_row			+fm_offset	),	(void*) ( (int*)spmaddrB+(0)*jump_kr_row+	kern_offset ));
	kdotp32(dest_in_C,		(void*)(	(int*)spmaddrA+	(size-1)	*jump_fm_row			+fm_offset	),	(void*) ( (int*)spmaddrB+(1)*jump_kr_row+	kern_offset ));

	//______________________________sub_kernel I
	dest_in_C	=		dest_in_C_zero + sizeof(int)*(size+1)*(jump_fm_row-1); //[24]
	dest_in_D	=		dest_in_D_zero + sizeof(int)*(size+1)*(jump_fm_row-1);
	kern_offset	=	0;
	fm_offset		=	(jump_fm_row-1-1);
	kdotp32(dest_in_D,		(void*)(	(int*)spmaddrA+	(size-1-1)*jump_fm_row			+fm_offset	),	(void*) ( (int*)spmaddrB+(0)*jump_kr_row+	kern_offset ));
	kdotp32(dest_in_C,		(void*)(	(int*)spmaddrA+	(size-1)	*jump_fm_row			+fm_offset	),	(void*) ( (int*)spmaddrB+(1)*jump_kr_row+	kern_offset ));

	//______________________________sommo i parziali prodotti dei sub_kernels A-C-G-I
	CSR_MVSIZE(size*size*sizeof(int));
	kaddv32(dest_in_C_zero,		dest_in_C_zero,		dest_in_D_zero);
	// display_spm_matrix(A_ORDER,A_ORDER, (void*)spmaddrC);

  //______________________________sub_kernel E
	//resetti matrice D preventivamente
	kmemld((void*)spmaddrD, (void*)clean, dimension_A); //così da riempire preventivamente la scpm con valori zero
	for(int i=1; i< size-1;i++)
	{
		dest_in_C	= dest_in_C_zero + sizeof(int)*(A_ORDER*i)+1*sizeof(int);
		dest_in_D	= dest_in_D_zero + sizeof(int)*(A_ORDER*i)+1*sizeof(int);
		k_element=0;
		mat_int_shift=A_ORDER*(i-1);
		for (int rw_pt=-1; rw_pt<2; rw_pt++) //rw_pt is an index i use to point to the correct row, regarding this loop that is executed three times
		//instead of making 9 different ksvmulrf32
		{
			CSR_MVSIZE((size-2)*sizeof(int));
			ksvmulsc32(dest_in_D,			(void*)	( (int*)spmaddrA + (i+rw_pt)*jump_fm_row	+0 ),	(void*)	( (int*)spmaddrB+k_element++) );
			CSR_MVSIZE(	(size*size-mat_int_shift)*sizeof(int)	);
			kaddv32 (dest_in_C, dest_in_C, dest_in_D);

			CSR_MVSIZE((size-2)*sizeof(int));
			ksvmulsc32(dest_in_D,			(void*)	( (int*)spmaddrA + (i+rw_pt)*jump_fm_row	+1 ),	(void*)	( (int*)spmaddrB+k_element++) );
			CSR_MVSIZE(	(size*size-mat_int_shift)*sizeof(int)	);
			kaddv32	(dest_in_C, dest_in_C, dest_in_D);

			CSR_MVSIZE((size-2)*sizeof(int));
			ksvmulsc32(dest_in_D,			(void*)	( (int*)spmaddrA + (i+rw_pt)*jump_fm_row	+2 ),	(void*)	( (int*)spmaddrB+k_element++) );
			CSR_MVSIZE(	(size*size-mat_int_shift)*sizeof(int)	);
			kaddv32 (dest_in_C, dest_in_C, dest_in_D);
		}
	}
	// display_spm_matrix(A_ORDER,A_ORDER, (void*)spmaddrC);
	//______________________________sub_kernel B
	//resetti matrice D preventivamente
	kmemld((void*)spmaddrD, (void*)clean, dimension_A); //così da riempire preventivamente la scpm con valori zero
	for(int i=0; i< 1;i++)
	{
		dest_in_C	= dest_in_C_zero + 1*sizeof(int);
    dest_in_D	= dest_in_D_zero + 1*sizeof(int);
		k_element=3;
		mat_int_shift=A_ORDER*(i-1);
		for (int rw_pt=0; rw_pt<2; rw_pt++) //rw_pt is an index i use to point to the correct row, regarding this loop that is executed three times
		//instead of making 9 different ksvmulrf32
		{
			CSR_MVSIZE((size-2)*sizeof(int));
			ksvmulsc32(dest_in_D,			(void*)	( (int*)spmaddrA + (i+rw_pt)*jump_fm_row	+0 ),	(void*)	( (int*)spmaddrB+k_element++) );
			CSR_MVSIZE(	(size*size-mat_int_shift)*sizeof(int)	);
			kaddv32 (dest_in_C, dest_in_C, dest_in_D);
			CSR_MVSIZE((size-2)*sizeof(int));
			ksvmulsc32(dest_in_D,			(void*)	( (int*)spmaddrA + (i+rw_pt)*jump_fm_row	+1 ),	(void*)	( (int*)spmaddrB+k_element++) );
			CSR_MVSIZE(	(size*size-mat_int_shift)*sizeof(int)	);
			kaddv32	(dest_in_C, dest_in_C, dest_in_D);
			CSR_MVSIZE((size-2)*sizeof(int));
			ksvmulsc32(dest_in_D,			(void*)	( (int*)spmaddrA + (i+rw_pt)*jump_fm_row	+2 ),	(void*)	( (int*)spmaddrB+k_element++) );
			CSR_MVSIZE(	(size*size-mat_int_shift)*sizeof(int)	);
			kaddv32 (dest_in_C, dest_in_C, dest_in_D);
		}
	}

	//______________________________sub_kernel H
	//resetti matrice D preventivamente
	kmemld((void*)spmaddrD, (void*)clean, dimension_A); //così da riempire preventivamente la scpm con valori zero
	for(int i=size-1; i< size;i++)
	{
		dest_in_C	= dest_in_C_zero + sizeof(int)*(A_ORDER*i)+1*sizeof(int);
    dest_in_D	= dest_in_D_zero + sizeof(int)*(A_ORDER*i)+1*sizeof(int);
		k_element=0;
		mat_int_shift=A_ORDER*(i-1);
		for (int rw_pt=-1; rw_pt<1; rw_pt++) //rw_pt is an index i use to point to the correct row, regarding this loop that is executed three times
		//instead of making 9 different ksvmulrf32
		{
			CSR_MVSIZE((size-2)*sizeof(int));
			ksvmulsc32(dest_in_D,			(void*)	( (int*)spmaddrA + (i+rw_pt)*jump_fm_row	+0 ),	(void*)	( (int*)spmaddrB+k_element++) );
			CSR_MVSIZE(	(size*size-mat_int_shift)*sizeof(int)	);
			kaddv32 (dest_in_C, dest_in_C, dest_in_D);
			CSR_MVSIZE((size-2)*sizeof(int));
			ksvmulsc32(dest_in_D,			(void*)	( (int*)spmaddrA + (i+rw_pt)*jump_fm_row	+1 ),	(void*)	( (int*)spmaddrB+k_element++) );
			CSR_MVSIZE(	(size*size-mat_int_shift)*sizeof(int)	);
			kaddv32	(dest_in_C, dest_in_C, dest_in_D);
			CSR_MVSIZE((size-2)*sizeof(int));
			ksvmulsc32(dest_in_D,			(void*)	( (int*)spmaddrA + (i+rw_pt)*jump_fm_row	+2 ),	(void*)	( (int*)spmaddrB+k_element++) );
			CSR_MVSIZE(	(size*size-mat_int_shift)*sizeof(int)	);
			kaddv32 (dest_in_C, dest_in_C, dest_in_D);
		}
	}

	//______________________________sub_kernel D
	//resetti matrice D preventivamente
	kmemld((void*)spmaddrD, (void*)clean, dimension_A); //così da riempire preventivamente la scpm con valori zero
	for(int i=1; i< size-1;i++){
		dest_in_C	= dest_in_C_zero + sizeof(int)*(A_ORDER*i);
		dest_in_D	= dest_in_D_zero + sizeof(int)*(A_ORDER*i);
		dest_in_B = dest_in_B_zero + sizeof(int)*(B_ORDER*B_ORDER);
		// k_element=0;
		// mat_int_shift=A_ORDER*(i-1);
		kern_offset	=	1;
		fm_offset		=	0;
		CSR_MVSIZE(2*sizeof(int));
		kdotp32(dest_in_D,		(void*)(	(int*)spmaddrA+	(i-1)*jump_fm_row			+fm_offset	),	(void*) ( (int*)spmaddrB+(0)*jump_kr_row+	kern_offset ));
		kdotp32(dest_in_C,		(void*)(	(int*)spmaddrA+	(i)*jump_fm_row				+fm_offset	),	(void*) ( (int*)spmaddrB+(1)*jump_kr_row+	kern_offset ));
		kaddv32(dest_in_C, dest_in_C, dest_in_D);
		kdotp32(dest_in_D,		(void*)(	(int*)spmaddrA+	(i+1)*jump_fm_row			+fm_offset	),	(void*) ( (int*)spmaddrB+(2)*jump_kr_row+	kern_offset ));
		kaddv32(dest_in_C, dest_in_C, dest_in_D);
	}
	// display_spm_matrix(A_ORDER,A_ORDER, (void*)spmaddrC);

	//______________________________sub_kernel F
	//resetti matrice D preventivamente
	kmemld((void*)spmaddrD, (void*)clean, dimension_A); //così da riempire preventivamente la scpm con valori zero
	for(int i=1; i< size-1;i++){
		// dest_in_C	= dest_in_C_zero + sizeof(int)*(A_ORDER*i)+ sizeof(int)*(1)*(jump_fm_row-1);
		// dest_in_D	= dest_in_D_zero + sizeof(int)*(A_ORDER*i)+ sizeof(int)*(1)*(jump_fm_row-1);
		dest_in_C	= dest_in_C_zero + sizeof(int)*(A_ORDER*i)+ sizeof(int)*(1)*(jump_fm_row-1);
		dest_in_D	= dest_in_D_zero + sizeof(int)*(A_ORDER*i)+ sizeof(int)*(1)*(jump_fm_row-1);
		kern_offset	=	0;
		fm_offset= (jump_fm_row-1-1);
		CSR_MVSIZE(2*sizeof(int));
		kdotp32(dest_in_D,		(void*)(	(int*)spmaddrA+	(i-1)*jump_fm_row			+fm_offset	),	(void*) ( (int*)spmaddrB+(0)*jump_kr_row+	kern_offset ));
		kdotp32(dest_in_C,		(void*)(	(int*)spmaddrA+	(i)*jump_fm_row				+fm_offset	),	(void*) ( (int*)spmaddrB+(1)*jump_kr_row+	kern_offset ));
		kaddv32(dest_in_C, dest_in_C, dest_in_D);
		kdotp32(dest_in_D,		(void*)(	(int*)spmaddrA+	(i+1)*jump_fm_row			+fm_offset	),	(void*) ( (int*)spmaddrB+(2)*jump_kr_row+	kern_offset ));
		kaddv32(dest_in_C, dest_in_C, dest_in_D);
	}

	// // DISABLE COUNTING AND SAVE MCYCLE -------------------------------------------------------
  // __asm__("csrrw zero, 0x7A0, 0x00000000;"
  //     "csrrw %[perf], mcycle, zero;"
  //     "sw %[perf], 0(%[ptr_perf]);"
  //     :
  //     :[perf] "r" (perf), [ptr_perf] "r" (ptr_perf)
  //     );
  // perf32=perf;
  // printf("Convolution with Ksvmulsc&Kaddv32 + Kdotp32&Kaddv32 Speed is: %d Cycles\n", perf32);
  // //------------------------------------------------------------------------------------------

  printf("Display convolution with Ksvmulsc&Kaddv32 + Kdotp32&Kaddv32 matrix:\n");
	display_spm_matrix(A_ORDER,A_ORDER, (void*)spmaddrC);
	//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



	//------------------------------------------------------------------------------------------------------------
	// I check if the output is correct and performance of Convolution2D
	//------------------------------------------------------------------------------------------------------------
  //I move back the convoluted matrix into memmory, inside matrix"zeros" just for convenience
  kmemstr((void*)zeros, (void*)spmaddrC, dimension_A);
	int output_compare[A_ORDER*A_ORDER]={0};
	for(int i =0;i<A_ORDER*A_ORDER; i++)
  //I make these assinments so that i compute the base matrix,
  //not the one that I shift while being inside the spms
	{
		matA[i]=(1+i);
	}
  // ENABLE COUNTING -------------------------------------------------------------------------
	perf32=0;
  __asm__("csrrw zero, mcycle, zero;"
			"csrrw zero, 0x7A0, 0x00000001");
	//------------------------------------------------------------------------------------------
	convolution2D(A_ORDER, (int*)matA, B_ORDER, (int*)matB, (int*)output_compare);
  // DISABLE COUNTING AND SAVE MCYCLE -------------------------------------------------------
  __asm__("csrrw zero, 0x7A0, 0x00000000;"
      "csrrw %[perf], mcycle, zero;"
      "sw %[perf], 0(%[ptr_perf]);"
      :
      :[perf] "r" (perf), [ptr_perf] "r" (ptr_perf)
      );
  perf32=perf;
  printf("Convolution with Convolution2D()\n\tInput matrix not zeropadded\n\tsimple version of algorithm\n\tno DSP involved:\n\t\t%d Cycles\n", perf32);
  //------------------------------------------------------------------------------------------
	printf("Display convolution done in memory with a normal function for convolution in 2D:\n");
	matrix_print((int*)output_compare, A_ORDER);
  printf("Matrix_check:\tMEM:Convolution2D simple\tVS\tACCEL\n");
	matrix_check((int*)output_compare,(int*)zeros,A_ORDER);

  //------------------------------------------------------------------------------------------------------------
  // Performance of convolution2D_kernels
  //------------------------------------------------------------------------------------------------------------
  for(int i =0;i<A_ORDER*A_ORDER; i++)
  {
    output_compare[i]=0;
  }
  int mat_second_A[A_ORDER][A_ORDER];
  for(int i =0;i<A_ORDER; i++)
  {
    for(int j=0; j<A_ORDER; j++){
      mat_second_A[i][j]=(i*A_ORDER+j+1);
    }
  }
  // ENABLE COUNTING -------------------------------------------------------------------------
  perf32=0;
  __asm__("csrrw zero, mcycle, zero;"
      "csrrw zero, 0x7A0, 0x00000001");
  //------------------------------------------------------------------------------------------
  convolution2D_kernels(A_ORDER, (int*)mat_second_A, (int*)matB, (int*)output_compare);
  // DISABLE COUNTING AND SAVE MCYCLE -------------------------------------------------------
  __asm__("csrrw zero, 0x7A0, 0x00000000;"
      "csrrw %[perf], mcycle, zero;"
      "sw %[perf], 0(%[ptr_perf]);"
      :
      :[perf] "r" (perf), [ptr_perf] "r" (ptr_perf)
      );
  perf32=perf;
  printf("Convolution with Convolution2D()\n\tInput matrix not zeropadded\n\tsub_kernels algorithm\n\tno DSP involved:\n\t\t%d Cycles\n", perf32);
  //------------------------------------------------------------------------------------------
	printf("Display convolution done in memory with convolution kernels in 2D:\n");
	// matrix_print((int*)output_compare, A_ORDER);
	printf("Matrix_check:\tMEM:Convolution2D sub_kernels\tVS\tACCEL\n");
	matrix_check((int*)output_compare,(int*)zeros,A_ORDER);


  printf("\n");
	return 0;
}




//------------------------------------------------------------------------------------------------------------
// Functions
//------------------------------------------------------------------------------------------------------------
//base algorithm for check pourposes
void convolution2D(int size, int *input, int size_k, int *kernel, int *output)
{
	const int kCenter = size_k/2;
	for (int i = 0; i < size; i++)
	{
		for (int j = 0; j < size; j++)
		{
			for (int m = 0; m < size_k; m++)     // kernel rows
			{
				for (int n = 0; n < size_k; n++)     // kernel columns
				{
					// indexes of input signal, used for checking boundaries
					int ii = i + (m - kCenter);
					int jj = j + (n - kCenter);

					// ignore input samples which are out of bound
					if (ii >= 0 && ii < size && jj >= 0 && jj < size)
						output[j + size*i] += input[jj + size*ii] * kernel[n + size_k*m];
				}
			}
		}
	}
}
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
  printf("Spengo_th\n");
}
//
void zeropadding (int * matrix, int size, int* padding)
{
//size si riferisce alle dimensioni della matrice di partenza
  for (int i = 0; i < size; i++)
  {
    for (int j = 0; j < size; j++)
    {
      padding[(i+1)*(size+2)+(j+1)] = matrix[i*size+j];
    }
  }
}
void display_spm_matrix(int size_r,int size_c,void* pt_spm_mat)
{
  printf("\n--------------------------------------\n");
  printf("\t\t-------Display_matrix 0x_@%d-----\n",pt_spm_mat);
  int pref_buff[4]={0};
  int k=0,quad=0,temp=0;
  for(int i=0; i<size_r; i++)
  {
    for(int j=0; j<size_c; j++)
    {
      if((i*size_c+j)==0) ;
      else if((i*size_c+j)%4==0)
      {
        quad++;
        k=0;
      }
      kmemstr(
        (void*)pref_buff,
				(  (void*) (   pt_spm_mat + quad*16  ) ),
				4*sizeof(int)
			);

      temp=pref_buff[k];
			// printf("\t[%02d]  %02d",(i*size_c+j),temp);
			printf("\t%02d",temp);
      k++;
    }
    printf("\n");
  }
  printf("\t\t-------Display_matrix 0x_@%d-----\n",pt_spm_mat);
  printf("--------------------------------------\n\n");
}
void matrix_print(int* pt, int size)
{
	for(int i=0; i<size; i++)
	{
		for(int j=0; j<size; j++)
		{
			printf("\t%d",*((int*)pt+i*size+j));
		}
		printf("\n");
	}
}
void convolution2D_kernels(int size, int (*matrix)[size], int *kernel, int *out)
{

	int i, j;
	int pt=0;
	///////////////////////////////////
													//alto sinistra A
	i=0;
	j=0;
	pt=i*size+j;
		out[pt] +=	matrix[i][j]			* kernel[4] +
					matrix[i][j+1]		* kernel[5] +
					matrix[i+1][j] 	* kernel[7] +
					matrix[i+1][j+1] 	* kernel[8];
	///////////////////////////////////
	//scandisci tutta la prima riga tra i due		 vertici alti 	B
	i=0;
	for (j = 1; j < size-1; j++)
	{
		pt=i*size+j;
		out[pt] +=	matrix[i][j-1]		* kernel[3] +
					matrix[i][j]			* kernel[4] +
					matrix[i][j+1]		* kernel[5] +
					matrix[i+1][j-1] 	* kernel[6] +
					matrix[i+1][j] 	* kernel[7] +
					matrix[i+1][j+1] 	* kernel[8];
	}
	///////////////////////////////////
	//vertice alto a destra 						C
	i=0;
	j=(size-1);
	pt=i*size+j;
		out[pt] +=	matrix[i][j-1]		* kernel[3] +
					matrix[i][j]			* kernel[4] +
					matrix[i+1][j-1] 	* kernel[6] +
					matrix[i+1][j] 	* kernel[7];
		//printf("out[%d]=%d\n",pt,(int)out[pt]);
	//scandisci tutta la prima colonna 				D
	j=0;
	for(i = 1; i < size-1 ; i++)
	{
		pt=i*size+j;
		out[pt] +=	matrix[i-1][j]	* kernel[1] +
					matrix[i-1][j+1]	* kernel[2] +
					matrix[i][j]			* kernel[4] +
					matrix[i][j+1]		* kernel[5] +
					matrix[i+1][j] 	* kernel[7] +
					matrix[i+1][j+1] 	* kernel[8];
	}
	// kernel 										E centrale
	for (i = 1; i < size-1; i++)
	{
		for (j = 1; j < size-1; j++)
		{
			pt=i*size+j;
			out[pt] +=	matrix[i-1][j-1] 	* kernel[0] +
						matrix[i-1][j]	* kernel[1] +
						matrix[i-1][j+1]	* kernel[2] +
						matrix[i][j-1]		* kernel[3] +
						matrix[i][j]			* kernel[4] +
						matrix[i][j+1]		* kernel[5] +
						matrix[i+1][j-1] 	* kernel[6] +
						matrix[i+1][j] 	* kernel[7] +
						matrix[i+1][j+1] 	* kernel[8];
		}
	}
	//scandisci tutta l'ultima						colonna	F
	j=(size-1);
	for(i = 1; i < size-1 ; i++)
	{
		pt=i*size+j;
		out[pt] +=	matrix[i-1][j-1] 	* kernel[0] +
					matrix[i-1][j]	* kernel[1] +
					matrix[i][j-1]		* kernel[3] +
					matrix[i][j]			* kernel[4] +
					matrix[i+1][j-1] 	* kernel[6] +
					matrix[i+1][j] 	* kernel[7];
	}
	//in basso a 									sinistra G
	j=0;
	i=size-1;
	pt=i*size+j;
		out[pt] +=	matrix[i-1][j]	* kernel[1] +
					matrix[i-1][j+1]	* kernel[2] +
					matrix[i][j]			* kernel[4] +
					matrix[i][j+1]		* kernel[5];
	//scandisci tutta l'ultima riga tra i due vertici bassi	 H
	for (j = 1; j < size-1; j++)
	{
		pt=i*size+j;
		out[pt] +=	matrix[i-1][j-1] 	* kernel[0] +
					matrix[i-1][j]	* kernel[1] +
					matrix[i-1][j+1]	* kernel[2] +
					matrix[i][j-1]		* kernel[3] +
					matrix[i][j]			* kernel[4] +
					matrix[i][j+1]		* kernel[5];
	}
	//in basso a 									destra	I
	i=(size-1);
	j=size-1;
	pt=i*size+j;
		out[pt] +=	matrix[i-1][j-1] 	* kernel[0] +
					matrix[i-1][j]	* kernel[1] +
					matrix[i][j-1]		* kernel[3] +
					matrix[i][j]			* kernel[4];
}
