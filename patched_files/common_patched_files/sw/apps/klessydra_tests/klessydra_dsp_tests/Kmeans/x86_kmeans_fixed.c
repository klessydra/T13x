#include<stdio.h>
#include<assert.h>
#include<float.h> 
#include<math.h>

//#define DATA_SET
//#define DATA_SET2
#define DATA_SET3
#define FRACTIONAL_PART 18
#define SHIFT 9


#ifdef DATA_SET
	#define NUM_OF_POINTS 6
	#define NUM_OF_CENT 3
	#define DIMENSIONS 2
#endif
#ifdef DATA_SET
	float Data[NUM_OF_POINTS][DIMENSIONS]={ 4,0, 1,3, 3,2, 1,3, 4,5, 4,1};
	float Centroids[NUM_OF_CENT][DIMENSIONS]={4,2, 4,3, 3,0};
	float Tolerance = 0.001000;
#endif

#ifdef DATA_SET2
	#define NUM_OF_POINTS 31
	#define NUM_OF_CENT 3
	#define DIMENSIONS 2
#endif
#ifdef DATA_SET2
	float Data[NUM_OF_POINTS][DIMENSIONS]={25, 79, 34, 51, 22, 53, 27, 78, 33, 59, 33, 74, 31, 73, 22, 57, 35, 69, 34, 75, 67, 51, 54, 32, 57, 40, 43, 47, 50, 53, 57, 36, 59, 35, 52, 58, 65, 59, 47, 50, 49, 25, 48, 20, 35, 14, 33, 12, 44, 20, 45, 5, 38, 29, 43, 27, 51, 8, 46, 7};
	float Centroids[NUM_OF_CENT][DIMENSIONS]={4,2, 4,3, 3,0};
	float Tolerance = 0.001000;
#endif

#ifdef DATA_SET3
	#define NUM_OF_POINTS 150
	#define NUM_OF_CENT 3
	#define DIMENSIONS 4
