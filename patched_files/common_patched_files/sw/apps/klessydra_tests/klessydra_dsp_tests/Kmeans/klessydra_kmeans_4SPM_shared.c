#include<stdlib.h> 
#include<assert.h> 
#include<float.h>  
#include<math.h>
#include<stdio.h>
#include<limits.h>

//Klessydra lib
#include"dsp_functions.h"
#include"functions.h"
#include"klessydra_defs.h"
#include"dataset.h"

#define SPM_MAX 64
#define SIZE_OF_INT 4
#define FRACTIONAL_PART 18
#define SHIFT 9

int 	performance=0;
int 	perf[3]= {0,0,0};
int* 	ptr_perf[3];
int perf_results[3][4]={0};

void start_count(){
	performance=0;
	int cnt_en=0;
  __asm__(	
						// resetto registri
						"csrrw zero, 0xB00, 	zero;"
						"csrrw zero, 0xB02, 	zero;"
						"csrrw zero, 0xB06, 	zero;"
						"csrrw zero, 0xB07, 	zero;"
						//abilito tutto
						// "li %[cnt_en], 0x00000FF3;"
						"li %[cnt_en], 0x00000063;"
						"csrrw zero, 0x7A0, %[cnt_en];"
						:
						:[cnt_en] "r" (cnt_en)	);
}
int finish_count(){

	__asm__("csrrw zero, 0x7A0, 0x00000000");
	
	int i = Klessydra_get_coreID();

	__asm__("csrrw %[perf], 0xB00, zero;"
      "sw %[perf], 0(%[ptr_perf]);"
      :
      :[perf] "r" (perf[i]), 	[ptr_perf] "r" (ptr_perf[i])
      );
	perf_results[i][0]=perf[i];//CICLI
	__asm__("csrrw %[perf], 0xB02, zero;"
		"sw %[perf], 0(%[ptr_perf]);"
		:
		:[perf] "r" (perf[i]), 	[ptr_perf] "r" (ptr_perf[i])
		);
	perf_results[i][1]=perf[i];//ISTRUZIONI

	__asm__("csrrw %[perf], 0xB06, zero;"
		"sw %[perf], 0(%[ptr_perf]);"
		:
		:[perf] "r" (perf[i]), 	[ptr_perf] "r" (ptr_perf[i])
		);
	perf_results[i][2]=perf[i];//Load
	
	__asm__("csrrw %[perf], 0xB07, zero;"
		"sw %[perf], 0(%[ptr_perf]);"
		:
		:[perf] "r" (perf[i]), 	[ptr_perf] "r" (ptr_perf[i])
		);
	perf_results[i][3]=perf[i];//Store
			
	return perf_results;
}



int zero=0;

