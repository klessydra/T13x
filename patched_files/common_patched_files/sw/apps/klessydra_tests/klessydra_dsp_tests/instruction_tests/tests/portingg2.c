#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <stdint.h>

// #define MHARTID_IDCORE_MASK 15
// #define THREAD_POOL_SIZE 4
// #define spmaddrA 0x00200000  // Startung address of SPMA
// #define spmaddrB 0x00201000  // Startung address of SPMB
// #define spmaddrC 0x00202000  // Startung address of SPMC
// #define spmaddrD 0x00203000  // Startung address of SPMD
// #define spmaddrA 0x10000000  // Startung address of SPMA
// #define spmaddrB 0x10004000  // Startung address of SPMB
// #define spmaddrC 0x10008000  // Startung address of SPMC
// #define spmaddrD 0x1000C000  // Startung address of SPMD
#define N_SPM 4
#define SPM_MAX 64
#define NUMBER_OF_POINTS 12
#define DIMENSION 2
#define NUMBER_OF_CENTR 3
#define FRACTIONAL_PART 20
// #define ZERORISCY 1
#define KLESSYDRA 1



#ifdef KLESSYDRA
	#include "dsp_functions.h"
	#include "functions.h"
	#include "klessydra_defs.h"
#endif

#ifdef KLESSYDRA
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
#endif


int 			perf0 = 0;
int final_perf0 = 777;
int  *ptr_perf0 = &perf0;

//quando faccio con klessydra questo va tolto
// int MVSIZE;
// void CSR_MVSIZE(int rs1);
int kmeminit();
int memory_debug(int i);
int kmemfree();
// int kmemld(void* rd, void* rs1, int rs2);
// int kmemstr(void* rd, void* rs1, int rs2);
// int kaddv32(void* rd, void* rs1, void* rs2);
// int ksrav32(void* rd, void* rs1, void* rs2);
// int ksvmulsc32(void* rd, void* rs1, void* rs2);
// int kvcp(void* rd, void* rs1);
int* memory;
int bank[1000]={0};


//   /$$      /$$           /$$
//  | $$$    /$$$          |__/
//  | $$$$  /$$$$  /$$$$$$  /$$ /$$$$$$$
//  | $$ $$/$$ $$ |____  $$| $$| $$__  $$
//  | $$  $$$| $$  /$$$$$$$| $$| $$  \ $$
//  | $$\  $ | $$ /$$__  $$| $$| $$  | $$
//  | $$ \/  | $$|  $$$$$$$| $$| $$  | $$
//  |__/     |__/ \_______/|__/|__/  |__/
// float Data_fl[NUMBER_OF_POINTS][DIMENSION]={ 3,2, 4,4, 0,1, 3,0, 0,3, 3,1, 4,0, 1,3, 3,2, 1,3, 4,5, 4,1};
// float Centroids_fl[NUMBER_OF_CENTR][DIMENSION]={4,2,4,3,3,0};
float Tollerance_fl = 0.001000;
int azzero=0;