#endif
#ifdef DATA_SET3
	float Data[NUM_OF_POINTS][DIMENSIONS]={5.1, 3.5, 1.4, 0.2
,4.9, 3, 1.4, 0.2
,4.7, 3.2, 1.3, 0.2
,4.6, 3.1, 1.5, 0.2
,5, 3.6, 1.4, 0.2
,5.4, 3.9, 1.7, 0.4
,4.6, 3.4, 1.4, 0.3
,5, 3.4, 1.5, 0.2
,4.4, 2.9, 1.4, 0.2
,4.9, 3.1, 1.5, 0.1
,5.4, 3.7, 1.5, 0.2
,4.8, 3.4, 1.6, 0.2
,4.8, 3, 1.4, 0.1
,4.3, 3, 1.1, 0.1
,5.8, 4, 1.2, 0.2
,5.7, 4.4, 1.5, 0.4
,5.4, 3.9, 1.3, 0.4
,5.1, 3.5, 1.4, 0.3
,5.7, 3.8, 1.7, 0.3
,5.1, 3.8, 1.5, 0.3
,5.4, 3.4, 1.7, 0.2
,5.1, 3.7, 1.5, 0.4
,4.6, 3.6, 1, 0.2
,5.1, 3.3, 1.7, 0.5
,4.8, 3.4, 1.9, 0.2
,5, 3, 1.6, 0.2
,5, 3.4, 1.6, 0.4
,5.2, 3.5, 1.5, 0.2
,5.2, 3.4, 1.4, 0.2
,4.7, 3.2, 1.6, 0.2
,4.8, 3.1, 1.6, 0.2
,5.4, 3.4, 1.5, 0.4
,5.2, 4.1, 1.5, 0.1
,5.5, 4.2, 1.4, 0.2
,4.9, 3.1, 1.5, 0.2
,5, 3.2, 1.2, 0.2
,5.5, 3.5, 1.3, 0.2
,4.9, 3.6, 1.4, 0.1
,4.4, 3, 1.3, 0.2
,5.1, 3.4, 1.5, 0.2
,5, 3.5, 1.3, 0.3
,4.5, 2.3, 1.3, 0.3
,4.4, 3.2, 1.3, 0.2
,5, 3.5, 1.6, 0.6
,5.1, 3.8, 1.9, 0.4
,4.8, 3, 1.4, 0.3
,5.1, 3.8, 1.6, 0.2
,4.6, 3.2, 1.4, 0.2
,5.3, 3.7, 1.5, 0.2
,5, 3.3, 1.4, 0.2
,7, 3.2, 4.7, 1.4
,6.4, 3.2, 4.5, 1.5
,6.9, 3.1, 4.9, 1.5
,5.5, 2.3, 4, 1.3
,6.5, 2.8, 4.6, 1.5
,5.7, 2.8, 4.5, 1.3
,6.3, 3.3, 4.7, 1.6
,4.9, 2.4, 3.3, 1
,6.6, 2.9, 4.6, 1.3
,5.2, 2.7, 3.9, 1.4
,5, 2, 3.5, 1
,5.9, 3, 4.2, 1.5
,6, 2.2, 4, 1
,6.1, 2.9, 4.7, 1.4
,5.6, 2.9, 3.6, 1.3
,6.7, 3.1, 4.4, 1.4
,5.6, 3, 4.5, 1.5
,5.8, 2.7, 4.1, 1
,6.2, 2.2, 4.5, 1.5
,5.6, 2.5, 3.9, 1.1
,5.9, 3.2, 4.8, 1.8
,6.1, 2.8, 4, 1.3
,6.3, 2.5, 4.9, 1.5
,6.1, 2.8, 4.7, 1.2
,6.4, 2.9, 4.3, 1.3
,6.6, 3, 4.4, 1.4
,6.8, 2.8, 4.8, 1.4
,6.7, 3, 5, 1.7
,6, 2.9, 4.5, 1.5
,5.7, 2.6, 3.5, 1
,5.5, 2.4, 3.8, 1.1
,5.5, 2.4, 3.7, 1
,5.8, 2.7, 3.9, 1.2
,6, 2.7, 5.1, 1.6
,5.4, 3, 4.5, 1.5
,6, 3.4, 4.5, 1.6
,6.7, 3.1, 4.7, 1.5
,6.3, 2.3, 4.4, 1.3
,5.6, 3, 4.1, 1.3
,5.5, 2.5, 4, 1.3
,5.5, 2.6, 4.4, 1.2
,6.1, 3, 4.6, 1.4
,5.8, 2.6, 4, 1.2
,5, 2.3, 3.3, 1
,5.6, 2.7, 4.2, 1.3
,5.7, 3, 4.2, 1.2
,5.7, 2.9, 4.2, 1.3
,6.2, 2.9, 4.3, 1.3
,5.1, 2.5, 3, 1.1
,5.7, 2.8, 4.1, 1.3
,6.3, 3.3, 6, 2.5
,5.8, 2.7, 5.1, 1.9
,7.1, 3, 5.9, 2.1
,6.3, 2.9, 5.6, 1.8
,6.5, 3, 5.8, 2.2
,7.6, 3, 6.6, 2.1
,4.9, 2.5, 4.5, 1.7
,7.3, 2.9, 6.3, 1.8
,6.7, 2.5, 5.8, 1.8
,7.2, 3.6, 6.1, 2.5
,6.5, 3.2, 5.1, 2
,6.4, 2.7, 5.3, 1.9
,6.8, 3, 5.5, 2.1
,5.7, 2.5, 5, 2
,5.8, 2.8, 5.1, 2.4
,6.4, 3.2, 5.3, 2.3
,6.5, 3, 5.5, 1.8
,7.7, 3.8, 6.7, 2.2
,7.7, 2.6, 6.9, 2.3
,6, 2.2, 5, 1.5
,6.9, 3.2, 5.7, 2.3
,5.6, 2.8, 4.9, 2
,7.7, 2.8, 6.7, 2
,6.3, 2.7, 4.9, 1.8
,6.7, 3.3, 5.7, 2.1
,7.2, 3.2, 6, 1.8
,6.2, 2.8, 4.8, 1.8
,6.1, 3, 4.9, 1.8
,6.4, 2.8, 5.6, 2.1
,7.2, 3, 5.8, 1.6
,7.4, 2.8, 6.1, 1.9
,7.9, 3.8, 6.4, 2
,6.4, 2.8, 5.6, 2.2
,6.3, 2.8, 5.1, 1.5
,6.1, 2.6, 5.6, 1.4
,7.7, 3, 6.1, 2.3
,6.3, 3.4, 5.6, 2.4
,6.4, 3.1, 5.5, 1.8
,6, 3, 4.8, 1.8
,6.9, 3.1, 5.4, 2.1
,6.7, 3.1, 5.6, 2.4
,6.9, 3.1, 5.1, 2.3
,5.8, 2.7, 5.1, 1.9
,6.8, 3.2, 5.9, 2.3
,6.7, 3.3, 5.7, 2.5
,6.7, 3, 5.2, 2.3
,6.3, 2.5, 5, 1.9
,6.5, 3, 5.2, 2
,6.2, 3.4, 5.4, 2.3
,5.9, 3, 5.1, 1.8};
	//float Centroids[NUM_OF_CENT][DIMENSIONS]={4,2, 4,3, 3,0};
	float Tolerance = 0.001000;
