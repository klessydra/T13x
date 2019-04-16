#include"dsp_functions.h"
#include"functions.h"
#include<stdio.h>
#include<stdlib.h>

#define A_ORDER 30
#define B_ORDER 3
#define K_ROW B_ORDER
#define DIRT_ORDER 10
#define K_COL (B_ORDER+1)
#define K_SQ_ORDER (K_ROW * K_COL)
#define Z_ORDER (A_ORDER+2)
#define K_CENTER (B_ORDER/2)

int matA[A_ORDER*A_ORDER];
int dimension_A=A_ORDER*A_ORDER*sizeof(int);
int zeros[Z_ORDER*Z_ORDER] = {0};
int dimension_Z=Z_ORDER*Z_ORDER*sizeof(int);
int dirt[DIRT_ORDER*DIRT_ORDER]={0};
int dimension_dir=DIRT_ORDER*DIRT_ORDER*sizeof(int);

int matB[B_ORDER*B_ORDER] = {0};
int dimension_B=B_ORDER*B_ORDER*sizeof(int);

int kern[K_SQ_ORDER] = {0};
int dimension_K=K_SQ_ORDER*sizeof(int);
int temp_arr[A_ORDER*A_ORDER]={0};
int temp_arr_1[A_ORDER*A_ORDER]={0};
int pref_buff[4]={0};
int temp=16;
int result[A_ORDER*A_ORDER]; //delle stesse dimensioni di matrice A

void spegni_threads();
void zeropadding (int * matrix, int size, int* padding);
void zeropadding_kern (int * matrix, int size, int* padding);
void display_spm_matrix(int size_r,int size_c,void* pt_spm_mat);
void matrix_print(int* pt, int size);
void convolution2D(int size, int *input, int size_k, int *kernel, int *output);
void matrix_check( int* mat1, int* mat2, int size );