int main(){

	#ifdef KLESSYDRA
		spegni_threads();
	#endif
	memory=&bank[0];
	
	
	int n		=	NUMBER_OF_POINTS;
	int m		=	DIMENSION;
	int k	=	NUMBER_OF_CENTR;
	int t	=	0;


	int centroids		[NUMBER_OF_CENTR][DIMENSION]={{4194304,	2097152},{4194304,	3145728},{3145728,	0}};


	int data[NUMBER_OF_POINTS][DIMENSION]=
	{{100, 200} ,{300 , 400} , {0,1048576},{3145728,0},{0,3145728},{3145728,1048576},{4194304,0},{1048576,3145728},{3145728,2097152},{1048576,3145728},{4194304,5242880},{4194304,1048576}};
	
	t=(int)(Tollerance_fl*(1<<FRACTIONAL_PART));
	
	int limite=0;
	limite=sizeof(data);
	limite=limite>>2;

// PRINT THE ALLOCATED ARRAYS	
	for (int i=0; i< NUMBER_OF_POINTS; i++){
		for(int j=0; j< DIMENSION; j++){
			// *((int*)data+i)=(int)floor(*((float*)Data_fl+i)*(1<<FRACTIONAL_PART));
			printf("0x%08x\t",&data[i][j]);
			// printf("0x%08x\t",*(int*)&data[i][j]);
			printf("[%d]%d\n",1+i*DIMENSION+j,	data[i][j]);
		}
	}
	printf("-------------------\n");
	for (int i=0; i< NUMBER_OF_CENTR; i++){
		for(int j=0; j< DIMENSION; j++){
			// *((int*)data+i)=(int)floor(*((float*)Data_fl+i)*(1<<FRACTIONAL_PART));
			printf("0x%08x\t",&centroids[i][j]);
			// printf("0x%08x\t",*(int*)&centroids[i][j]);
			printf("[%d]%d\n",1+i*DIMENSION+j,	centroids[i][j]);
		}
	}
	
	
/*
	//Scrivo i valori puntuali di tutti i Centroidi in integer
	for (int i=0; i< (sizeof(Centroids_fl)/sizeof(int)); i++){
		*((int*)centroids+i)=(int)floor(*((float*)Centroids_fl+i)*pow(2,FRACTIONAL_PART));
		printf("%d\n",*((int*)centroids+i));
	}
	#ifdef KLESSYDRA
	CSR_MVSIZE(SPM_MAX*SPM_MAX*sizeof(int));
  kbcast32((void*)spmaddrA,(void*)azzero);
  kbcast32((void*)spmaddrB,(void*)azzero);
  kbcast32((void*)spmaddrC,(void*)azzero);
  kbcast32((void*)spmaddrD,(void*)azzero);
	#endif
	printf("---------------------------DBG-------------------------------\n");
	int inside;
	#ifdef ZERORISCY
		printf("USO ZERORISCY\n");
	#endif
	#ifdef KLESSSYDRA
		printf("USO KLESSSYDRA\n");
	#endif
	// --------------------------------------------------------------------------------------------------------------------------------------
	CSR_MVSIZE(sizeof(int));
	//parte di verifica che volendo può anche andare nel main()
	assert(data && k > 0 && k <= n && m > 0 && t >= 0); // for debugging
	int dim_spm = spmaddrB-spmaddrA; //dimension of a scratchpad memory in byte
	dim_spm = dim_spm >> 5; //dim_spm/32, dimension in number of int
	int dim_spm_tot = dim_spm*N_SPM;
	assert((7+k+(2*k*m)+n+(n*m))<=dim_spm_tot); //quello che vorrò usare entrerà nelle mie memorie scratchpad, altrimenti si ferma

	// --------------------------------------------------------------------------------------------------------------------------------------
	int p=kmeminit(); //inizializzo spm emulata
	if (p<0)
	{
		printf("No scratchpad memory available\n");
		return (NULL);
	}

	int distance = 0;
	int min_distance = 0x7FFFFFFF;
	int z = 0;
	int v = -k; //quotient (for divisions)
	int h = n;
	int	 i, j; // loop counters
	int old_error = 0x7FFFFFFF;
	int error			= 0x7FFFFFFF; // sum of squared euclidean distance

	//salvo variabili nel primo spazio d'indirizzamento delle spm
	// // // // //il primo argomento è a quale indirizzo della spm voglio salvare,
	// // // // //il secondo cosa voglio salvare e il terzo dimensione in byte del contenuto
	const int addr_h						=spmaddrA;
	const int addr_old_error		=spmaddrA+1*sizeof(int);
	const int addr_error				=spmaddrA+2*sizeof(int);
	const int addr_v						=spmaddrA+3*sizeof(int);
	const int addr_min_distance	=spmaddrA+4*sizeof(int);
	const int addr_distance			=spmaddrA+5*sizeof(int);
	const int addr_z						=spmaddrA+6*sizeof(int);

	kmemld((void*)addr_h, 						&h, sizeof(int));
	kmemld((void*)addr_old_error, 		&old_error, sizeof(int));
	kmemld((void*)addr_error, 				&error, sizeof(int));
	kmemld((void*)addr_v, 						&v, sizeof(int));
	kmemld((void*)addr_min_distance, 	&min_distance, sizeof(int));
	kmemld((void*)addr_distance,			&distance, sizeof(int));
	kmemld((void*)addr_z, 						&z, sizeof(int));
	// --------------------------------------------------------------------------------------------------------------------------------------

	printf("Sueprata Kmemld\n");
	int address = spmaddrA+7*sizeof(int);
	int labels[NUMBER_OF_POINTS]={0};
	for(int i=0; i < sizeof(labels)/sizeof(int);i++){
		*((int*)labels+i)=0;
	}
	int counts[NUMBER_OF_CENTR]={0};
	for(int i=0; i < sizeof(counts)/sizeof(int);i++){
		*((int*)counts+i)=0;
	}
	// int* labels = (int* ) calloc(n, sizeof(int));
	// int* counts = (int* ) calloc(k, sizeof(int)); // size of each cluster
	int c [NUMBER_OF_CENTR][DIMENSION]={0};
	for(int i=0; i < sizeof(c)/sizeof(int);i++){
		*((int*)c+i)=0;
	}
	int c1[NUMBER_OF_CENTR][DIMENSION]={0};
	for(int i=0; i < sizeof(c1)/sizeof(int);i++){
		*((int*)c1+i)=0;
	}
	// int** c 		= Centroids ? Centroids : (int** ) calloc(num_cent_K, sizeof(int* )); //calloc() è come la malloc ma inizializza i valori a 0
	// int** c1 		= (int** ) calloc	(num_cent_K, sizeof(int* )); // temp Centroids
	// --------------------------------------------------------------------------------------------------------------------------------------
	int monoindex_2=0;
	for (z=0; -v<=h; z++)	//z=Num_pts/num_cent_K
	{
		kaddv32((void*)addr_h, (void*)addr_h, (void*)addr_v);//h=h+v, ricorda che v lo ho iniziaizzato negativo;
		kmemstr((void*)addr_h, &h, sizeof(int));//aggiorno h per il confronto
		printf("Dentro primo loop %d\n",monoindex_2++);

	}

	// --------------------------------------------------------------------------------------------------------------------------------------
	// for (h = i = 0; i < num_cent_K; h += z, i++) {
	// 	c1[i] = (int* ) calloc(diM, sizeof(int));
	// 	if (!Centroids)
	// 	{
	// 		c[i] = (int* ) calloc(diM, sizeof(int));
	// 		// pick num_cent_K points as initial Centroids
	// 		for (j = diM; j-- > 0; c[i][j] = Data[h][j]);
	// 	}
	// }

	for (h = i = 0; i < k; h += z, i++) {
		// c1[i] = (int* ) calloc(diM, sizeof(int));
		// if (!Centroids)
		// {
			// c[i] = (int* ) calloc(diM, sizeof(int));
			// pick num_cent_K points as initial Centroids
			for (j = m; j > 0; j--)
			{
				c[i][j] = data[h][j];
				// printf("dentro\n");
			}
		// }
	}

	// --------------------------------------------------------------------------------------------------------------------------------------
	//salvataggio nelle spm dei centroidi
	int addr_c = address;
	monoindex_2=0;
	for (i = 0; i < k; i++)
	{
		kmemld((void*)address, c[i], m*sizeof(int));
		address=address+m*sizeof(int);
		printf("Dentro secondo loop %d\n",monoindex_2++);

	}

	// --------------------------------------------------------------------------------------------------------------------------------------
	//		kmemld((void*)address, c, diM*num_cent_K*sizeof(int));
	//		address=address+diM*num_cent_K*sizeof(int);
	//questa operazione non posso farla perché c non è un unico array di valori, bensì
	//è definito come array di array, salverebbe come valori gli indirizzi degli array

	int addr_c1 = address;

	monoindex_2=0;
	for (i = 0; i < k; i++)
	{
		kmemld((void*)address, c1[i], m*sizeof(int));
		address=address+m*sizeof(int);
		printf("Dentro terzo loop %d\n",monoindex_2++);

	}

	// --------------------------------------------------------------------------------------------------------------------------------------
	//salvataggio nelle spm dei counts
	int addr_counts = address;
	kmemld((void*)address, counts, k*sizeof(int));
	address=address+k*sizeof(int);

	// --------------------------------------------------------------------------------------------------------------------------------------
	//salvataggio nelle spm delle labels
	int addr_labels = address;
	kmemld((void*)address, labels, n*sizeof(int));
	address=address+n*sizeof(int);

	// --------------------------------------------------------------------------------------------------------------------------------------
	//salvataggio nelle spm dei dati
	int addr_data = address;
	monoindex_2=0;
	for (i = 0; i < n; i++)
	{
		kmemld((void*)address, data[i], m*sizeof(int));
		address=address+m*sizeof(int);
		printf("Dentro quarto loop %d\n",monoindex_2++);

	}
	kmemld((void*)address, data, m*n*sizeof(int));

	// --------------------------------------------------------------------------------------------------------------------------------------
	//for (i=0; i<7+num_cent_K+(2*num_cent_K*diM)+Num_pts+(Num_pts*diM);i++)
	//	memory_debug(i);

	int temp;//variabile di appoggio
	int address_1=address;
	int address_2=address;

	// main loop
	// --------------------------------------------------------------------------------------------------------------------------------------
	// --------------------------------------------------------------------------------------------------------------------------------------
	#ifdef ZERORISCY
		// ENABLE COUNTING -------------------------------------------------------------------------
		final_perf0=0;
		 __asm__("csrrw zero, 0x780, zero;"
				 "csrrw zero, 0x7A0, 0x00000001");
		//-----------------------------------------------------------------------------------------
	#endif
	#ifdef KLESSYDRA
		// ENABLE COUNTING -------------------------------------------------------------------------
		// final_perf0=0;
		 // __asm__("csrrw zero, 0x780, zero;"
				 // "csrrw zero, 0x7A0, 0x00000001");
				// // // // // // // // // CAMBIAAAAAAAAAAAAAAAAaaaaaaaaaaaaaaaaaaaaaaaaaa
		//-----------------------------------------------------------------------------------------
	#endif
	monoindex_2=0;
	while(1)
		{
			printf("Dentro il while %d\n",monoindex_2++);
			// save error from last step
			old_error = error;
			error = 0;
			kmemld((void*)addr_old_error, &old_error, sizeof(int));
			kmemld((void*)addr_error, &error, sizeof(int));

			// clear old counts and temp centroids
			for (i = 0; i < k; counts[i++] = 0)
			{
				for (j = 0; j < m; c1[i][j++] = 0);
			}

			address = addr_c1;
			for (i = 0; i < k; i++)
			{
				kmemld((void*)address, c1[i], m*sizeof(int));
				address=address+m*sizeof(int);
			}

			kmemld((void*)address, counts, k*sizeof(int));

			for (h = 0; h < n; h++)
			{
				// identify the closest cluster
				min_distance = 0x7FFFFFFF;
				kmemld((void*)addr_min_distance, &min_distance, sizeof(int));
				for (i = 0; i < k; i++)
				{
					distance = 0;
					kmemld((void*)addr_distance, &distance, sizeof(int));

					for(j=0; j<m; j++)
					{
						//z=(data[h][j] - c[i][j])>>FRACTIONAL_PART/2;
						//rendo c[i][j] negativo
						address=addr_c+((i*m)+j)*sizeof(int);
						kmemstr((void*)address, &v, sizeof(int));//v=c[i][j]
						v=-v;
						kmemld((void*)addr_v, &v, sizeof(int)); //v=-v

						address=addr_data+((h*m)+j)*sizeof(int);
						kaddv32((void*)addr_z, (void*)address, (void*)addr_v);//z=data[h][j]+v

						v=FRACTIONAL_PART/2;
						kmemld((void*)addr_v, &v, sizeof(int)); //v=FRACTIONAL_PART/2

						ksrav32((void*)addr_z, (void*)addr_z, (void*)addr_v);//z=z>>v

						//distance += z*z;
						ksvmulsc32((void*)addr_v, (void*)addr_z, (void*)addr_z); //v=z*z
						kaddv32((void*)addr_distance, (void*)addr_distance, (void*)addr_v); //distance=distance+v
					}

					kmemstr((void*)addr_distance, &distance, sizeof(int));
					kmemstr((void*)addr_min_distance, &min_distance, sizeof(int));

					if (distance < min_distance)
					{
						// labels[h] = i;
						// min_distance = distance;
						labels[h] = i;
						address=addr_labels+h*sizeof(int);
						kmemld((void*)address, &i, sizeof(int));

						min_distance = distance;
						kmemld((void*)addr_min_distance, &min_distance, sizeof(int));
					}
				}

				// update size and temp centroid of the destination cluster
				//for (j = m; j-- > 0; c1[labels[h]][j] += data[h][j]);

				// for (j = 0; j <m ; j++)
				// {
					// address=addr_labels+h*sizeof(int);
					// kmemstr((void*)address, &temp, sizeof(int));//temp=labels[h]

					// address_1=addr_c1+(temp*m+j)*sizeof(int);
					// address_2=addr_data+(h*m+j)*sizeof(int);
					// kaddv32((void*)address_1, (void*)address_2, (void*)address_1);//c1[labels[h]][j] += data[h][j]
				// }

				address=addr_labels+h*sizeof(int);
				kmemstr((void*)address, &temp, sizeof(int));//temp=labels[h]

				address_1=addr_c1+(temp*m)*sizeof(int);
				address_2=addr_data+(h*m)*sizeof(int);
				CSR_MVSIZE(m*sizeof(int));
				kaddv32((void*)address_1, (void*)address_2, (void*)address_1);
				CSR_MVSIZE(sizeof(int));

				//counts[labels[h]]++;
				v=1;
				kmemld((void*)addr_v, &v, sizeof(int));//v=1
				address=addr_counts+temp*sizeof(int);
				kaddv32((void*)address, (void*)address, (void*)addr_v);//counts[labels[h]]=counts[labels[h]]+v

				// update standard error
				kaddv32((void*)addr_error,(void*)addr_error, (void*)addr_min_distance);//error += min_distance;
			}

			for (i = 0; i < k; i++)// update all centroids
			{
				for (j = 0; j < m; j++)
				{
					//for (h=c1[i][j],v=counts[i],z=0; v<=h; z++)
					//	h=h-v;
					address=addr_c1+(i*m+j)*sizeof(int);
					kvcp((void*)addr_h, (void*)address); //h=c1[i][j]
					address=addr_counts+i*sizeof(int);
					kmemstr((void*)address, &v, sizeof(int));
					v=-v;
					kmemld((void*)addr_v, &v, sizeof(int)); //v=-counts[i]
					kmemstr((void*)addr_h, &h, sizeof(int));
					for (z=0; -v<=h; z++)
					{
						kaddv32((void*)addr_h, (void*)addr_h, (void*)addr_v);//h=h+(-v);
						kmemstr((void*)addr_h, &h, sizeof(int));//aggiorno h per il confronto
					}
					address=addr_counts+i*sizeof(int);
					kmemstr((void*)address, &counts[i], sizeof(int));
					address=addr_c1+(i*m+j)*sizeof(int);
					kmemstr((void*)address, &c1[i][j], sizeof(int));
					c[i][j] = counts[i] ? z : c1[i][j];
					address=addr_c+(i*m+j)*sizeof(int);
					kmemld((void*)address, &c[i][j], sizeof(int));
				}
			}

			//z=error-old_error;
			kmemstr((void*)addr_old_error, &v, sizeof(int)); //v=old_error
			v=-v;
			kmemld((void*)addr_v, &v, sizeof(int)); //v=-old_error
			kaddv32((void*)addr_z, (void*)addr_error, (void*)addr_v); //z=error+v
			kmemstr((void*)addr_z, &z, sizeof(int)); //z=z

			if (z<0)
			{
				z=-z;
				kmemld((void*)addr_z, &z, sizeof(int));//z=temp;
			}
			kmemstr((void*)addr_error, &error, sizeof(int));//salvo error (alla prossima iterazione salvo old_error=error)

			if (z<t)
				break;
	}
	#ifdef ZERORISCY
		// DISABLE COUNTING AND SAVE MCYCLE -------------------------------------------------------
	 	__asm__("csrrw zero, 0x7A0, 0x00000000;"
	 		"csrrw %[perf0], 0x780, zero;"
	 		"sw %[perf0], 0(%[ptr_perf0]);"
	 		:
			// // // // // // // // // CAMBIAAAAAAAAAAAAAAAAaaaaaaaaaaaaaaaaaaaaaaaaaa
	 		:[perf0] "r" (perf0), [ptr_perf0] "r" (ptr_perf0)
	 		);
	  final_perf0=*(ptr_perf0);
	  printf("Cycles of while in Klessydra is Speed is:\n\t%d Cycles\n", final_perf0);
	  // //------------------------------------------------------------------------------------------
	#endif
	// housekeeping
	// for (i = 0; i < num_cent_K; i++) {
	// 		if (!Centroids) {
	// 				free(c[i]);
	// 		}
	// 		free(c1[i]);
	// }
	//
	// if (!Centroids) {
	// 		free(c);
	// }
	// free(c1);
	//
	// free(counts);

	kmemfree(); //libero spm emulata
	int monoindex=0;
	printf("\nData Set:--------\n");
	for (int i=0; i< (sizeof(Data_fl)/sizeof(int)); i=i+2){
		printf("[%d]\t%d\t",monoindex++,*((int*)data+i));
		printf("%d\n",*((int*)data+i+1));
	}
	printf("\nCentroids:--------\n");
	monoindex=0;
	//Scrivo i valori puntuali di tutti i Centroidi in integer
	for (int i=0; i< (sizeof(Centroids_fl)/sizeof(int)); i=i+2){
		printf("[%d]\t%d\t",monoindex++,*((int*)centroids+i));
		printf("%d\n",*((int*)centroids+i+1));
	}
	printf("\nLabels:--------\n");
	for(int i=0; i < sizeof(labels)/sizeof(int);i++){
		printf("[%d]\t%d\n",i,*((int*)labels+i));
	}
*/
	return 0;
}