#endif

#define RISCY
int perf0 = 0;
int final_perf0 = 777;
int *ptr_perf0 = &perf0;

int perf1 = 0;
int final_perf1 = 777;
int *ptr_perf1 = &perf1;

int perf3 = 0;
int final_perf3 = 777;
int *ptr_perf3 = &perf3;

int perf4 = 0;
int final_perf4 = 777;
int *ptr_perf4 = &perf4;

int 	performance=0;
int 	perf[3]= {0,0,0};
int* 	ptr_perf[3];
int perf_results[3][4]={0};


void start_count_riscy(){
			int enable_perf_cnt = 0;
			final_perf0=0;
			final_perf1=0;
			final_perf3=0;
			final_perf4=0;
			__asm__("csrrw zero, 0x780, zero;"  // reset cycle count
					"csrrw zero, 0x781, zero;"  // reset instruction count
					"csrrw zero, 0x785, zero;"  // reset memory load count
					"csrrw zero, 0x786, zero;"  // reset memory store count
					"li %[enable], 0x000003F3;"  // 
					"csrrw zero, 0x7A0, %[enable]" // enable performance counters
					:
					:[enable] "r" (enable_perf_cnt)
			);
}
void finish_count_riscy(){
			__asm__("csrrw zero, 0x7A0, 0x00000000;" // disable performance counters
					"csrrw %[perf0], 0x780, zero;"
					"sw %[perf0], 0(%[ptr_perf0]);"
					"csrrw %[perf1], 0x781, zero;"
					"sw %[perf1], 0(%[ptr_perf1]);"
					"csrrw %[perf3], 0x785, zero;"
					"sw %[perf3], 0(%[ptr_perf3]);"
					"csrrw %[perf4], 0x786, zero;"
					"sw %[perf4], 0(%[ptr_perf4]);"
					:
					:[perf0] "r" (perf0), [ptr_perf0] "r" (ptr_perf0),
					 [perf1] "r" (perf1), [ptr_perf1] "r" (ptr_perf1),
					 [perf3] "r" (perf3), [ptr_perf3] "r" (ptr_perf3),
					 [perf4] "r" (perf4), [ptr_perf4] "r" (ptr_perf4)
			);

			final_perf0=*(ptr_perf0);
			final_perf1=*(ptr_perf1);
			final_perf3=*(ptr_perf3);
			final_perf4=*(ptr_perf4);
}

#include "functions.h"

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