//------------------------------------------------------------------------------------------------------------
// 													MAIN
//------------------------------------------------------------------------------------------------------------
int main()
{
  printf("\n*****************\n");
  spegni_threads();
  CSR_MVSIZE(9*sizeof(int));
  __asm__("csrrw zero, mcycle, zero");
	int clean[Z_ORDER*Z_ORDER];
	for(int i =0;i<Z_ORDER*Z_ORDER; i++)
  {
    clean[i]=0;
  }
	kmemld((void*)spmaddrC, (void*)clean, dimension_Z); //così da riempire preventivamente la scpm con valori zero
	kmemld((void*)spmaddrD, (void*)clean, dimension_Z); //così da riempire preventivamente la scpm con valori zero

	// for(int i =0;i<A_ORDER*A_ORDER; i++)
  // {
  //   matA[i]=(1+i);
  // }
	// Test for the shifting of ksrav32_v2 works fine
	int shifting=9;
	for(int i =0;i<A_ORDER*A_ORDER; i++)
  {
    matA[i]=(1+i)<<shifting;
  }
	zeropadding((int*)matA,A_ORDER,(int*)zeros);
	// matrix_print((int*)zeros,Z_ORDER);
	kmemld((void*)spmaddrD, (void*)zeros, dimension_Z);
	ksrav32_v2((void*)spmaddrA,(void*)spmaddrD,shifting,dimension_Z); //I make the counter-shift and save in spmaddrA the intended matrix
	// display_spm_matrix(Z_ORDER,Z_ORDER, (void*)spmaddrA);
	kmemld((void*)spmaddrD, (void*)clean, dimension_Z); // I clean spmaddrD, since i used it for making the ksrav32
	// zeropadding((int*)matA,A_ORDER,(int*)zeros);
	// kmemld((void*)spmaddrA, (void*)zeros, dimension_Z); //scrivo in spmA la matrice zeropadded
	// display_spm_matrix(Z_ORDER,Z_ORDER, (void*)spmaddrA);
	for(int i=0; i<B_ORDER*B_ORDER; i++) //scrivo dei valori randomici sul kernel
  {
    matB[i]=1+i;
  }
	// zeropadding_kern((int *)matB, B_ORDER, (int*)kern);
	kmemld((void*)spmaddrB, (void*)matB, dimension_B);
	// display_spm_matrix(B_ORDER,B_ORDER, (void*)spmaddrB);


	//------------------------------------------------------------------------------------------------------------
	// Convolution with Kdotp32 and Kaddv32
	//------------------------------------------------------------------------------------------------------------
	//imposto delle nuove cooridnate globali
	int size=A_ORDER; //si riferisce alla matrice in input, serve a limitare il doppioloop nella matrice zeropadded
	int jump_fm_row=Z_ORDER; // determina il salto della matrice zeropadded
	int jump_kr_row=B_ORDER; // determina il salto della riga per la matrice kernel zeropadded
	void* dest_in_C=(void*)((int*)spmaddrC);

	// for(int i=1; i< size+1;i++) //index of rows is like having the centroid of older functions
	// {
	// 	for (int off=0; off < size; off++)
	// 	{
	// 		CSR_MVSIZE(3*sizeof(int));
	// 		kdotp32(dest_in_C,											(void*)(	(int*)spmaddrA+	(i-1)		*jump_fm_row+off	),	(void*) ( (int*)spmaddrB+(0)*jump_kr_row ));
	// 		kdotp32((void*)((int*)(spmaddrD)),			(void*)(	(int*)spmaddrA+	(i)			*jump_fm_row+off	),	(void*) ( (int*)spmaddrB+(1)*jump_kr_row ));
	// 		kdotp32((void*)((int*)(spmaddrD+16)),		(void*)(	(int*)spmaddrA+	(i+1)		*jump_fm_row+off	),	(void*) ( (int*)spmaddrB+(2)*jump_kr_row ));
	// 		CSR_MVSIZE(1*sizeof(int));
	// 		kaddv32((void*)(int*)(spmaddrA),		dest_in_C,									(void*) (int*)(spmaddrD));
	// 		kaddv32(dest_in_C,									(void*)((int*)(spmaddrA)),	(void*) (int*)(spmaddrD+16));
	// 		dest_in_C+= 4 ;
	// 	}
	// }
	// printf("Convolution with Kdotp32 and Kaddv32:");
	// display_spm_matrix(A_ORDER,A_ORDER, (void*)spmaddrC);



	//------------------------------------------------------------------------------------------------------------
	//	Convolution with ksvmulrd and Kaddv32
	//------------------------------------------------------------------------------------------------------------
	//riscrivo in spmD la matrice zeropadded e shiftata a sinistra
	kmemld((void*)spmaddrD, (void*)zeros, dimension_Z);
	//rimetto sulla matrice A la matrice dopo aver fatto lo shifting a destra
	ksrav32_v2((void*)spmaddrA,(void*)spmaddrD,shifting,dimension_Z);
	//I clean every other scratchpad
	kmemld((void*)spmaddrC, (void*)clean, dimension_Z);
	kmemld((void*)spmaddrB, (void*)clean, dimension_Z);
	kmemld((void*)spmaddrD, (void*)clean, dimension_Z);
	//Pointers to Spms and other index that i'll need for the convolution
	dest_in_C=(void*)(	(int*)	(spmaddrC)	);
	void* dest_in_B=(void*)(	(int*)	(spmaddrB)	);
	void* dest_in_D=(void*)(	(int*)	(spmaddrD)	);
	void* dest_in_C_zero=(void*)(	(int*)(spmaddrC)	);
	void* dest_in_B_zero=(void*)(	(int*)(spmaddrB)	);
	void* dest_in_D_zero=(void*)(	(int*)(spmaddrD)	);
	int k_element=0;
	int mat_int_shift=0; //internal shifting for properly pointing insied the spms while making kaddv32

	for(int i=1; i< size+1;i++)
	{
		dest_in_C	= dest_in_C_zero + sizeof(int)*A_ORDER*(i-1);
		dest_in_B	= dest_in_B_zero + sizeof(int)*A_ORDER*(i-1);
		dest_in_D	= dest_in_D_zero + sizeof(int)*A_ORDER*(i-1);
		k_element=0;
		mat_int_shift=A_ORDER*(i-1);
		for (int rw_pt=-1; rw_pt<2; rw_pt++) //rw_pt is an index i use to point to the correct row, regarding this loop that is executed three times
    //instead of making 9 different ksvmulrf32
    {
			// kmemld((void*)spmaddrD, (void*)clean, dimension_A);
			CSR_MVSIZE((size)*sizeof(int));
			ksvmulrf32(dest_in_D,			(void*)	( (int*)spmaddrA + (i+rw_pt)*jump_fm_row	+0 ),	(void*)	( (int*)matB[k_element++] ));
			CSR_MVSIZE(	(size*size-mat_int_shift)*sizeof(int)	);
			kaddv32 (dest_in_B, dest_in_C, dest_in_D);
			// kmemld((void*)spmaddrC, (void*)clean, dimension_A);
			CSR_MVSIZE((size)*sizeof(int));
			ksvmulrf32(dest_in_C,			(void*)	( (int*)spmaddrA + (i+rw_pt)*jump_fm_row	+1 ),	(void*)	( (int*)matB[k_element++] ));
			CSR_MVSIZE(	(size*size-mat_int_shift)*sizeof(int)	);
			kaddv32	(dest_in_D, dest_in_B, dest_in_C);
			// kmemld((void*)spmaddrB, (void*)clean, dimension_A);
			CSR_MVSIZE((size)*sizeof(int));
			ksvmulrf32(dest_in_B,			(void*)	( (int*)spmaddrA + (i+rw_pt)*jump_fm_row	+2 ),	(void*)	( (int*)matB[k_element++] ));
			CSR_MVSIZE(	(size*size-mat_int_shift)*sizeof(int)	);
			kaddv32 (dest_in_C, dest_in_D, dest_in_B);
		}
	}
	printf("Convolution with ksvmulrd and Kaddv32:");
	//display_spm_matrix(A_ORDER,A_ORDER, (void*)spmaddrC);


	//------------------------------------------------------------------------------------------------------------
	// I check if the output is correct
	//------------------------------------------------------------------------------------------------------------

  kmemstr((void*)zeros, (void*)spmaddrC, dimension_Z); //i move back the convoluted matrix into mem.matrix zeros just for convenience
	int output_compare[A_ORDER*A_ORDER]={0};
	for(int i =0;i<A_ORDER*A_ORDER; i++) //I make these assinments so that i compute the base matrix, not the one that i shift while being in the spms
	{
		matA[i]=(1+i);
	}
	convolution2D(A_ORDER, (int*)matA, B_ORDER, (int*)matB, (int*)output_compare);
	// printf("Convolution done in memory with a normal function for convolutio in 2D:");
	// matrix_print((int*)output_compare, A_ORDER);
	matrix_check((int*)output_compare,(int*)zeros,A_ORDER);

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
void zeropadding_kern (int * matrix, int size, int* padding)
{
  int shift=0;
  for (int i = 0; i < size; i++)
  {
    for (int j = 0; j < size; j++)
    {
      if(((i*size+j)%size)==0 && (i*size+j)!= 0)
      {
        shift++;
      }
      padding[i*size+j+shift] = matrix[i*size+j];
    }
  }
}
//
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