// **********************************************************************************************
// **********************************************************************************************
// **********************************************************************************************
// **********************************************************************************************
// **********************************************************************************************
// **********************************************************************************************
// **********************************************************************************************


// void CSR_MVSIZE(int rs1)  // Takes on argument as the number of bytes in the vectors, and sets the MVSIZE CSR register to that size
// {
	// MVSIZE = rs1;
// }

#ifdef ZERORISCY
int kmeminit()
{
	// memory=(int* )calloc(512,sizeof(int));
	// if (memory==NULL)
	// 	return(-1);
	// else
		return (0);
}

int memory_debug(int i)
{
	printf("memory[%d]=%d\n",i,memory[i]);
	return (0);
}

int kmemfree()
{
	// free(memory);
	return (0);
}

int kmemld(void* rd, void* rs1, int rs2)  // reads the vector indexed in rs1, of size rs2 (in Bytes), and stores it in the scratchpad memory index in rd
{
	int* int_rd=(int*)rd;
	int addr_rd=((int)int_rd-spmaddrA)/sizeof(int);
	memcpy(&memory[addr_rd], rs1, rs2);
	return (0);
}

int kmemstr(void* rd, void* rs1, int rs2) // reads the vector in the scratchpad memory index of rd, of size rs2 (in Bytes), and stores it in the main memory referred in rs1
{
	int* int_rd=(int*)rd;
	int addr_rd=((int)int_rd-spmaddrA)/sizeof(int);
	memcpy(rs1, &memory[addr_rd], rs2);
	return (0);
}