int main()
{
	int data[NUM_OF_POINTS][DIMENSIONS];
	int n=NUM_OF_POINTS;
	int m=DIMENSIONS;
	int k=NUM_OF_CENT;
	int t=(int)round(Tolerance*pow(2,FRACTIONAL_PART));
	int centroids[NUM_OF_CENT][DIMENSIONS];
	int labels[n];
	int counts[k];
	int h,i,j;
	int old_error;
	int error=2147483647;
	int c[k][m];
	int c1[k][m];
	int sub[k][m];
	int sub2[k][m];
	int inv_count[k];
	float inv_count_f[k];
	int prod[k][m];
	
	for ( i = 0; i < n; i++){
		for ( j = 0 ; j < m; j++){
			data[i][j]=(int)round(Data[i][j]*pow(2,FRACTIONAL_PART));
		}
	}
	
	
	for (h=i=0; i<k; h+=n/k, i++) {
		for (j=m-1; j>-1;j--){
			c[i][j] = data[h][j];
		}
	}

	__asm__("csrw 0x300, 0x8;" );//Enable interrupts for all threads
	__asm__("csrrw zero, mcycle, zero");
	sync_barrier_reset();		
	sync_barrier_thread_registration();
	sync_barrier();

	sync_barrier_reset();		
	sync_barrier_thread_registration();
	#ifdef RISCY
	//start_count_riscy();
	start_count();
	#endif
	do {
		/* save error from last step */
		old_error = error;
		error = 0;
		/* clear old counts and temp centroids */
		for (i = 0; i < k; i++) {
			for (j = 0; j < m; j++){
				c1[i][j] = 0;
			}
		}
		for(i=0;i<k;i++){
			counts[i]=0;
		}
		for (h = 0; h < n; h++) {
			/* identify the closest cluster */
			int min_distance = 2147483647;
			for (i = 0; i < k; i++) {
				for(int p=k-1;p>-1;p--){
					for (j = m-1; j > -1; j--){
						sub[i][j]=0;
					}
				}
				for(int p=k-1;p>-1;p--){
					for (j = m-1; j>-1; j--){
						sub2[i][j]=0;
					}
				}
				for(int p=k-1;p>-1;p--){
					for (j = m-1; j>-1; j--){
						prod[i][j]=0;
					}
				}
				int distance = 0;
				for (j = 0; j < m; j++){
					sub[i][j]=data[h][j] - c[i][j];
					sub[i][j]=sub[i][j]>>SHIFT;
					sub2[i][j]=sub[i][j];
					prod[i][j]=sub[i][j]*sub2[i][j];
					distance += prod[i][j];
				}
				if (distance < min_distance) {
					labels[h] = i;
					min_distance = distance;
				}
			}
			/* update size and temp centroid of the destination cluster */
			for (j = m-1; j>-1; j--){ 
				c1[labels[h]][j] += data[h][j];
			}		
			counts[labels[h]]++;
			/* update standard error */
			error += min_distance;
		}
		for (i = 0; i < k; i++) { /* update all centroids */
			inv_count_f[i]=1/(float)counts[i];
			inv_count[i]=(int)round(inv_count_f[i]*pow(2,FRACTIONAL_PART));
			inv_count[i]=(int)round(inv_count[i]>>SHIFT);
			for (j = 0; j < m; j++) {
				if(counts[i]==0){
					c[i][j]=c1[i][j];
				}
				else{
					c1[i][j]=c1[i][j]>>SHIFT;
					c[i][j]=c1[i][j] * inv_count[i];
				}
			}
		}
	} while (fabs(error - old_error) > t);

	#ifdef RISCY
	//finish_count_riscy();
	finish_count();
	sync_barrier();
	//printf(" Cycle Count = %d \n Instruction Count = %d \n Load Count = %d \n Store Count = %d \n \n", final_perf0, final_perf1, final_perf3, final_perf4);
	if (Klessydra_get_coreID()==0) {
	  for(i=0; i<3; i++){
	    printf(" Cycle Count = %d \n Instruction Count = %d \n Load Count = %d \n Store Count = %d \n \n", perf_results[i][0], perf_results[i][1], perf_results[i][2], perf_results[i][3]);
	  }
	}
    else {
      __asm__("wfi;");
    }
	#endif
	
	for(i=0;i<k;i++){
		printf("Centroid[%d]:  ",i);
		for(j=0;j<m;j++){
			printf("%d\t",c[i][j]);
		}
		printf("\n");
	}
	
	
	return 0;
}