int main(){
	int data[NUM_OF_POINTS][DIMENSIONS];
	int centroids[NUM_OF_CENT][DIMENSIONS];
	int n = NUM_OF_POINTS;
	int m = DIMENSIONS;
	int k = NUM_OF_CENT;
	int t ;
	int z;
	int uno = 1;
	int shft = SHIFT;
	int labels[NUM_OF_POINTS];
	int counts[NUM_OF_CENT];
	int counts_inv[NUM_OF_CENT];
	float counts_inv_f[NUM_OF_CENT];
	int c_temp[NUM_OF_CENT][DIMENSIONS];
	int c[NUM_OF_CENT][DIMENSIONS];
	int temp_dist[DIMENSIONS];
	int max_int = 2147483647;
	int min_distance = 2147483647;
	int error = 2147483647;
	int old_error = 2147483647;
	int distance = 0;
	int offset[3]={0,0,0};
	int ones[m];
	int n_cycle=(NUM_OF_POINTS*DIMENSIONS)/(SPM_MAX*SPM_MAX/3);
	int i,j,h,p;
	int scl=SPM_MAX*SPM_MAX/(3*DIMENSIONS);
	z= n/k;
	t= (int)round(Tolerance*pow(2,FRACTIONAL_PART));
   	if((n*m)-(n_cycle*(SPM_MAX*SPM_MAX/3))>0){
		n_cycle++;
	}

	for(i=0;i<m;i++){
		temp_dist[i]=0;
	}
	//Write Data in data
	for(i=0;i<n;i++){
		for(j=0;j<m;j++){
			data[i][j]=(int)round(Data[i][j]*pow(2,FRACTIONAL_PART));
		}
	}
	//Initialize variables
	for(i=0;i<m;i++){
		ones[i]=1;
	}
	for(i=0;i<n;i++){
		labels[i]=0;
	}
	for(i=0;i<k;i++){
		counts[i]=0;
		counts_inv[i]=0;
	}
	for(i=0;i<k;i++){
		for(j=0;j<m;j++){
			c_temp[i][j]=0;
		}
	}
	//Initialize random centroids
	for (h=i=0; i<k; h+=z, i++) {
		for (j=m-1; j>-1;j--){
			c[i][j] = -data[h][j];
		}
	}

	__asm__("csrw 0x300, 0x8;" );//Enable interrupts for all threads
	__asm__("csrrw zero, mcycle, zero");
	CSR_MVSIZE(SPM_MAX*SPM_MAX*SIZE_OF_INT);
	if(Klessydra_get_coreID()==0){
		kbcast((void *)spmaddrA, (void *)zero);
		kbcast((void *)spmaddrD, (void *)zero);
	}
	else if(Klessydra_get_coreID()==1){
		kbcast((void *)spmaddrB, (void *)zero);
	}
	else if(Klessydra_get_coreID()==2){
		kbcast((void *)spmaddrC, (void *)zero);
	}
	sync_barrier_reset();		
	sync_barrier_thread_registration();
	if(Klessydra_get_coreID()==0){
		kmemld((void *)((int *)spmaddrB), &c[0][0],  SIZE_OF_INT*(k*m));
		kmemld((void *)((int *)spmaddrC),  &c_temp[0][0],  SIZE_OF_INT*(k*m));  
		kmemld((void *)((int *)spmaddrC+(k*m)),  &distance, SIZE_OF_INT);
		kmemld((void *)((int *)spmaddrC+((k*m)+2)),  &temp_dist[0], SIZE_OF_INT*m);
		kmemld((void *)((int *)spmaddrC+(((k*m)+2+m)+1)+((k*m)+2)+1+m+((k*m)+2)+m),  &ones, SIZE_OF_INT*m);
		kmemld((void *)((int *)spmaddrD),  &c_temp[0][0],  SIZE_OF_INT*(k*m));
		kmemld((void *)((int *)spmaddrD+(k*m)),  &distance, SIZE_OF_INT);
		kmemld((void *)((int *)spmaddrD+((k*m)+2)),  &temp_dist[0], SIZE_OF_INT*m);
		start_count();
		do{
			old_error=error;
			error=0;    
			CSR_MVSIZE(SIZE_OF_INT*(k*m));
			kbcast((void *)((int *)spmaddrD),  (void*)zero);//c_temp[i][j]=0;
			for(i=0;i<k;i++){
			counts[i]=0;
			}
			for(int p=0;p<n_cycle;p++){
				if((n*m)-((scl*m)*(n_cycle-1))>(SPM_MAX*SPM_MAX/3)){
					n_cycle++;
				}
				if(p<(n_cycle-1)){

					kmemld((void *)((int *)spmaddrA), &data[scl*p][0],  SIZE_OF_INT*(scl*m));
					for(h=0;h<scl;h++){
						min_distance=max_int;
						for(i=0;i<k;i++){
							CSR_MVSIZE(SIZE_OF_INT);
							offset[0]=(k*m);
							kbcast((void *)((int *)spmaddrC+offset[0]),  (void *)zero);//distance=0;
							kbcast((void *)((int *)spmaddrD+offset[0]),  (void *)zero);//distance=0;
							CSR_MVSIZE(SIZE_OF_INT*m);
							//distance += pow(data[h][j] - c[i][j], 2)
							offset[0]=(k*m)+2;
							offset[1]=h*m;
							offset[2]=i*m;
							kaddv((void *)((int *)spmaddrC+offset[0]),  (void *)((int *)spmaddrA+offset[1]),  (void *)((int *)spmaddrB+offset[2]));//data[h][j]-C[i][j]
							ksrav((void *)((int *)spmaddrC+offset[0]),  (void *)((int *)spmaddrC+offset[0]),  shft);//(data[h][j]-C[i][j])>>shift
							kvcp((void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrC+offset[0]));
							kvmul((void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrC+offset[0]));//pow(data[h][j]-C[i][j],2)
				
							offset[0]=k*m;
							offset[1]=(((k*m)+2+m)+1)+((k*m)+2)+1+m+((k*m)+2)+m;
							offset[2]=(k*m)+2;
							kdotp((void *)((int *)spmaddrC+offset[0]),   (void *)((int *)spmaddrD+offset[2]),  (void *)((int *)spmaddrC+offset[1]));
				
							offset[1]=k*m;
							kmemstr((void*) &distance,  (void *)((int *)spmaddrC+offset[1]),  SIZE_OF_INT);//distance
							if (distance < min_distance){
								labels[h] = i;
								min_distance = distance;
							}
						}
						//Sum all data in a cluster and put it in c_temp[i][j]
						offset[0]=(labels[h]*m);
						offset[2]=(h*m);
						kaddv((void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrA+offset[2]));//c1[labels[h]][j] += data[h][j]

						//update counts[i]
						counts[labels[h]]++;
						
						// update standard error 
						
						error=error+min_distance;
					}
				}
				else{
					kmemld((void *)((int *)spmaddrA), &data[scl*p][0],  SIZE_OF_INT*((n-scl*(n_cycle-1))*m));
					for(h=0;h<(n-scl*(n_cycle-1));h++){
						min_distance=max_int;
						for(i=0;i<k;i++){
							CSR_MVSIZE(SIZE_OF_INT);
							offset[0]=(k*m);
							kbcast((void *)((int *)spmaddrC+offset[0]),  (void *)zero);//distance=0;
							kbcast((void *)((int *)spmaddrD+offset[0]),  (void *)zero);//distance=0;
							CSR_MVSIZE(SIZE_OF_INT*m);
							//distance += pow(data[h][j] - c[i][j], 2)
							offset[0]=(k*m)+2;
							offset[1]=h*m;
							offset[2]=i*m;
							kaddv((void *)((int *)spmaddrC+offset[0]),  (void *)((int *)spmaddrA+offset[1]),  (void *)((int *)spmaddrB+offset[2]));//data[h][j]-C[i][j]
							ksrav((void *)((int *)spmaddrC+offset[0]),  (void *)((int *)spmaddrC+offset[0]),  shft);//(data[h][j]-C[i][j])>>shift
							kvcp((void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrC+offset[0]));
							kvmul((void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrC+offset[0]));//pow(data[h][j]-C[i][j],2)
				
							offset[0]=k*m;
							offset[1]=(((k*m)+2+m)+1)+((k*m)+2)+1+m+((k*m)+2)+m;
							offset[2]=(k*m)+2;
							kdotp((void *)((int *)spmaddrC+offset[0]),   (void *)((int *)spmaddrD+offset[2]),  (void *)((int *)spmaddrC+offset[1]));
				
							offset[1]=k*m;
							kmemstr((void*) &distance,  (void *)((int *)spmaddrC+offset[1]),  SIZE_OF_INT);//distance
							if (distance < min_distance){
								labels[h] = i;
								min_distance = distance;
							}
						}
						//Sum all data in a cluster and put it in c_temp[i][j]
						offset[0]=(labels[h]*m);
						offset[2]=(h*m);
						kaddv((void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrA+offset[2]));//c1[labels[h]][j] += data[h][j]
						//update counts[i]
						counts[labels[h]]++;
						// update standard error 
						error=error+min_distance;
					}
				}
			}
			//update centroids
			CSR_MVSIZE(SIZE_OF_INT*m*k);
			ksrav((void *)((int *)spmaddrC),  (void *)((int *)spmaddrD),  shft);//c1[i][j]>>shift;
			CSR_MVSIZE(SIZE_OF_INT*m);
			for (i = 0; i < k; i++) {
				counts_inv_f[i]=1/(float)counts[i];
				counts_inv[i]=-(int)round((int)round(counts_inv_f[i]*pow(2,FRACTIONAL_PART))>>shft);
				offset[0]=i*m;
				if(counts[i]==0){
					printf("\n\nDENTRO\n\n");
					kvcp((void *)((int *)spmaddrB+offset[0]),  (void *)((int *)spmaddrD+offset[0]));//c[i][j]=c1[i][j]
				}
				else{
					ksvmulrf((void *)((int *)spmaddrB+offset[0]),  (void *)((int *)spmaddrC+offset[0]),  counts_inv[i]);//c[i][j] = c1[i][j] / counts[i]
				}
			}
			//error check
		}
		while (fabs(error - old_error) > t);
		//download centroids form spm	
		kmemstr(&c[0][0],  (void *)((int *)spmaddrB),  SIZE_OF_INT*(k*m));
		finish_count();	
	}
	if(Klessydra_get_coreID()==1){
		kmemld((void *)((int *)spmaddrB+(k*m)), &c[0][0],  SIZE_OF_INT*(k*m));
		kmemld((void *)((int *)spmaddrC+(((k*m)+2+m)+1)),  &c_temp[0][0],  SIZE_OF_INT*(k*m));  
		kmemld((void *)((int *)spmaddrC+(((k*m)+2+m)+1)+(k*m)),  &distance, SIZE_OF_INT);
		kmemld((void *)((int *)spmaddrC+(((k*m)+2+m)+1)+((k*m)+2)),  &temp_dist[0], SIZE_OF_INT*m);
		kmemld((void *)((int *)spmaddrD+(((k*m)+2+m)+1)),  &c_temp[0][0],  SIZE_OF_INT*(k*m));  
		kmemld((void *)((int *)spmaddrD+(((k*m)+2+m)+1)+(k*m)),  &distance, SIZE_OF_INT);
		kmemld((void *)((int *)spmaddrD+(((k*m)+2+m)+1)+((k*m)+2)),  &temp_dist[0], SIZE_OF_INT*m);
		start_count();
		do{
			old_error=error;
			error=0;    
			CSR_MVSIZE(SIZE_OF_INT*(k*m));
			offset[0]=(((k*m)+2+m)+1);
			kbcast((void *)((int *)spmaddrD+offset[0]),  (void*)zero);//c_temp[i][j]=0;
			for(i=0;i<k;i++){
			counts[i]=0;
			}
			for(int p=0;p<n_cycle;p++){
				if((n*m)-((scl*m)*(n_cycle-1))>(SPM_MAX*SPM_MAX/3)){
					n_cycle++;
				}
				if(p<(n_cycle-1)){
					kmemld((void *)((int *)spmaddrA+scl*m), &data[scl*p][0],  SIZE_OF_INT*(scl*m));//??
					for(h=0;h<scl;h++){
						min_distance=max_int;
						for(i=0;i<k;i++){
							CSR_MVSIZE(SIZE_OF_INT);
							offset[0]=(((k*m)+2+m)+1)+(k*m);
							kbcast((void *)((int *)spmaddrC+offset[0]),  (void *)zero);//distance=0;
							kbcast((void *)((int *)spmaddrD+offset[0]),  (void *)zero);//distance=0;
							CSR_MVSIZE(SIZE_OF_INT*m);
							//distance += pow(data[h][j] - c[i][j], 2)
							offset[0]=(((k*m)+2+m)+1)+((k*m)+2);
							offset[1]=scl*m+h*m;
							offset[2]=(k*m)+i*m;
							kaddv((void *)((int *)spmaddrC+offset[0]),  (void *)((int *)spmaddrA+offset[1]),  (void *)((int *)spmaddrB+offset[2]));//data[h][j]-C[i][j]
							ksrav((void *)((int *)spmaddrC+offset[0]),  (void *)((int *)spmaddrC+offset[0]),  shft);//(data[h][j]-C[i][j])>>shift
							kvcp((void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrC+offset[0]));
							kvmul((void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrC+offset[0]));//pow(data[h][j]-C[i][j],2)

							offset[0]=(((k*m)+2+m)+1)+(k*m);
							offset[2]=(((k*m)+2+m)+1)+((k*m)+2);
							offset[1]=(((k*m)+2+m)+1)+((k*m)+2)+1+m+((k*m)+2)+m;
							kdotp((void *)((int *)spmaddrC+offset[0]),  (void *)((int *)spmaddrC+offset[1]),  (void *)((int *)spmaddrD+offset[2]));//distance+=pow(data[h][j]-C[i][j],2)
							
							offset[1]=(((k*m)+2+m)+1)+(k*m);
							kmemstr((void*) &distance,  (void *)((int *)spmaddrC+offset[1]),  SIZE_OF_INT);//distance
							if (distance < min_distance){
								labels[h] = i;
								min_distance = distance;
							}
						}
						//Sum all data in a cluster and put it in c_temp[i][j]
						offset[0]=(((k*m)+2+m)+1)+(labels[h]*m);
						offset[2]=scl*m+(h*m);
						kaddv((void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrA+offset[2]));//c1[labels[h]][j] += data[h][j]
						//update counts[i]
						counts[labels[h]]++;				
						// update standard error 
						error=error+min_distance;
					}
				}
				else{
					kmemld((void *)((int *)spmaddrA+scl*m), &data[scl*p][0],  SIZE_OF_INT*((n-scl*(n_cycle-1))*m));
					for(h=0;h<(n-scl*(n_cycle-1));h++){
						min_distance=max_int;
						for(i=0;i<k;i++){
							CSR_MVSIZE(SIZE_OF_INT);
							offset[0]=(((k*m)+2+m)+1)+(k*m);
							kbcast((void *)((int *)spmaddrC+offset[0]),  (void *)zero);//distance=0;
							kbcast((void *)((int *)spmaddrD+offset[0]),  (void *)zero);//distance=0;
							CSR_MVSIZE(SIZE_OF_INT*m);
							//distance += pow(data[h][j] - c[i][j], 2)
							offset[0]=(((k*m)+2+m)+1)+((k*m)+2);
							offset[1]=scl*m+h*m;
							offset[2]=(k*m)+i*m;
							kaddv((void *)((int *)spmaddrC+offset[0]),  (void *)((int *)spmaddrA+offset[1]),  (void *)((int *)spmaddrB+offset[2]));//data[h][j]-C[i][j]
							ksrav((void *)((int *)spmaddrC+offset[0]),  (void *)((int *)spmaddrC+offset[0]),  shft);//(data[h][j]-C[i][j])>>shift
							kvcp((void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrC+offset[0]));
							kvmul((void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrC+offset[0]));//pow(data[h][j]-C[i][j],2)

							offset[0]=(((k*m)+2+m)+1)+(k*m);
							offset[2]=(((k*m)+2+m)+1)+((k*m)+2);
							offset[1]=(((k*m)+2+m)+1)+((k*m)+2)+1+m+((k*m)+2)+m;
							kdotp((void *)((int *)spmaddrC+offset[0]),  (void *)((int *)spmaddrC+offset[1]),  (void *)((int *)spmaddrD+offset[2]));//distance+=pow(data[h][j]-C[i][j],2)
							
							offset[1]=(((k*m)+2+m)+1)+(k*m);
							kmemstr((void*) &distance,  (void *)((int *)spmaddrC+offset[1]),  SIZE_OF_INT);//distance
							if (distance < min_distance){
								labels[h] = i;
								min_distance = distance;
							}
						}
						//Sum all data in a cluster and put it in c_temp[i][j]
						offset[0]=(((k*m)+2+m)+1)+(labels[h]*m);
						offset[2]=scl*m+(h*m);
						kaddv((void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrA+offset[2]));//c1[labels[h]][j] += data[h][j]
						//update counts[i]
						counts[labels[h]]++;		
						// update standard error 
						error=error+min_distance;
					}
				}
			}
			//update centroids
			CSR_MVSIZE(SIZE_OF_INT*m*k);
			offset[0]=(((k*m)+2+m)+1);
			ksrav((void *)((int *)spmaddrC+offset[0]),  (void *)((int *)spmaddrD+offset[0]),  shft);//c1[i][j]>>shift;
			CSR_MVSIZE(SIZE_OF_INT*m);
			for (i = 0; i < k; i++) {
				counts_inv_f[i]=1/(float)counts[i];
				counts_inv[i]=-(int)round((int)round(counts_inv_f[i]*pow(2,FRACTIONAL_PART))>>shft);
				if(counts[i]==0){
					offset[0]=(k*m)+i*m;
					offset[1]=(((k*m)+2+m)+1)+i*m;
					kvcp((void *)((int *)spmaddrB+offset[0]),  (void *)((int *)spmaddrD+offset[0]));//c[i][j]=c1[i][j]
				}
				else{
					offset[0]=(k*m)+i*m;
					offset[1]=(((k*m)+2+m)+1)+i*m;
					ksvmulrf((void *)((int *)spmaddrB+offset[0]),  (void *)((int *)spmaddrC+offset[1]),  counts_inv[i]);//c[i][j] = c1[i][j] / counts[i]
				}

			}
			//error check
		}
		while (fabs(error - old_error) > t);
		//download centroids form spm
		kmemstr(&c[0][0],  (void *)((int *)spmaddrB+(k*m)),  SIZE_OF_INT*(k*m));	
		finish_count();
	}
	if(Klessydra_get_coreID()==2){
		kmemld((void *)((int *)spmaddrB+(k*m)+(k*m)), &c[0][0],  SIZE_OF_INT*(k*m));
		kmemld((void *)((int *)spmaddrC+(((k*m)+2+m)+1)+((k*m)+2)+1+m),  &c_temp[0][0],  SIZE_OF_INT*(k*m));  
		kmemld((void *)((int *)spmaddrC+(((k*m)+2+m)+1)+((k*m)+2)+1+m+(k*m)),  &distance, SIZE_OF_INT);
		kmemld((void *)((int *)spmaddrC+(((k*m)+2+m)+1)+((k*m)+2)+1+m+((k*m)+2)),  &temp_dist[0], SIZE_OF_INT*m);
		kmemld((void *)((int *)spmaddrD+(((k*m)+2+m)+1)+((k*m)+2)+1+m),  &c_temp[0][0],  SIZE_OF_INT*(k*m));  
		kmemld((void *)((int *)spmaddrD+(((k*m)+2+m)+1)+((k*m)+2)+1+m+(k*m)),  &distance, SIZE_OF_INT);
		kmemld((void *)((int *)spmaddrD+(((k*m)+2+m)+1)+((k*m)+2)+1+m+((k*m)+2)),  &temp_dist[0], SIZE_OF_INT*m);
		start_count();
		do{
			old_error=error;
			error=0;    
			CSR_MVSIZE(SIZE_OF_INT*(k*m));
			offset[0]=(((k*m)+2+m)+1)+((k*m)+2)+1+m;
			kbcast((void *)((int *)spmaddrD+offset[0]),  (void*)zero);//c_temp[i][j]=0;
			for(i=0;i<k;i++){
			counts[i]=0;
			}
			for(int p=0;p<n_cycle;p++){
				if((n*m)-((scl*m)*(n_cycle-1))>(SPM_MAX*SPM_MAX/3)){
					n_cycle++;
				}
				if(p<(n_cycle-1)){
					kmemld((void *)((int *)spmaddrA+scl*m+scl*m), &data[scl*p][0],  SIZE_OF_INT*(scl*m));
					for(h=0;h<scl;h++){
						min_distance=max_int;
						for(i=0;i<k;i++){
							CSR_MVSIZE(SIZE_OF_INT);
							offset[0]=(((k*m)+2+m)+1)+((k*m)+2)+1+m+(k*m);
							kbcast((void *)((int *)spmaddrC+offset[0]),  (void *)zero);//distance=0;
							kbcast((void *)((int *)spmaddrD+offset[0]),  (void *)zero);//distance=0;
							CSR_MVSIZE(SIZE_OF_INT*m);
							//distance += pow(data[h][j] - c[i][j], 2)
							offset[0]=(((k*m)+2+m)+1)+((k*m)+2)+1+m+((k*m)+2);
							offset[1]=scl*m+scl*m+h*m;
							offset[2]=(k*m)+(k*m)+i*m;
							kaddv((void *)((int *)spmaddrC+offset[0]),  (void *)((int *)spmaddrA+offset[1]),  (void *)((int *)spmaddrB+offset[2]));//data[h][j]-C[i][j]
							ksrav((void *)((int *)spmaddrC+offset[0]),  (void *)((int *)spmaddrC+offset[0]),  shft);//(data[h][j]-C[i][j])>>shift
							kvcp((void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrC+offset[0]));
							kvmul((void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrC+offset[0]));//pow(data[h][j]-C[i][j],2)
							
							offset[0]=(((k*m)+2+m)+1)+((k*m)+2)+1+m+(k*m);
							offset[1]=(((k*m)+2+m)+1)+((k*m)+2)+1+m+((k*m)+2)+m;
							offset[2]=(((k*m)+2+m)+1)+((k*m)+2)+1+m+((k*m)+2);
							kdotp((void *)((int *)spmaddrC+offset[0]),  (void *)((int *)spmaddrC+offset[1]),  (void *)((int *)spmaddrD+offset[2]));//distance+=pow(data[h][j]-C[i][j],2)

							offset[1]=(((k*m)+2+m)+1)+((k*m)+2)+1+m+(k*m);
							kmemstr((void*) &distance,  (void *)((int *)spmaddrC+offset[1]),  SIZE_OF_INT);//distance
							if (distance < min_distance){
								labels[h] = i;
								min_distance = distance;
							}
						}
						//Sum all data in a cluster and put it in c_temp[i][j]
						offset[0]=(((k*m)+2+m)+1)+((k*m)+2)+1+m+(labels[h]*m);
						offset[2]=scl*m+scl*m+(h*m);
						kaddv((void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrA+offset[2]));//c1[labels[h]][j] += data[h][j]
						//update counts[i]
						counts[labels[h]]++;				
						// update standard error 	
						error=error+min_distance;
					}
				}
				else{
					kmemld((void *)((int *)spmaddrA+scl*m+scl*m), &data[scl*p][0],  SIZE_OF_INT*((n-scl*(n_cycle-1))*m));
					for(h=0;h<(n-scl*(n_cycle-1));h++){
						min_distance=max_int;
						for(i=0;i<k;i++){
							CSR_MVSIZE(SIZE_OF_INT);
							offset[0]=(((k*m)+2+m)+1)+((k*m)+2)+1+m+(k*m);
							kbcast((void *)((int *)spmaddrC+offset[0]),  (void *)zero);//distance=0;
							kbcast((void *)((int *)spmaddrD+offset[0]),  (void *)zero);//distance=0;
							CSR_MVSIZE(SIZE_OF_INT*m);
							//distance += pow(data[h][j] - c[i][j], 2)
							offset[0]=(((k*m)+2+m)+1)+((k*m)+2)+1+m+((k*m)+2);
							offset[1]=scl*m+scl*m+h*m;
							offset[2]=(k*m)+(k*m)+i*m;
							kaddv((void *)((int *)spmaddrC+offset[0]),  (void *)((int *)spmaddrA+offset[1]),  (void *)((int *)spmaddrB+offset[2]));//data[h][j]-C[i][j]
							ksrav((void *)((int *)spmaddrC+offset[0]),  (void *)((int *)spmaddrC+offset[0]),  shft);//(data[h][j]-C[i][j])>>shift
							kvcp((void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrC+offset[0]));
							kvmul((void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrC+offset[0]));//pow(data[h][j]-C[i][j],2)
							
							offset[0]=(((k*m)+2+m)+1)+((k*m)+2)+1+m+(k*m);
							offset[1]=(((k*m)+2+m)+1)+((k*m)+2)+1+m+((k*m)+2)+m;
							offset[2]=(((k*m)+2+m)+1)+((k*m)+2)+1+m+((k*m)+2);
							kdotp((void *)((int *)spmaddrC+offset[0]),  (void *)((int *)spmaddrC+offset[1]),  (void *)((int *)spmaddrD+offset[2]));//distance+=pow(data[h][j]-C[i][j],2)

							offset[1]=(((k*m)+2+m)+1)+((k*m)+2)+1+m+(k*m);
							kmemstr((void*) &distance,  (void *)((int *)spmaddrC+offset[1]),  SIZE_OF_INT);//distance
							if (distance < min_distance){
								labels[h] = i;
								min_distance = distance;
							}
						}
						//Sum all data in a cluster and put it in c_temp[i][j]
						offset[0]=(((k*m)+2+m)+1)+((k*m)+2)+1+m+(labels[h]*m);
						offset[2]=scl*m+scl*m+(h*m);
						kaddv((void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrD+offset[0]),  (void *)((int *)spmaddrA+offset[2]));//c1[labels[h]][j] += data[h][j]
						//update counts[i]
						counts[labels[h]]++;						
						// update standard error 						
						error=error+min_distance;
					}
				}
			}
			//update centroids
			CSR_MVSIZE(SIZE_OF_INT*m*k);
			offset[0]=(((k*m)+2+m)+1)+((k*m)+2)+1+m;
			ksrav((void *)((int *)spmaddrC+offset[0]),  (void *)((int *)spmaddrD+offset[0]),  shft);//c1[i][j]>>shift;
			CSR_MVSIZE(SIZE_OF_INT*m);
			for (i = 0; i < k; i++) {
				counts_inv_f[i]=1/(float)counts[i];
				counts_inv[i]=-(int)round((int)round(counts_inv_f[i]*pow(2,FRACTIONAL_PART))>>shft);
				if(counts[i]==0){
					offset[0]=(k*m)+(k*m)+i*m;
					offset[1]=(((k*m)+2+m)+1)+((k*m)+2)+1+m+i*m;
					kvcp((void *)((int *)spmaddrB+offset[0]),  (void *)((int *)spmaddrD+offset[0]));//c[i][j]=c1[i][j]
				}
				else{
					offset[0]=(k*m)+(k*m)+i*m;
					offset[1]=(((k*m)+2+m)+1)+((k*m)+2)+1+m+i*m;
					ksvmulrf((void *)((int *)spmaddrB+offset[0]),  (void *)((int *)spmaddrC+offset[1]),  counts_inv[i]);//c[i][j] = c1[i][j] / counts[i]
				}

			}
			//error check
		}
		while (fabs(error - old_error) > t);
		//download centroids form spm
		kmemstr(&c[0][0],  (void *)((int *)spmaddrB+(k*m)+(k*m)),  SIZE_OF_INT*(k*m));
		finish_count();
	}
	sync_barrier();		
	sync_barrier_reset();		
	sync_barrier_thread_registration();
	if(Klessydra_get_coreID()==0){
		printf("\n");
		printf("Fine_Conteggio:\t");
		for (int i =0 ; i <4; i++){ 
			printf("%d\t",(perf_results[0][i]+perf_results[1][i]+perf_results[2][i])/3);
		}
		printf("\n");
	}
	sync_barrier();		
	sync_barrier_reset();		
	sync_barrier_thread_registration();
	if(Klessydra_get_coreID()==0){
		for(i=0;i<k;i++){
			printf("Cluster %d: ",i);
			for(j=0;j<m;j++){
				printf("%d\t", -c[i][j]);
			}
			printf("\n");
		}
	}
	sync_barrier();
	sync_barrier_reset();		
	sync_barrier_thread_registration();
	if(Klessydra_get_coreID()==1){
		for(i=0;i<k;i++){
			printf("Cluster %d: ",i);
			for(j=0;j<m;j++){
				printf("%d\t", -c[i][j]);
			}
			printf("\n");
		}
	}
	sync_barrier();
	sync_barrier_reset();		
	sync_barrier_thread_registration();
	if(Klessydra_get_coreID()==2){	
		for(i=0;i<k;i++){
			printf("Cluster %d: ",i);
			for(j=0;j<m;j++){
				printf("%d\t", -c[i][j]);
			}
			printf("\n");
		}
	}
	sync_barrier();
	
	return 0;
}






