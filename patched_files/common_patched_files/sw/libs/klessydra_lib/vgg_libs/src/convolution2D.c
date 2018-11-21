#include"definitions_data_test.h"

// void convolution2D_KH(int size, const float (*matrix)[size], float *kernel, float *out) {
	// int i, j;				//int (*ptr_arr)[rig][col]
	// int pt=0;
	// i=size-1;

// }

// void convolution2D_KB(int size, const float (*matrix)[size], float *kernel, float *out) {
	// int i, j;				//int (*ptr_arr)[rig][col]
	// int pt=0;
	
// }
// void convolution2D_KD(int size,const float (*matrix)[size], float *kernel, float *out) {
	// int i, j;				//int (*ptr_arr)[rig][col]
	// int pt=0;
	
// }
// void convolution2D_KF(int size,const float (*matrix)[size], float *kernel, float *out) {
	// int i, j;				//int (*ptr_arr)[rig][col]
	// int pt=0;
	
// }
// void convolution2D_KE(int size,const float (*matrix)[size], float *kernel, float *out) {
	// int i, j;				//int (*ptr_arr)[rig][col]
	// int pt=0;
	
// }

void convolution2D(int size,const float (*matrix)[size], float *kernel, float *out) {
	
	int i, j;				//int (*ptr_arr)[rig][col]
	int pt=0;
	//int k=k_esim; //questo serviva quando passavi la matrice tridimensionale e dovevi indicare con quale lavorare
	// 9 distinti kernel in sequenza ma out of order per scansionare la matrice
	
	///////////////////////////////////
	//alto sinistra A
	i=0;
	j=0;
	// static unsigned long int cont_mul;
	// static unsigned long int cont_index;
	// static unsigned long int cont_inc;

	pt=i*size+j;
		out[pt] +=	matrix[i][j]			* kernel[4] +
					matrix[i][j+1]		* kernel[5] +
					matrix[i+1][j] 	* kernel[7] +
					matrix[i+1][j+1] 	* kernel[8];
	// cont_mul+=4;
	// cont_index+=4;
	// cont_inc+=3;
	
	i=0;
	//scandisci tutta la prima riga tra i due vertici alti 	B
	for (j = 1; j < size-1; j++) {
		pt=i*size+j;
		out[pt] +=	matrix[i][j-1]		* kernel[3] +
					matrix[i][j]			* kernel[4] +
					matrix[i][j+1]		* kernel[5] +
					matrix[i+1][j-1] 	* kernel[6] +
					matrix[i+1][j] 	* kernel[7] +
					matrix[i+1][j+1] 	* kernel[8];
		// cont_mul+=6;
		// cont_index+=7;
		// cont_inc+=5;
	}
	
	//alto a destra	C
	i=0;
	j=(size-1);
	pt=i*size+j;
		out[pt] +=	matrix[i][j-1]		* kernel[3] +
					matrix[i][j]			* kernel[4] +
					matrix[i+1][j-1] 	* kernel[6] +
					matrix[i+1][j] 	* kernel[7];
	// cont_mul+=4;
	// cont_index+=4;
	// cont_inc+=3;
	
	//scandisci tutta la prima colonna D
	j=0;
	for(i = 1; i < size-1 ; i++){
		pt=i*size+j;
		out[pt] +=	matrix[i-1][j]	* kernel[1] +
					matrix[i-1][j+1]	* kernel[2] +
					matrix[i][j]			* kernel[4] +
					matrix[i][j+1]		* kernel[5] +
					matrix[i+1][j] 	* kernel[7] +
					matrix[i+1][j+1] 	* kernel[8];
		// cont_mul+=6;
		// cont_index+=7;
		// cont_inc+=5;
	}
	
	/////////////////////////
	// kernel E centrle
	
	for (i = 1; i < size-1; i++) {
		for (j = 1; j < size-1; j++) {	
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
		// cont_mul+=9;
		// cont_index+=12;
		// cont_inc+=8;
		}
	}	
	////////////////////
	//scandisci tutta l'ultima colonna	F
	j=(size-1);
	for(i = 1; i < size-1 ; i++){
		pt=i*size+j;
		out[pt] +=	matrix[i-1][j-1] 	* kernel[0] +
					matrix[i-1][j]	* kernel[1] +
					matrix[i][j-1]		* kernel[3] +
					matrix[i][j]			* kernel[4] +
					matrix[i+1][j-1] 	* kernel[6] +
					matrix[i+1][j] 	* kernel[7];
		// cont_mul+=6;
		// cont_index+=7;
		// cont_inc+=5;
		}
	
	/////////////////////
	//in basso a sinistra G
	j=0;
	i=size-1;
	pt=i*size+j;
		out[pt] +=	matrix[i-1][j]	* kernel[1] +
					matrix[i-1][j+1]	* kernel[2] +
					matrix[i][j]			* kernel[4] +
					matrix[i][j+1]		* kernel[5];
	// cont_mul+=4;
	// cont_index+=4;
	// cont_inc+=3;
	
	
	//scandisci tutta l'ultima riga tra i due vertici bassi	H
	for (j = 1; j < size-1; j++) {
		pt=i*size+j;
		out[pt] +=	matrix[i-1][j-1] 	* kernel[0] +
					matrix[i-1][j]	* kernel[1] +
					matrix[i-1][j+1]	* kernel[2] +
					matrix[i][j-1]		* kernel[3] +
					matrix[i][j]			* kernel[4] +
					matrix[i][j+1]		* kernel[5];
		// cont_mul+=6;
		// cont_index+=7;
		// cont_inc+=5;
	}
	
	
	//in basso a destra	I
	i=(size-1);
	j=size-1;
	pt=i*size+j;
		out[pt] +=	matrix[i-1][j-1] 	* kernel[0] +
					matrix[i-1][j]	* kernel[1] +
					matrix[i][j-1]		* kernel[3] +
					matrix[i][j]			* kernel[4];
	// cont_mul+=4;
	// cont_index+=4;
	// cont_inc+=3;
}