int kaddv32(void* rd, void* rs1, void* rs2)  // Performs 32-bit vector addition of the spm indexes referred in rs1 and rs2, and stores the result in spm referred in rd
{
	int* int_rs2=(int*)rs2;
	int addr_rs2=((int)int_rs2-spmaddrA)/sizeof(int);
	int* int_rs1=(int*)rs1;
	int addr_rs1=((int)int_rs1-spmaddrA)/sizeof(int);
	int* int_rd=(int*)rd;
	int addr_rd=((int)int_rd-spmaddrA)/sizeof(int);

	for (int i=0; i<MVSIZE/sizeof(int); i++)
		memory[addr_rd+i] = memory[addr_rs1+i] + memory[addr_rs2+i];

	return(0);
}

int ksrav32(void* rd, void* rs1, void* rs2) // Performs 32-bit right arithmetic shift of the spm indexes referred in rs1 by the shift amount in rs2, and stores the result in spm referred in rd
{
	int* int_rs2=(int*)rs2;
	int addr_rs2=((int)int_rs2-spmaddrA)/sizeof(int);
	int* int_rs1=(int*)rs1;
	int addr_rs1=((int)int_rs1-spmaddrA)/sizeof(int);
	int* int_rd=(int*)rd;
	int addr_rd=((int)int_rd-spmaddrA)/sizeof(int);

	for (int i=0; i<MVSIZE/sizeof(int); i++)
		memory[addr_rd+i] = (memory[addr_rs1+i])>>(memory[addr_rs2]);

	return(0);
}

int ksvmulsc32(void* rd, void* rs1, void* rs2) // Performs 32-bit scalar vector multiplication of the spm indexes referred in rs1 by the scalar in rs2, and stores the result in spm referred in rd
{
	int* int_rs2=(int*)rs2;
	int addr_rs2=((int)int_rs2-spmaddrA)/sizeof(int);
	int* int_rs1=(int*)rs1;
	int addr_rs1=((int)int_rs1-spmaddrA)/sizeof(int);
	int* int_rd=(int*)rd;
	int addr_rd=((int)int_rd-spmaddrA)/sizeof(int);
	for (int i=0; i<MVSIZE/sizeof(int); i++)
		memory[addr_rd+i] = memory[addr_rs1+i] * memory[addr_rs2+i];

	return(0);
}
#endif

int kvcp(void* rd, void* rs1)  // Copies the vector specified in the index in rs1 into the destination index in rd
{
	int* int_rs1=(int*)rs1;
	int addr_rs1=((int)int_rs1-spmaddrA)/sizeof(int);
	int* int_rd=(int*)rd;
	int addr_rd=((int)int_rd-spmaddrA)/sizeof(int);

	memcpy(&memory[addr_rd], &memory[addr_rs1], sizeof(int));

	return(0);
}
